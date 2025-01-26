#!/bin/bash
set -e

# Configurações
VERSION="2.3.0p25"                    # Versão do Checkmk
UBUNTU_CODENAME="noble"               # Código do release
OMD_SITE=$(omd sites | awk '{print $1}')  # Detectar site automaticamente
BACKUP_DIR="/var/lib/checkmk/backups"  # Diretório de backups
TIMESTAMP=$(date +%Y%m%d%H%M%S)

# Função para rollback
rollback() {
    echo -e "\n⛔️ Rollback necessário. Revertendo alterações..."
    sudo omd stop "$OMD_SITE" 2>/dev/null || true
    sudo omd rm -f "${OMD_SITE}_temp" 2>/dev/null || true
    sudo dpkg -r check-mk-raw || true
    sudo omd restore "$BACKUP_DIR/${OMD_SITE}_${TIMESTAMP}.tar.gz"
    echo "✅ Rollback completo. Sistema restaurado para o estado anterior."
    exit 1
}

# Verificar se é root
if [ "$EUID" -ne 0 ]; then
    echo "⚠️ Execute como root!"
    exit 1
fi

# Criar diretório de backups
sudo mkdir -p "$BACKUP_DIR"

# 1. Fazer backup da instalação atual
echo "🔵 Criando backup do site $OMD_SITE..."
sudo omd stop "$OMD_SITE"
sudo omd backup "$OMD_SITE" "$BACKUP_DIR/${OMD_SITE}_${TIMESTAMP}.tar.gz"
sudo omd start "$OMD_SITE"

# 2. Instalar nova versão
echo "🔵 Instalando Checkmk $NEW_VERSION..."
wget "https://download.checkmk.com/checkmk/${NEW_VERSION}/check-mk-raw-${NEW_VERSION}_0.${UBUNTU_CODENAME}_amd64.deb" -O /tmp/checkmk_new.deb
sudo apt-get install -f -y

# 3. Criar ambiente temporário para testes
echo "🔵 Configurando ambiente temporário..."
sudo omd cp "$OMD_SITE" "${OMD_SITE}_temp"
sudo omd update --conflict=install "${OMD_SITE}_temp"
sudo omd start "${OMD_SITE}_temp"

# 4. Informações para teste
IP=$(hostname -I | awk '{print $1}')
echo -e "\n🔵 Ambiente temporário pronto para testes:"
echo -e "🌐 URL: http://${IP}/${OMD_SITE}_temp/"
echo -e "🔑 Credenciais: admin / admin"
echo -e "\n⚠️ Teste o sistema antes de continuar!"

# 5. Confirmação do usuário
read -p "⏳ Os testes foram bem sucedidos? (s/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    rollback
fi

# 6. Atualização definitiva
echo "🔵 Aplicando atualização no site principal..."
sudo omd stop "$OMD_SITE"
sudo omd update --conflict=install "$OMD_SITE"
sudo omd start "$OMD_SITE"

# 7. Limpeza
sudo omd rm -f "${OMD_SITE}_temp"
rm /tmp/checkmk_new.deb

echo -e "\n✅ Atualização concluída com sucesso!"
echo -e "🌐 URL Principal: http://${IP}/${OMD_SITE}/"
