# Build infrastructure (Jenkins + GCE)

How apt.llvm.org packages are built on Google Cloud. Background:
<https://blog.llvm.org/posts/2021-11-02-apt.llvm.org-moving-from-physical-server-to-the-cloud/>

Hosted on Google Cloud (region `europe-west1`). Project ID, service-account
emails and keys are intentionally kept out of this (public) repo.

## Overview

A single Jenkins controller (`llvm-jenkins.debian.net`) drives matrix builds. Most
architectures build on **ephemeral GCE agents**: Jenkins boots a VM from a baked
image on demand, runs one or more builds, and deletes it after a short idle
retention. Nothing build-related runs on the controller itself.

```
Jenkins controller  ──(google-compute-engine plugin, cloud "gce-gce")──┐
                                                                        │ boots on demand
   ┌───────────────────────┬────────────────────────────┐             ▼
   amd64 / i386             arm64                      s390x        ephemeral VM
   image-debian-node-N      image-debian-node-arm64-1   (separate)  (c4a/e2-standard-32)
   europe-west1-b           europe-west1-c                          │
                                                                     ├─ cowbuilder/pbuilder chroot
                                                                     ├─ sccache → GCS (apt-llvm-org-sccache)
                                                                     └─ result pushed back to controller
```

## Per-architecture agents

| Arch | Provisioning | Machine type | Zone | Boot image | Notes |
|------|--------------|--------------|------|-----------|-------|
| amd64 / i386 | ephemeral (`deb-*`) | e2-standard-32 | europe-west1-b | `image-debian-node-N` | Java 21 in `/usr/bin/java` |
| arm64 | ephemeral (`arm64-*`) | c4a-standard-32 (Axion) | europe-west1-c | `image-debian-node-arm64-1` | Java 21 via `javaExecPath`; see gotchas |
| s390x | separate / local sccache | — | — | — | no GCS cache (local `SCCACHE_DIR`) |

The amd64 and arm64 InstanceConfigurations both live in `config.xml` under the
`gce-gce` cloud (`instanceCap 10`, 5-minute retention). They differ by
`namePrefix`, zone, `machineType`, `labels`, boot image, and `javaExecPath`.

### `arm64-build` / `debian-build-node` — the image builders

Each ephemeral image has a long-lived **builder VM** that is the golden source for
that image and is normally **STOPPED**:

- `debian-build-node` (europe-west1-b) → `image-debian-node-N` (amd64/i386)
- `arm64-build` (europe-west1-c, kept as Spot) → `image-debian-node-arm64-1` (arm64)

You start it, update it, stop it, and snapshot its disk to a new image. See
[Refreshing an image](#refreshing-an-image).

## The deploy mechanism (important)

Live config on the controller is wired to **this git checkout** at
`/home/jenkins/llvm-jenkins.debian.net.git`, so most changes deploy by `git push`
+ a pull on the node — **no image re-bake needed**:

- `/var/lib/jenkins/config.xml` is a **hardlink** to the checkout's `config.xml`.
  Editing it in git and re-establishing the hardlink (`ln -f`) updates the live
  config. (See [[jenkins-config-deploy]] in memory for the fragile auto-pull.)
- `/root/.pbuilderrc` is a **symlink** to the checkout's `pbuilderrc`.
- pbuilder hooks are read straight from the checkout:
  `PBUILDER_HOOKDIR=/home/jenkins/llvm-jenkins.debian.net.git/pbuilder-hookdir/`
  (set in `/etc/jenkins/debian_glue`, matched by `create-refresh-image.sh`).
- **Ephemeral nodes `git stash && git pull && git stash apply` on boot**, so a
  pushed `pbuilderrc` / hook change reaches every new agent on its next launch.

What does **NOT** deploy via git and must be baked into the image: anything not in
the repo — the GCS service-account key, `/etc/resolv.conf`, the Java 21 JDK, the
cowbuilder base chroots, and (for arm64) the host `/opt/sccache` contents.

There is a stale `salt://jenkins/pbuilderrc` (file.managed → `/root/.pbuilderrc`);
it is **not** what runs — the symlink wins. Don't be misled by it.

## The build chain

1. Jenkins matrix job picks a `{dist, arch}` cell, requests an agent with the
   matching label; the cloud plugin boots a VM from the image.
2. jenkins-debian-glue runs `cowbuilder`/`pbuilder` with `/root/.pbuilderrc`.
3. `pbuilderrc` sets `BINDMOUNTS`, `USENETWORK`, mirrors per dist/arch.
4. pbuilder hooks fire inside the chroot. `D23sccache` downloads the sccache
   binary (if absent) and starts the server.
5. `debian/rules` (from the `llvm-toolchain` source package) compiles with sccache
   in front of clang/gcc, reading/writing the shared GCS cache.
6. The `.deb`s and stats artifacts are returned to the controller.

## sccache

sccache fronts the compiler and caches objects in **GCS bucket
`apt-llvm-org-sccache`** (s390x is the exception — it uses a local `SCCACHE_DIR`).

Three things must align for an arch to use the GCS cache. All are gated by
"is this an intel/cloud arch?" checks that historically listed only i386/amd64:

1. **`pbuilderrc` — `USENETWORK=yes`** (sccache needs network for GCS). Line ~108.
2. **`pbuilderrc` — bind-mount the host `/opt/sccache`** into the chroot. Line ~120.
   This is the real permission fix: the *host* `/opt/sccache` is `777` (jenkins) and
   holds the GCS key; bind-mounting it gives the chroot a writable cache dir + key.
3. **`debian/rules` GCS-branch filter** (in `llvm-toolchain`, not this repo): the
   `ifneq (,$(filter $(DEB_HOST_ARCH),i386 amd64 ...))` that selects GCS vs local.

A dedicated GCS service-account key lives under `/opt/sccache/` (a JSON key with
read/write on the bucket). It is **not in git or salt**; it is baked into each
image and must be re-placed on a from-scratch rebuild. The filename/path is the
one referenced by `SCCACHE_GCS_KEY_PATH` in the `D23sccache` hook.

### The `D23sccache` hook & the log-permission trap

`pbuilder-hookdir/D23sccache` runs **as root**, but `debian/rules` starts the
sccache server **as the non-root pbuilder build user**. Both write
`SCCACHE_ERROR_LOG=/opt/sccache/sccache.log`. If the root hook creates that file
first (e.g. its `--show-stats` fails GCS auth because the key is missing), the
non-root builder then can't write it →
`Cannot open/write log file '/opt/sccache/sccache.log'` →
`Timed out waiting for server startup` → **FTBFS at `stamps/configure`**.

Fixes in place (self-healing on every arch):

- the hook pre-creates `sccache.log` `0666` and keeps the dir `0777`;
- with the writable host `/opt/sccache` (+ key) bind-mounted, `--show-stats`
  succeeds, so no root-owned error log is ever written.

## arm64 gotchas (don't regress)

arm64 was migrated from an always-on node to ephemeral agents on 2026-06-16.
Three non-obvious things are baked into its setup — see
[[arm64-ephemeral-migration]] in memory for the full story:

1. **Java:** the controller ships Java 21 agent classes. The arm64 image's
   `/usr/bin/java` is 17 → `UnsupportedClassVersionError` (class 65.0 vs 61.0) →
   "Connection was broken", node never connects. Fix: the arm64
   InstanceConfiguration sets `javaExecPath=/home/jenkins/jdk-21.0.11/bin/java`.
   amd64's `/usr/bin/java` is already 21.
2. **DNS:** a fresh boot of the arm64 image has an **empty `/etc/resolv.conf`** (no
   systemd-resolved; networkd doesn't populate it) → can't resolve the controller
   or GitHub. Fix baked on the disk: static `/etc/resolv.conf` with
   `nameserver 169.254.169.254` (GCP metadata DNS).
3. **sccache:** arm64 was excluded from the three GCS gates above; the always-on
   node had masked it with persisted writable `/opt/sccache` state. Now fixed in
   `pbuilderrc` + the hook (pushed); the `debian/rules` gate lives in `llvm-toolchain`.

Also: `create-refresh-image.sh` only bootstraps `ARCHS="amd64 i386"` cowbuilder
bases — it does **not** build arm64 bases. The arm64 pbuilder bases live on the
`arm64-build` disk and must be handled separately when rebuilding from scratch.

## Refreshing an image

Run `image-update.sh` (amd64 flow; the arm64 flow mirrors it with the arm64
builder/zone/image). It:

1. Warns about **stale `deb-*` agents** (older than `STALE_DEB_DAYS`, default 3) —
   these are usually bound to an obsolete image, fail the remoting handshake, pin
   the cloud at its `instanceCap`, and **block all builds**. Kill them in the GCP
   console and remove the matching Jenkins node.
2. Starts the builder VM (`debian-build-node`), where you `apt dist-upgrade`,
   refresh repos, and run `create-refresh-image.sh` (updates/creates cowbuilder
   bases for each dist/arch using `HOOKDIR` = this checkout's `pbuilder-hookdir`).
3. Stops the VM, snapshots its disk to `image-debian-node-{N+1}`, deprecates the
   old image, and tells you to bump the image name in `config.xml` (the cloud
   config) and restart Jenkins.

## Files in this repo

| File | Role |
|------|------|
| `config.xml` | Jenkins global config incl. the `gce-gce` cloud + per-arch InstanceConfigurations (hardlinked live) |
| `pbuilderrc` | pbuilder config: mirrors, `BINDMOUNTS`, `USENETWORK` per dist/arch (symlinked to `/root/.pbuilderrc`) |
| `pbuilder-hookdir/` | pbuilder hooks run inside the chroot (`D23sccache` starts sccache; `D20scan-build`; …) |
| `debian_glue` | jenkins-debian-glue config |
| `create-refresh-image.sh` | (re)build cowbuilder base chroots on the builder VM |
| `image-update.sh` | start builder → refresh → snapshot to a new image |
| `jobs/` | per-job Jenkins config |
```
