```
wget -O nibi.sh https://raw.githubusercontent.com/Megumiiiiii/nibiru/main/nibi.sh?token=GHSAT0AAAAAAB67D4DLXAX4RCCDJ5JGHIY2Y743S7Q; chmod +x nibi.sh; ./nibi.sh
```


Snapshot from kj89

```
curl -L https://snapshots.kjnodes.com/nibiru-testnet/snapshot_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.nibid
[[ -f $HOME/.nibid/data/upgrade-info.json ]] && cp $HOME/.nibid/data/upgrade-info.json $HOME/.nibid/cosmovisor/genesis/upgrade-info.json

sudo systemctl restart nibid && sudo journalctl -u nibid -f --no-hostname -o cat
```
