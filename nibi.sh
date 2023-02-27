#!/bin/bash
echo -e "\033[0;35m"
echo " ____*##########*                              ";
echo " __*##############                             ";
echo " __################                            ";
echo " _##################_________*####*            ";
echo " __##################_____*##########          ";
echo " __##################___*#############         ";
echo " ___#################*_###############*        ";
echo " ____#################################*        ";
echo " ______###############################         ";
echo " _______#############################          ";
echo " ________=##########################           ";
echo " __________########################            ";
echo " ___________*#####################             ";
echo " ____________*##################               ";
echo " _____________*###############                 ";
echo " _______________#############                  ";
echo " ________________##########                    ";
echo " ________________=#######*                     ";
echo " _________________######                       ";
echo " __________________####                        ";
echo " __________________###                         ";
echo " ___________________#                          ";
echo -e "\e[0m"

sleep 2

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
NIBIRU_PORT=39
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export NIBIRU_CHAIN_ID=nibiru-itn-1" >> $HOME/.bash_profile
echo "export NIBIRU_PORT=${NIBIRU_PORT}" >> $HOME/.bash_profile
source $HOME/.bash_profile

echo '================================================='
echo -e "Your node name: \e[1m\e[32m$NODENAME\e[0m"
echo -e "Your wallet name: \e[1m\e[32m$WALLET\e[0m"
echo -e "Your chain name: \e[1m\e[32m$NIBIRU_CHAIN_ID\e[0m"
echo -e "Your port: \e[1m\e[32m$NIBIRU_PORT\e[0m"
echo '================================================='
sleep 2

echo -e "\e[1m\e[32m1. Update bentar... \e[0m" && sleep 1
# update
sudo apt update && sudo apt upgrade -y

echo -e "\e[1m\e[32m2. Installing alat & bahan... \e[0m" && sleep 1
# packages
sudo apt install curl build-essential git wget jq make gcc tmux screen unzip lz4 chrony -y

# install go
if ! [ -x "$(command -v go)" ]; then
ver="1.19" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile
fi

echo -e "\e[1m\e[32m3. Downloading and building binaries... \e[0m" && sleep 1
# download binary
cd $HOME && rm -rf nibiru
git clone https://github.com/NibiruChain/nibiru.git
cd nibiru
git checkout v0.19.2
make install

# config
nibid config chain-id nibiru-itn-1
nibid config keyring-backend test
nibid config node tcp://localhost:39657

# init
nibid init $NODENAME --chain-id nibiru-itn-1

# download genesis and addrbook
curl -Ls https://snapshots.kjnodes.com/nibiru-testnet/genesis.json > $HOME/.nibid/config/genesis.json
curl -Ls https://snapshots.kjnodes.com/nibiru-testnet/addrbook.json > $HOME/.nibid/config/addrbook.json

# set peers and seeds
sed -i -e "s|^seeds *=.*|seeds = \"3f472746f46493309650e5a033076689996c8881@nibiru-testnet.rpc.kjnodes.com:39659\"|" $HOME/.nibid/config/config.toml
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.025unibi\"|" $HOME/.nibid/config/app.toml


# set custom ports
sed -i -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:39658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:39657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:39060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:39656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":39660\"%" $HOME/.nibid/config/config.toml
sed -i -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:39317\"%; s%^address = \":8080\"%address = \":39080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:39090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:39091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:39545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:39546\"%" $HOME/.nibid/config/app.toml

# config pruning
sed -i \
  -e 's|^pruning *=.*|pruning = "custom"|' \
  -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|' \
  -e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|' \
  -e 's|^pruning-interval *=.*|pruning-interval = "19"|' \
  $HOME/.nibid/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.nibid/config/config.toml

# reset
nibid tendermint unsafe-reset-all --home $HOME/.nibid

echo -e "\e[1m\e[32m4. Starting service... \e[0m" && sleep 1
# create service
sudo tee /etc/systemd/system/nibid.service > /dev/null <<EOF
[Unit]
Description=nibiru
After=network-online.target

[Service]
User=$USER
ExecStart=$(which nibid) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# start service
sudo systemctl daemon-reload
sudo systemctl enable nibid
sudo systemctl restart nibid

echo '=============== SUDAH ==================='
echo -e 'Cek logs: \e[1m\e[32mjournalctl -u nibid -f -o cat\e[0m'
echo -e "Cek sync status: \e[1m\e[32mcurl -s localhost:${NIBIRU_PORT}657/status | jq .result.sync_info\e[0m"
