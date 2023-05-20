## SAUCE GUIDE
[KJ](https://services.kjnodes.com/home/testnet/nibiru/installation)

### Set Name
```
MONIKER="Nama_Validator"
```

### Install + Update keperluan
```
sudo apt -q update
sudo apt -qy install curl git jq lz4 build-essential
sudo apt -qy upgrade
```

### Download + Build
- Clone Projek
```
cd $HOME
rm -rf nibiru
git clone https://github.com/NibiruChain/nibiru.git
cd nibiru
git checkout v0.19.2
```

- Build
```
make build
```

- Prepare untuk cosmovisor
```
mkdir -p $HOME/.nibid/cosmovisor/genesis/bin
mv build/nibid $HOME/.nibid/cosmovisor/genesis/bin/
rm -rf build
```

- Buat applications symlink
```
sudo ln -s $HOME/.nibid/cosmovisor/genesis $HOME/.nibid/cosmovisor/current -f
sudo ln -s $HOME/.nibid/cosmovisor/current/bin/nibid /usr/local/bin/nibid -f
```

### Install Cosmovisor + Create service
- Download Cosmovisor
```
go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@v1.4.0
```

- Create Service
```
sudo tee /etc/systemd/system/nibid.service > /dev/null << EOF
[Unit]
Description=nibiru-testnet node service
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.nibid"
Environment="DAEMON_NAME=nibid"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.nibid/cosmovisor/current/bin"

[Install]
WantedBy=multi-user.target
EOF
```

- Reload
```
sudo systemctl daemon-reload
sudo systemctl enable nibid
```

### Set Node
- Set Config
```
nibid config chain-id nibiru-itn-1
nibid config keyring-backend test
nibid config node tcp://localhost:13957
```

- Init
```
nibid init $MONIKER --chain-id nibiru-itn-1
```

- Download Genesis + Addrbook
```
curl -Ls https://snapshots.kjnodes.com/nibiru-testnet/genesis.json > $HOME/.nibid/config/genesis.json
curl -Ls https://snapshots.kjnodes.com/nibiru-testnet/addrbook.json > $HOME/.nibid/config/addrbook.json
```


- Tambahkan seeds
```
sed -i -e "s|^seeds *=.*|seeds = \"3f472746f46493309650e5a033076689996c8881@nibiru-testnet.rpc.kjnodes.com:13959\"|" $HOME/.nibid/config/config.toml
```

- Set gas
```
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.025unibi\"|" $HOME/.nibid/config/app.toml
```
- Set prunning
```
sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
  $HOME/.nibid/config/app.toml
```

- Set port
```
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:13958\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:13957\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:13960\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:13956\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":13966\"%" $HOME/.nibid/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:13917\"%; s%^address = \":8080\"%address = \":13980\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:13990\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:13991\"%; s%:8545%:13945%; s%:8546%:13946%; s%:6065%:13965%" $HOME/.nibid/config/app.toml
```

### Download snapshot
```
curl -L https://snapshots.kjnodes.com/nibiru-testnet/snapshot_latest.tar.lz4 | tar -Ilz4 -xf - -C $HOME/.nibid
[[ -f $HOME/.nibid/data/upgrade-info.json ]] && cp $HOME/.nibid/data/upgrade-info.json $HOME/.nibid/cosmovisor/genesis/upgrade-info.json
```

### Start
```
sudo systemctl start nibid && sudo journalctl -u nibid -f --no-hostname -o cat
```

## Useful command
[Command](https://services.kjnodes.com/home/testnet/nibiru/useful-commands)


<div id="header" align="center">
  <img src="https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExMzNmZTIxZmE3ZmY3MzRiMDcwNDJhYTQ5ZmNlY2YxMWE1OWIyYmVkNSZlcD12MV9pbnRlcm5hbF9naWZzX2dpZklkJmN0PWc/mVBlqOD4ra9jQiI3cC/giphy.gif" height="125" width="420"/>
</div>
