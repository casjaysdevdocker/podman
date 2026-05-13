## 👋 Welcome to podman 🚀  

podman README  
  
  
## Install my system scripts  

```shell
 sudo bash -c "$(curl -q -LSsf "https://github.com/systemmgr/installer/raw/main/install.sh")"
 sudo systemmgr --config && sudo systemmgr install scripts  
```
  
## Automatic install/update  
  
```shell
dockermgr update podman
```
  
## Install and run container
  
```shell
dockerHome="/var/lib/srv/$USER/docker/casjaysdevdocker/podman/podman/latest/rootfs"
mkdir -p "/var/lib/srv/$USER/docker/podman/rootfs"
git clone "https://github.com/dockermgr/podman" "$HOME/.local/share/CasjaysDev/dockermgr/podman"
cp -Rfva "$HOME/.local/share/CasjaysDev/dockermgr/podman/rootfs/." "$dockerHome/"
docker run -d \
--restart always \
--privileged \
--name casjaysdevdocker-podman-latest \
--hostname podman \
-e TZ=${TIMEZONE:-America/New_York} \
-v "$dockerHome/data:/data:z" \
-v "$dockerHome/config:/config:z" \
-p 80:80 \
casjaysdevdocker/podman:latest
```
  
## via docker-compose  
  
```yaml
version: "2"
services:
  ProjectName:
    image: casjaysdevdocker/podman
    container_name: casjaysdevdocker-podman
    environment:
      - TZ=America/New_York
      - HOSTNAME=podman
    volumes:
      - "/var/lib/srv/$USER/docker/casjaysdevdocker/podman/podman/latest/rootfs/data:/data:z"
      - "/var/lib/srv/$USER/docker/casjaysdevdocker/podman/podman/latest/rootfs/config:/config:z"
    ports:
      - 80:80
    restart: always
```
  
## Get source files  
  
```shell
dockermgr download src casjaysdevdocker/podman
```
  
OR
  
```shell
git clone "https://github.com/casjaysdevdocker/podman" "$HOME/Projects/github/casjaysdevdocker/podman"
```
  
## Build container  
  
```shell
cd "$HOME/Projects/github/casjaysdevdocker/podman"
buildx 
```
  
## Authors  
  
🤖 casjay: [Github](https://github.com/casjay) 🤖  
⛵ casjaysdevdocker: [Github](https://github.com/casjaysdevdocker) [Docker](https://hub.docker.com/u/casjaysdevdocker) ⛵  
