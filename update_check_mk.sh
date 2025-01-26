#!/bin/bash
set -e

# Configurações
VERSION="2.3.0p25"                    # Versão do Checkmk
UBUNTU_CODENAME="noble"               # Código do release
OMD_SITE=$(omd sites | awk 'NR==1{print $1}')  # Detectar primeiro site ativo
BACKUP_DIR="/var/lib/checkmk/backups"  # Diretório de backups
TIMESTAMP=$(date +%Y%m%d%H%M%S)

# Função para rollback
rollback() {
    echo -e "\n⛔️ Rollback necessário. Revertendo alterações..."
    sudo omd stop "$OMD_SITE" 2>/dev/null || true
    sudo omd rm -f "${OMD_SITE}_temp" 2>/dev/null || true
    sudo dpkg --purge check-mk-raw 2>/dev/null || true
    sudo omd restore "$BACKUP_DIR/${OMD_SITE}_${TIMESTAMP}.tar.gz"
    echo "✅ Rollback completo. Sistema restaurado para o estado anterior."
    exit 1
}

# Verificar se é root
if [ "$EUID" -ne 0 ]; then
    echo "⚠️ Execute como root!"
    exit 1
fi

# 1. Verificar versão atual
CURRENT_VERSION=$(omd version)
echo "🔵 Versão atual: $CURRENT_VERSION"

# 2. Fazer backup da instalação atual
sudo mkdir -p "$BACKUP_DIR"
echo "🔵 Criando backup do site $OMD_SITE..."
sudo omd stop "$OMD_SITE"
sudo omd backup "$OMD_SITE" "$BACKUP_DIR/${OMD_SITE}_${TIMESTAMP}.tar.gz"

# 3. Instalar nova versão
echo "🔵 Baixando Checkmk ${VERSION}..."
wget "https://download.checkmk.com/checkmk/${VERSION}/check-mk-raw-${VERSION}_0.${UBUNTU_CODENAME}_amd64.deb" -O /tmp/checkmk_new.deb

echo "🔵 Instalando nova versão..."
sudo dpkg -i /tmp/checkmk_new.deb || {
    echo "⚠️ Erro na instalação do pacote. Tentando corrigir dependências..."
    sudo apt-get install -f -y
}

# 4. Validar instalação
INSTALLED_VERSION=$(dpkg -l | grep '^ii  check-mk-raw' | awk '{print $2}' | sed 's/check-mk-raw-//')
if [ "$INSTALLED_VERSION" != "${VERSION}" ]; then
    echo "⛔️ Versão instalada ($INSTALLED_VERSION) não corresponde à esperada ($VERSION)"
    rollback
fi

# 5. Ambiente temporário para testes
echo "🔵 Configurando ambiente temporário..."
sudo omd cp "$OMD_SITE" "${OMD_SITE}_temp"
sudo omd update --conflict=install "${OMD_SITE}_temp"
sudo omd start "${OMD_SITE}_temp"

# 6. Informações para teste
IP=$(hostname -I | awk '{print $1}')
echo -e "\n🔵 Ambiente temporário pronto para testes:"
echo -e "🌐 URL: http://${IP}/${OMD_SITE}_temp/"
echo -e "🔑 Credenciais: As actuais"
echo -e "\n⚠️ Teste o sistema antes de continuar!"

# 7. Confirmação do usuário
read -p "⏳ Os testes foram bem sucedidos? (s/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    rollback
fi

# 8. Atualização definitiva
echo "🔵 Aplicando atualização no site principal..."
sudo omd stop "$OMD_SITE"
sudo omd update --conflict=install "$OMD_SITE"
sudo omd start "$OMD_SITE"

# 9. Limpeza
sudo omd rm -f "${OMD_SITE}_temp"
rm /tmp/checkmk_new.deb

echo -e "\n✅ Atualização concluída com sucesso!"
echo -e "🌐 URL Principal: http://${IP}/${OMD_SITE}/"
echo -e "🔄 Nova versão: $(omd version)"
