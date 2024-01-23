#!/bin/bash
set -e
export CLOUDSDK_PYTHON="/usr/bin/python3.9"

# Update the gcloud image

# List what we have
gcloud compute instances list

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
