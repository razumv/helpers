# Install VictoriaMetrics and Grafana by docker-compose
1. Clone project
```
git clone https://github.com/razumv/helpers/
```
2. Enter to directory
```
cd helpers/vm
```
3. Install docker, docker-compose
```wget -O get-docker.sh https://get.docker.com
sudo sh get-docker.sh
sudo apt install -y docker-compose
rm -f get-docker.sh
```
4. Start VictoriaMetrics and Grafana in background
```
docker-compose up -d
```
