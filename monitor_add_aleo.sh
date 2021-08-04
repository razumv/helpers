#!/bin/bash

#Install telegraf
cat <<EOF | sudo tee /etc/apt/sources.list.d/influxdata.list
deb https://repos.influxdata.com/ubuntu bionic stable
EOF

sudo curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -

sudo apt-get update
sudo apt-get -y install telegraf jq bc

# make the telegraf user sudo and adm to be able to execute scripts as sol user
sudo adduser telegraf sudo
sudo adduser telegraf adm
sudo -- bash -c 'echo "telegraf ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers'

sudo cp /etc/telegraf/telegraf.conf /etc/telegraf/telegraf.conf.orig
sudo rm -rf /etc/telegraf/telegraf.conf

#Configure
cat <<EOF | sudo tee /etc/telegraf/telegraf.conf
[agent]
  hostname = "$HOSTNAME"
  owner = "$OWNER"
  flush_interval = "30s"
  interval = "30s"

# Input Plugins
[[inputs.cpu]]
    percpu = true
    totalcpu = true
    collect_cpu_time = false
    report_active = false
[[inputs.disk]]
    ignore_fs = ["devtmpfs", "devfs"]
[[inputs.io]]
[[inputs.mem]]
[[inputs.net]]
[[inputs.system]]
[[inputs.swap]]
[[inputs.netstat]]
[[inputs.processes]]
[[inputs.kernel]]
[[inputs.diskio]]

# Output Plugin InfluxDB
[[outputs.influxdb]]
  database = "telegraf"
  urls = [ "http://vm.razumv.tech:8080/write" ] # keep this to send all your metrics to the community dashboard otherwise use http://yourownmonitoringnode:8086
  username = "doubletop" # keep both values if you use the community dashboard
  password = "doubletop"

[[inputs.exec]]
#  ## override the default metric name of "exec"
  name_override = "connections"
  commands = ["sudo su -c $HOME/scipts/getconnection.sh  -s /bin/bash $USER"]
  interval = "1m"
  timeout = "1m"
  data_format = "value"
  data_type = "integer" # required

 [[inputs.exec]]
  name_override = "blockheight"
  commands = ["sudo su -c $HOME/scipts/getheight.sh   -s /bin/bash $USER"]
  interval = "1m"
  timeout = "1m"
  data_format = "value"
  data_type = "integer" # required

 [[inputs.exec]]
  name_override = "minedcounter"
  commands = ["sudo su -c $HOME/scipts/getmindeblocks.sh   -s /bin/bash $USER"]
  interval = "1m"
  timeout = "1m"
  data_format = "value"
  data_type = "integer" # required
  
 [[inputs.exec]]
  name_override = "getversion"
  commands = ["sudo su -c $HOME/scipts/getversion.sh   -s /bin/bash $USER"]
  interval = "1m"
  timeout = "1m"
  data_format = "value"
  data_type = "string" # required
EOF

mkdir $HOME/aleoscipt

sudo tee <<EOF >/dev/null $HOME/aleoscipt/getconnection.sh
#!/bin/bash
curl -s --data-binary '{"jsonrpc": "2.0", "id":"documentation", "method": "getconnectioncount", "params": [] }' -H 'content-type: application/json' http://localhost:3030/ | jq '.result?'
EOF

sudo tee <<EOF >/dev/null $HOME/aleoscipt/getheight.sh
#!/bin/bash
curl -s --data-binary '{"jsonrpc": "2.0", "id":"documentation", "method": "getblockcount", "params": [] }' -H 'content-type: application/json' http://localhost:3030/ | jq '.result?';
EOF

sudo tee <<EOF >/dev/null $HOME/aleoscipt/getmindeblocks.sh
#!/bin/bash
curl -s --data-binary '{"jsonrpc": "2.0", "id":"documentation", "method": "getnodestats", "params": [] }' -H 'content-type: application/json' http://localhost:3030/ | jq '.[].misc?.blocks_mined?'        
EOF

sudo tee <<EOF >/dev/null $HOME/aleoscipt/getversion.sh
#!/bin/bash
/root/.cargo/bin/snarkos --help | grep -o '[0-9]*\.[0-9]*\.[0-9]*'        
EOF

sudo systemctl enable telegraf
sudo systemctl restart telegraf

 
