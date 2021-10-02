#!/bin/bash
set -e

# Update the gcloud image
gcloud compute instances list

# Start the VM
gcloud compute instances start debian-build-node &> out.log

# Retrieve the public ip
IP=$(grep "external" out.log|awk '{print $5}')
echo "Sleep until $IP is live"
sleep 30s
ssh $IP

# hack on the vm

# Stop the vm for the image creation
gcloud compute instances stop debian-build-node

# Retrieve the current image
gcloud compute images list --filter="name~'image-debian-node-.*'" &> out.log
NODEID=$(grep "image-debian-node" out.log|awk '{print $1}'||cut -d- -f4)
NEW_NODE=i=$((NODEID+1))
# Create the new image
gcloud compute images create image-debian-node-$NEW_NODE --source-disk=debian-build-node
# Obsolete the old one
gcloud compute images deprecate  image-debian-node-$NODEID --state=OBSOLETE --replacement=image-debian-node-$NEW_NODE

echo "Update jenkins on http://URL/configureClouds/"
rm out.log
