#!/bin/bash
if [ ! $OWNER ]; then
	read -p "Введите свой ник, например телеграмм(без @): " OWNER
fi
echo 'Владелец: ' $OWNER
sleep 1
echo 'export OWNER='$OWNER >> $HOME/.profile
if [ ! $HOSTNAME ]; then
	read -p "Введите название своего сервера: " HOSTNAME
fi
echo 'Название вашего сервера: ' $HOSTNAME
sleep 1
echo 'export HOSTNAME='$HOSTNAME >> $HOME/.profile

systemctl stop prometheus && systemctl disable prometheus

# sudo useradd --no-create-home --shell /usr/sbin/nologin prometheus
sudo mkdir /etc/prometheus
# sudo mkdir /var/lib/prometheus
# sudo chown -R prometheus:prometheus /etc/prometheus
# sudo chown -R prometheus:prometheus /var/lib/prometheus
# wget https://github.com/prometheus/prometheus/releases/download/v2.25.2/prometheus-2.25.2.linux-amd64.tar.gz
# tar xfz prometheus-*.tar.gz
# cd prometheus-2.25.2.linux-amd64
# sudo cp ./prometheus /usr/local/bin/
# sudo cp ./promtool /usr/local/bin/
# sudo chown prometheus:prometheus /usr/local/bin/prometheus
# sudo chown prometheus:prometheus /usr/local/bin/promtool
# sudo cp -r ./consoles /etc/prometheus
# sudo cp -r ./console_libraries /etc/prometheus
# sudo chown -R prometheus:prometheus /etc/prometheus/consoles
# sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
# cd .. && rm -rf prometheus*
apt install wget -y 
wget https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/v1.63.0/vmutils-amd64-v1.63.0.tar.gz
tar xvf vmutils-amd64-v1.63.0.tar.gz
rm -rf vmutils-amd64-v1.63.0.tar.gz

sudo tee <<EOF >/dev/null /etc/prometheus/prometheus.yml
global:
  scrape_interval: 30s
  evaluation_interval: 30s
  external_labels:
    owner: $OWNER
    hostname: $HOSTNAME
scrape_configs:    
  - job_name: "node_exporter"
    scrape_interval: 30s
    static_configs:
      - targets: ["localhost:9100"]
    relabel_configs:
      - source_labels: [__address__]
        regex: '.*'
        target_label: instance
        replacement: '$HOSTNAME'         
EOF

# sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml

sudo tee <<EOF >/dev/null /etc/systemd/system/vmagent.service
[Unit]
  Description=vmagent Monitoring
  Wants=network-online.target
  After=network-online.target
[Service]
  User=$USER
  Type=simple
  ExecStart=$HOME/vmagent-prod \
  -promscrape.config=/etc/prometheus/prometheus.yml \
  -remoteWrite.url=http://doubletop:doubletop@vm.razumv.tech:8080/api/v1/write
  ExecReload=/bin/kill -HUP $MAINPID
[Install]
  WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload && systemctl enable vmagent && systemctl restart vmagent

wget https://github.com/prometheus/node_exporter/releases/download/v1.1.2/node_exporter-1.1.2.linux-amd64.tar.gz
tar xvf node_exporter-1.1.2.linux-amd64.tar.gz
cp node_exporter-1.1.2.linux-amd64/node_exporter /usr/local/bin
sudo chown prometheus:prometheus /usr/local/bin/node_exporter

sudo tee <<EOF >/dev/null /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target
[Service]
User=$USER
Type=simple
ExecStart=/usr/local/bin/node_exporter --web.listen-address=":9100"
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload && systemctl enable node_exporter && systemctl restart node_exporter

echo "Monitoring Installed"
