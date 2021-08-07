```
git clone https://github.com/razumv/helpers/
cd helpers/vm
wget -O get-docker.sh https://get.docker.com 
sudo sh get-docker.sh
sudo apt install -y docker-compose
rm -f get-docker.sh
docker-compose up -d
