# SafeNode on Docker
To run a SafeNode on Docker, be sure to use `docker-compose.safenode.yml` when running the containers.

## Configure the container

#### 1. Create a SafeNode Paper Wallet
Go to https://safenodes.org/generate-wallet and create your SafeNode Paper Wallet.

#### 2. Run configuration script
```
docker-compose -p safenode exec safecoin setup-safenode.sh
```
It will ask the SafeKey generated at point [#1](#1-Create-a-SafeNode-Paper-Wallet) and the actual blockchain height (optional).

If the configuration ends fine you should read `SafeNode has been configured. Restart the container.`

#### 3. Restart the container
```
docker-compose -p safenode restart safecoin
```
The container will download ZCash params before running the node, it will take a while. You can check progress with `docker-compose -p safenode logs -f safecoin`.

Wait that the daemon runs, then go to the next step.

#### 4. Test that everything's fine
```
docker-compose -p safenode exec safecoin safecoin-cli getnodeinfo
```
Check that the informations about your node are ok. After a while your node will appear [here](https://safenodes.org/). This is the final confirmation that everything works just fine.

#### 5. Enable node
Get the wallet address with
```
docker-compose -p safenode exec safecoin safecoin-cli listreceivedbyaddress 0 true
```
and send 1 SAFE to the that address, then send at least 10000 SAFE to the collateral address generated at [#1](#1-Create-a-SafeNode-Paper-Wallet).

**Now the node is enabled, you can double-check at https://safenodes.org/ in a few minutes**