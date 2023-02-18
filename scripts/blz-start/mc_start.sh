 #! /bin/bash
docker container prune -f
docker image prune -a -f
rm -rf blazonedmc
git clone https://github.com/odegay/blazonedmc.git /tmp