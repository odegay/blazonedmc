 #! /bin/bash
 # gcloud compute instances create example-instance --metadata-from-file startup-script=mc_start.sh
docker container prune -f
docker image prune -a -f
rm -rf /tmp/blazonedmc
git clone https://github.com/odegay/blazonedmc.git /tmp