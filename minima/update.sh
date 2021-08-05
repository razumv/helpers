#!/bin/bash
sudo tee <<EOF >/dev/null /etc/systemd/journald.conf
Storage=persistent
EOF

sudo systemctl restart systemd-journald

wget https://github.com/minima-global/Minima/raw/master/jar/minima.jar -O $HOME/minima.jar.new
sudo systemctl stop minima
mv $HOME/minima.jar $HOME/minima.jar.bk
mv $HOME/minima.jar.new $HOME/minima.jar
sudo systemctl start minima
echo 'Minima updated successfully'
echo -e '\n\e[44mRun command to see logs: \e[0m\n'
echo 'journalctl -n 100 -f -u minima'
