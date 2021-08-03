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

sudo useradd --no-create-home --shell /usr/sbin/nologin prometheus
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown -R prometheus:prometheus /var/lib/prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.25.2/prometheus-2.25.2.linux-amd64.tar.gz
tar xfz prometheus-*.tar.gz
cd prometheus-2.25.2.linux-amd64
sudo cp ./prometheus /usr/local/bin/
sudo cp ./promtool /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/prometheus
sudo chown prometheus:prometheus /usr/local/bin/promtool
sudo cp -r ./consoles /etc/prometheus
sudo cp -r ./console_libraries /etc/prometheus
sudo chown -R prometheus:prometheus /etc/prometheus/consoles
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries
cd .. && rm -rf prometheus*

sudo tee <<EOF >/dev/null /etc/prometheus/prometheus.yml
global:
  scrape_interval: 30s
  evaluation_interval: 30s
  external_labels:
    owner: $OWNER
    hostname: $HOSTNAME
scrape_configs:
  - job_name: "prometheus"
    scrape_interval: 30s
    static_configs:
      - targets: ["localhost:39090"]
    relabel_configs:
      - source_labels: [__address__]
        regex: '.*'
        target_label: instance
        replacement: '$HOSTNAME'      
  - job_name: "node_exporter"
    scrape_interval: 30s
    static_configs:
      - targets: ["localhost:39100"]
    relabel_configs:
      - source_labels: [__address__]
        regex: '.*'
        target_label: instance
        replacement: '$HOSTNAME'      
remote_write:
  - url: http://doubletop:doubletop@vm.razumv.tech:8080/api/v1/write      
EOF

sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml

sudo tee <<EOF >/dev/null /etc/systemd/system/prometheus.service
[Unit]
  Description=Prometheus Monitoring
  Wants=network-online.target
  After=network-online.target
[Service]
  User=prometheus
  Group=prometheus
  Type=simple
  ExecStart=/usr/local/bin/prometheus \
  --config.file /etc/prometheus/prometheus.yml \
  --storage.tsdb.path /var/lib/prometheus/ \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --storage.tsdb.retention.time=30m \
  --web.listen-address="0.0.0.0:39090"
  ExecReload=/bin/kill -HUP $MAINPID
[Install]
  WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload && systemctl enable prometheus && systemctl start prometheus
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
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/node_exporter --web.listen-address=":39100"
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload && systemctl enable node_exporter && systemctl start node_exporter

echo "Monitoring Installed"
