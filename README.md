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
Be sure to have at least 3GB free (RAM+SWAP) for your SafeCoin container, then run:
```
docker volume create --name safecoin-data
docker run --restart always -p 8770:8770 -v safecoin-data:/safecoin --name=safecoin -d safecoin/safecoin
```

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
docker exec SAFECOIN_CONTAINER_ID safecoin-cli
```

#### Create a wallet backup
```
docker cp SAFECOIN_CONTAINER_ID:/safecoin/.safecoin/wallet.dat .
```

#### Gracefully shutdown the container
If you stop the container with `docker stop`, safecoind will have 10s to terminate before to be brutally killed (SIGKILL). It's not a good way to stop a container. You should instead do:
```
docker kill --signal=SIGTERM safecoind
docker stop safecoind
```

#### Keep the container up-to-date with systemd service
:warning: THIS IS AN EXPERIMENTAL FEATURE, BE SURE TO HAVE A BACKUP OF YOUR WALLETS AND THE WILL TO FIGHT AGAINST BUGS

You can enable a systemd service that will pull the latest image from our repositories at every boot. If it's not your first SafeCoin container or you changed the name of the container/volume, do:
```
sed -i 's/=safecoin/=YOURCONTAINERNAME/' docker-safecoin.service > docker-YOURCONTAINERNAME.service
sed -i 's/-p 8770:8770 //' docker-YOURCONTAINERNAME.service
```
Now you have to copy on systemd folder and enable it.
```
mv docker-safecoin.service /etc/systemd/system
systemctl daemon-reload
systemctl enable --now docker-safecoin.service
```
Note that if you used `sed`, you have to change `docker-safecoin.service` with `docker-YOURCONTAINERNAME.service` where `YOURCONTAINERNAME` is the name you gave at the container.

## FAQ
#### Something went wrong, how can I see logs?
```
docker logs SAFECOIN_CONTAINER_ID
```
You can use `--follow` argument to continue streaming the new output from the container’s STDOUT and STDERR.

#### I sadly need to debug. How can I spawn a shell into the container?
```
docker exec -it SAFECOIN_CONTAINER_ID bash
```
You will be on a Ubuntu image.

#### I have a problem or I can't find my question on FAQs
Join on [Discord](https://discord.gg/c6hWAkQ) and ask there. Someone will help you for sure! :)
