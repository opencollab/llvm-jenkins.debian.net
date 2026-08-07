#!/bin/bash
set -e
export CLOUDSDK_PYTHON="/usr/bin/python3.11"

# Update the gcloud image

# List what we have
gcloud compute instances list

# Warn about stale build agents.
# deb-* agents are meant to be short-lived (minutes). If any are more than a few
# days old, Jenkins is almost certainly re-attaching to VMs built from an obsolete
# image (e.g. an agent Java older than the controller's), which fails the remoting
# handshake, pins the cloud at its instanceCap and blocks ALL builds.
STALE_DEB_DAYS=${STALE_DEB_DAYS:-3}
check_stale_deb_instances() {
    local now cutoff name created created_epoch age_days found=0
    now=$(date +%s)
    cutoff=$(( STALE_DEB_DAYS * 86400 ))
    while read -r name created; do
        [ -z "$name" ] && continue
        created_epoch=$(date -d "$created" +%s 2>/dev/null) || continue
        if [ $(( now - created_epoch )) -gt "$cutoff" ]; then
            found=1
            age_days=$(( (now - created_epoch) / 86400 ))
            printf '   %-18s created %s  (%d days old)\n' "$name" "$created" "$age_days"
        fi
    done < <(gcloud compute instances list \
                 --filter="name~'^deb-'" \
                 --format="value(name,creationTimestamp)" 2>/dev/null)

    if [ "$found" -eq 1 ]; then
        echo ""
        echo "=============================================================================="
        echo "  WARNING: stale deb-* build agents detected (older than ${STALE_DEB_DAYS} days, listed above)"
        echo ""
        echo "  They are almost certainly bound to an OBSOLETE image and will fail to"
        echo "  connect (e.g. agent Java < controller Java), pinning the cloud at its"
        echo "  instanceCap and blocking ALL builds."
        echo ""
        echo "  >>> KILL THEM in the GCP console (delete the VMs), then remove the matching"
        echo "      node in Manage Jenkins -> Nodes so a fresh agent is provisioned:"
        echo "      https://console.cloud.google.com/compute/instances?project=secret-envoy-319113"
        echo "=============================================================================="
        echo ""
    else
        echo "No stale deb-* agents (none older than ${STALE_DEB_DAYS} days)."
    fi
}
check_stale_deb_instances

# Start the VM
gcloud compute instances start debian-build-node --zone europe-west1-b &> out.log

# Retrieve the public ip
IP=$(grep "external" out.log|awk '{print $5}')
echo "Sleep until $IP is live"
sleep 30s

echo "# Commands that you might want to run
su
apt update && apt dist-upgrade
su - jenkins
# run:
bash update-vm.sh

# which will run:
rm -f agent.jar
wget https://llvm-jenkins.debian.net/jnlpJars/agent.jar
cd ~/llvm-project
git pull
cd ~/llvm-toolchain-integration-test-suite
git stash && git pull && git stash apply
cd ~/llvm-jenkins.debian.net.git
git stash && git pull && git stash apply
bash create-refresh-image.sh"
ssh $IP

echo "if timeout, check the GCP firewall"
# hack on the vm

# Stop the vm for the image creation
gcloud compute instances stop debian-build-node

# Retrieve the current image
gcloud compute images list --filter="name~'image-debian-node-.*'" &> out.log
NODEID=$(grep "image-debian-node" out.log|awk '{print $1}'|cut -d- -f4)
NEW_NODE=$((NODEID+1))
# Create the new image
gcloud compute images create  image-debian-node-$NEW_NODE --source-disk=debian-build-node --source-disk-zone=europe-west1-b
# Obsolete the old one
gcloud compute images deprecate image-debian-node-$NODEID --state=OBSOLETE --replacement=image-debian-node-$NEW_NODE

echo "Update jenkins on https://llvm-jenkins.debian.net/manage/cloud/gce-gce/configure"
echo "sed -i -e 's|image-debian-node-$NODEID|image-debian-node-$NEW_NODE|' /var/lib/jenkins/config.xml && service jenkins restart"
echo "Delete the old image (image-debian-node-$NODEID) once image-debian-node-$NEW_NODE is OK"
echo "https://console.cloud.google.com/compute/images?tab=images&authuser=1&"
rm out.log
