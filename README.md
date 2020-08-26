# SafeCoin for Docker
[![](https://images.microbadger.com/badges/version/safecoin/safecoin.svg)](https://hub.docker.com/r/safecoin/safecoin)

Docker image that runs SafeCoin daemon in a container for easy deployment.

## Installation
**Before to continue, be sure to have at least 3GB free (RAM+SWAP)**

### Fast setup
Run and follow instructions.
```
./boostrap-host.sh
```

> If you are running a safenode, prefix will be `safenode` not `safecoin`

### Manual setup

#### [Configure OBFS4 bridges (optional)](https://github.com/Fair-Exchange/safecoin-docker/tree/master/tor#use-a-obfs4-bridge-to-circumvent-censorship)
This is useful for users who needs to circumvent censorship (eg. who lives in China).

#### Setup
We have 4 docker-compose files:
- `docker-compose.yml`: base. This *must* always be included.
- `docker-compose.safenode.yml`: includes some scripts to help running a SafeNode
- `docker-compose.fightcens.yml`: run a [OBFS4 bridge](https://github.com/Yawning/obfs4/blob/master/doc/obfs4-spec.txt) and a [SnowFlake proxy](https://snowflake.torproject.org/) to help fighting censorship. Both are secure to run. You will need to make TCP ports 8772/8773 reachables from the internet **before running the container**.

Choose the ones you need and run:
```
docker-compose -p safecoin -f docker-compose.yml [-f docker-compose.safenode.yml] [-f docker-compose.fightcens.yml] build --pull
docker-compose -p safecoin -f docker-compose.yml [-f docker-compose.safenode.yml] [-f docker-compose.fightcens.yml] up -d
```
To fully run the daemon under Tor, making your node reachable only through a hidden service, set `TORNODE=1` like this:
```
TORNODE=1 docker-compose -p safecoin -f docker-compose.yml [-f docker-compose.safenode.yml] [-f docker-compose.fightcens.yml] build --pull
TORNODE=1 docker-compose -p safecoin -f docker-compose.yml [-f docker-compose.safenode.yml] [-f docker-compose.fightcens.yml] up -d
```

**Warning: file order is important!**

To run multiple instances see [running multiple instances](#Running-multiple-instances).

#### [Configure your SafeNode (optional)](https://github.com/Fair-Exchange/safecoin-docker/tree/master/safenode#configure-the-container)

#### Use safecoin-cli
```
docker-compose -p safecoin exec safecoin safecoin-cli <args>
```

#### Create a wallet backup
```
docker cp safecoin_safecoin-1:/safecoin/.safecoin/wallet.dat .
```

#### Stop the containers
```
docker-compose -p safecoin -f docker-compose.yml [-f docker-compose.fightcens.yml] stop
```

#### Update the containers
Run again setup will update container's image

#### Running multiple instances
To run multiple instanced, you will have to change `-p <name>` and changing daemon's listening port with `SAFEPORT` in order to avoid conflicts with other containers. Example:
```
SAFEPORT=8774 docker-compose -p safecoin2 -f docker-compose.yml [...] up -d
```
will run a new SafeCoin daemon on port 8774.


#### Keep the container up-to-date with systemd service
:warning: THIS IS AN EXPERIMENTAL FEATURE, BE SURE TO HAVE A BACKUP OF YOUR WALLETS AND THE WILL TO FIGHT AGAINST BUGS

You can enable a systemd service that will pull the latest image from our repositories at every boot copying `docker-safecoin.service` on systemd services' folder.
```
mv docker-safecoin.service /etc/systemd/system
systemctl daemon-reload
systemctl enable --now docker-safecoin.service
```

## FAQ
#### I want to run SafeCoin daemon with custom flags.
Open `docker-compose.yml` and add `command: <flags>` in safecoin section.
E.g. if I want to enable debug, I'll add command to my `docker-compose.yml` like that:
```
[...]
  safecoin:
    image: safecoin/safecoin
    command: -debug=1
[...]
```

#### Something went wrong, how can I see logs?
```
docker-compose -p safecoin -f docker-compose.yml [-f docker-compose.fightcens.yml] logs [-f] <service>
```
You can use `--follow` argument to continue streaming the new output from the container’s STDOUT and STDERR.

You can specify a service name (like `safecoin`) to see only logs related to that container

#### I sadly need to debug. How can I spawn a shell into the container?
```
docker-compose -p safecoin exec safecoin bash
```
You will be on a Debian Stable image.

#### I have a problem or I can't find my question on FAQs
Join on [Discord](https://discord.gg/c6hWAkQ) and ask there. Someone will help you for sure! :)
