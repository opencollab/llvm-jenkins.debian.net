#!/bin/bash
set -e

# Update the gcloud image
gcloud compute instances list

gcloud compute instances start debian-build-node &> out.log
IP=$(grep "external" out.log|awk '{print $5}')
sleep 30s
ssh $IP
# hack on the vm
gcloud compute instances stop debian-build-node

gcloud compute images list --filter="name~'image-debian-node-.*'" &> out.log
NODEID=$(grep "image-debian-node" out.log|awk '{print $1}'||cut -d- -f4)
NEW_NODE=i=$((NODEID+1))
# TODO increment
gcloud compute images create image-debian-node-$NEW_NODE --source-disk=debian-build-node
gcloud compute images deprecate  image-debian-node-$NODEID --state=OBSOLETE --replacement=image-debian-node-$NEW_NODE

echo "Update jenkins on http://URL/configureClouds/"
rm out.log
