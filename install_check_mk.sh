#!/bin/bash

# Configurações
VERSION="2.2.0p38"                    # Versão do Checkmk
UBUNTU_CODENAME="noble"               # Código do release
PACKAGE_NAME="check-mk-raw-${VERSION}_0.${UBUNTU_CODENAME}_amd64.deb"
DOWNLOAD_URL="https://download.checkmk.com/checkmk/${VERSION}/${PACKAGE_NAME}"

# Verificar parâmetro obrigatório
if [ $# -eq 0 ]; then
    echo "Erro: O nome do site OMD deve ser informado como parâmetro."
    echo "Uso: $0 <OMD_SITE>"
    exit 1
fi

OMD_SITE="$1"                         # Nome do site OMD (parâmetro obrigatório)

# Atualizar sistema
sudo apt-get update
sudo apt-get upgrade -y

# Instalar dependências
sudo apt-get install -y wget apache2

# Baixar pacote Checkmk
wget $DOWNLOAD_URL -O /tmp/checkmk.deb

# Instalar o pacote
sudo dpkg -i /tmp/checkmk.deb

# Resolver dependências faltantes
sudo apt-get install -f -y

# Habilitar módulos do Apache
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo systemctl restart apache2

# Configurar firewall (se habilitado)
sudo ufw allow http
sudo ufw reload

# Criar site com nome configurável
sudo omd create "$OMD_SITE"

# Iniciar o site
sudo omd start "$OMD_SITE"

# Gerar saída das informações de acesso
echo "-----------------------------------------------------------"
echo " Checkmk instalado com sucesso!"
echo "-----------------------------------------------------------"
echo " URL de acesso: http://$(hostname -I | awk '{print $1}')/$OMD_SITE/"
echo "-----------------------------------------------------------"
