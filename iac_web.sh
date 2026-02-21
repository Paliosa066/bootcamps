#!/bin/bash

# Atualização do sistema
apt-get update
apt-get upgrade -y

# Instalação do Apache e Unzip
apt-get install apache2 -y
apt-get install unzip -y

# Download da aplicação no diretório temporário
cd /tmp
wget https://github.com/denilsonbonatti/linux-site-dio/archive/refs/heads/main.zip
unzip main.zip

# Mover arquivos para o diretório padrão do Apache
cd linux-site-dio-main
cp -R * /var/www/html/
