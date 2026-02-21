#!/bin/bash

echo "Iniciando a criação da infraestrutura..."

echo "------------------------------------------"
echo "Criando diretórios..."
mkdir /publico
mkdir /adm
mkdir /ven
mkdir /sec

echo "------------------------------------------"
echo "Criando grupos de usuários..."
groupadd GRP_ADM
groupadd GRP_VEN
groupadd GRP_SEC

echo "------------------------------------------"
echo "Criando usuários e adicionando aos grupos..."
# Usuários do setor ADM
useradd carlos -m -s /bin/bash -p $(openssl passwd -1 senha123) -G GRP_ADM
useradd maria -m -s /bin/bash -p $(openssl passwd -1 senha123) -G GRP_ADM
useradd joao -m -s /bin/bash -p $(openssl passwd -1 senha123) -G GRP_ADM

# Usuários do setor VEN
useradd debora -m -s /bin/bash -p $(openssl passwd -1 senha123) -G GRP_VEN
useradd sebastiana -m -s /bin/bash -p $(openssl passwd -1 senha123) -G GRP_VEN
useradd roberto -m -s /bin/bash -p $(openssl passwd -1 senha123) -G GRP_VEN

# Usuários do setor SEC
useradd josefina -m -s /bin/bash -p $(openssl passwd -1 senha123) -G GRP_SEC
useradd amanda -m -s /bin/bash -p $(openssl passwd -1 senha123) -G GRP_SEC
useradd rogerio -m -s /bin/bash -p $(openssl passwd -1 senha123) -G GRP_SEC

echo "------------------------------------------"
echo "Especificando permissões dos diretórios..."

# Define o dono como root e os grupos correspondentes
chown root:GRP_ADM /adm
chown root:GRP_VEN /ven
chown root:GRP_SEC /sec

# Permissões: Dono total (7), Grupo total (7), Outros nada (0)
chmod 770 /adm
chmod 770 /ven
chmod 770 /sec

# Público: Todos podem ler, escrever e executar
chmod 777 /publico

echo "------------------------------------------"
echo "Infraestrutura criada com sucesso!"
