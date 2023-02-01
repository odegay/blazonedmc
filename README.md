# build the image
docker build . -f Dockerfile_dev -t blzmc --no-cache

# vanila
docker run -e EULA=true -p 25565:25565 --name blzmcc blzmc

# vanila with interaction
docker run -e EULA=true -d -it -p 25565:25565 --name blzmcc blzmc


# paper with interaction
docker run -e EULA=true -e TYPE=PAPER -p 25565:25565 --name blzmcc blzmc

# scan the container
docker exec -t -i blzmcc /bin/bash