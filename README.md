# SafeCoin for Docker
[![](https://images.microbadger.com/badges/version/safecoin/safecoin.svg)](https://hub.docker.com/r/safecoin/safecoin)

Docker image that runs SafeCoin daemon in a container for easy deployment.

## Installation
### Requirements
#### [Install Docker](https://docs.docker.com/get-docker/)

### Fast setup
Run as root:
```
curl https://raw.githubusercontent.com/Fair-Exchange/safecoin-docker/master/boostrap-host.sh | sh
```
###### root is needed for swap creation and systemd service. If you have enough memory and the user has the permission to run a docker container, you can run it as normal user.

### Manual setup
**Before to start the container, be sure to have at least 3GB free (RAM+SWAP)**

Run:
```
docker volume create --name safecoin-data
docker run --restart always -p 8770:8770 -v safecoin-data:/safecoin --name=safecoin -d safecoin/safecoin
```
#### ARM (BETA)
To run the beta version of the daemon on ARM use `safecoin/safecoin:arm-beta` as image.

> Note: if you want to set a particular option to safecoind you can pass it as argument to `docker run`.
>
> For example, if you want to reduce the RAM usage you reduce [-dbcache](https://github.com/Fair-Exchange/safecoin/blob/master/doc/reducing-memory-usage.md) running:
>
> ```
> docker run --restart always -p 8770:8770 -v safecoin-data:/safecoin --name=safecoin -d safecoin/safecoin -dbcache=4
> ```
>
> If you already have a running container you can stop it, edit `safecoin.conf` in your volume and start it or you can remove it and create a new one with different options.
>
> **:warning: removing a container which doesn't use volume to store data will inevitably lead to data loss!**

### Build from sources (expert users)
```
curl -L https://github.com/Fair-Exchange/safecoin-docker/archive/master.tar.gz | tar xz
cd safecoin-docker-master/
docker build --tag safecoin:manualbuild .

docker volume create --name safecoin-data
docker run --restart always -p 8770:8770 -v safecoin-data:/safecoin --name=safecoin -d safecoin:manualbuild
```

**NOTE**: you can choose the source version passing `--build-args VERSION=v0.xx` to Docker Build, by default it compiles the up-to-date master branch.

#### Use safecoin-cli
```
docker exec safecoin safecoin-cli <args>
```

#### Create a wallet backup
```
docker cp safecoin:/safecoin/.safecoin/wallet.dat .
```

#### Gracefully shutdown the container
If you stop the container with `docker stop`, safecoind will have 10s to terminate before to be brutally killed (SIGKILL). It's not a good way to stop a container. You should instead do:
```
docker kill --signal=SIGTERM safecoind
docker stop safecoind
```

#### Keep the container up-to-date with systemd service
:warning: THIS IS AN EXPERIMENTAL FEATURE, BE SURE TO HAVE A BACKUP OF YOUR WALLETS AND THE WILL TO FIGHT AGAINST BUGS

You can enable a systemd service that will pull the latest image from our repositories at every boot copying `docker-safecoin.service` on systemd services' folder.
```
mv docker-safecoin.service /etc/systemd/system
systemctl daemon-reload
systemctl enable --now docker-safecoin.service
```

## FAQ
#### Something went wrong, how can I see logs?
```
docker logs safecoin
```
You can use `--follow` argument to continue streaming the new output from the container’s STDOUT and STDERR.

#### I sadly need to debug. How can I spawn a shell into the container?
```
docker exec -it safecoin bash
```
You will be on a Ubuntu image.

#### I have a problem or I can't find my question on FAQs
Join on [Discord](https://discord.gg/c6hWAkQ) and ask there. Someone will help you for sure! :)
