# Tor for SafeCoin
### Use a OBFS4 bridge to circumvent censorship.
#### 1. Finding Public Bridges
https://bridges.torproject.org/bridges

If you can not reach the URL, send an email (from a [Riseup](https://riseup.net/) or [Gmail](https://mail.google.com/) account only) to bridges@torproject.org with "get transport obfs4" in the message body.

#### 2. Enable Bridge Support And Add Bridges
Copy the following lines to torrc:
```
UseBridges 1
ClientTransportPlugin obfs4 exec /usr/bin/obfs4proxy managed
```
Then, at step 1. you should have got something like:
```
obfs4 60.16.182.53:9001 cc8ca10a63aae8176a52ca5129ce816d011523f5
obfs4 87.237.118.139:444 0ed110497858f784dfd32d448dc8c0b93fee20ca
obfs4 60.63.97.221:443 daa5e435819275f88d695cb7fce73ed986878cf3
```
Add `bridge` at the beginning of each line:
```
bridge obfs4 60.16.182.53:9001 cc8ca10a63aae8176a52ca5129ce816d011523f5
bridge obfs4 87.237.118.139:444 0ed110497858f784dfd32d448dc8c0b93fee20ca
bridge obfs4 60.63.97.221:443 daa5e435819275f88d695cb7fce73ed986878cf3
```
copy-paste the result to `torrc`.

**Remind that bridges could go offline. When this happens, you will have to get new bridges.**