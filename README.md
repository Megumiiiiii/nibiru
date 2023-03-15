```
wget -O nibi.sh https://raw.githubusercontent.com/Megumiiiiii/nibiru/main/nibi.sh; chmod +x nibi.sh; ./nibi.sh
```


Snapshot from kj89

```yaml
sudo systemctl stop nibid
cp $HOME/.nibid/data/priv_validator_state.json $HOME/.nibid/priv_validator_state.json.backup
rm -rf $HOME/.nibid/data
```

```py
curl -L https://snapshots.kjnodes.com/nibiru-testnet/snapshot_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.nibid
mv $HOME/.nibid/priv_validator_state.json.backup $HOME/.nibid/data/priv_validator_state.json
```

```yaml
sudo systemctl restart nibid && sudo journalctl -u nibid -f --no-hostname -o cat
```


### List Command

[Command](https://services.kjnodes.com/home/testnet/nibiru/useful-commands)
