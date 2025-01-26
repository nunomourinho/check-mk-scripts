#!/bin/bash

# Verificar parâmetro
if [ $# -eq 0 ]; then
    echo "Usage: $0 <OMD_SITE>"
    echo "Sites disponíveis:"
    omd sites
    exit 1
fi

# Configurações
OMD_SITE="$1"
BACKUP_DIR="/var/lib/checkmk/backups"
TIMESTAMP=$(date +%Y%m%d%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/${OMD_SITE}_${TIMESTAMP}.tar.gz"

# Verificar root
if [ "$(id -u)" -ne 0 ]; then
    echo "⚠️ Execute como root!"
    exit 1
fi

# Verificar se o site existe
if ! omd sites | grep -qw "$OMD_SITE"; then
    echo "⛔️ Site não encontrado! Sites disponíveis:"
    omd sites
    exit 1
fi

# Criar diretório de backups
mkdir -p "$BACKUP_DIR"

# Executar backup
echo "▶️ Iniciando backup de $OMD_SITE..."
if omd backup "$OMD_SITE" "$BACKUP_FILE"; then
    echo -e "\n✅ Backup concluído com sucesso!"
    echo "📍 Local: $BACKUP_FILE"
    echo "📦 Tamanho: $(du -h "$BACKUP_FILE" | cut -f1)"
else
    echo -e "\n⛔️ Falha no backup! Verifique:"
    echo "- Espaço em disco disponível"
    echo "- Permissões do diretório"
    exit 1
fi
