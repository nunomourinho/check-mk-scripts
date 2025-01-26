#!/bin/bash

# Verificar parâmetro
if [ $# -eq 0 ]; then
    echo "Usage: $0 <OMD_SITE>"
    echo "Escolha um dos sites:"
    omd sites
    exit 1
fi

# Configurações
OMD_SITE="$1"
BACKUP_DIR="/var/lib/checkmk/backups"

# Verificar se é root
if [ "$EUID" -ne 0 ]; then
    echo "⚠️ Execute como root!"
    exit 1
fi

# Configurar tratamento de erros
set -eE
trap 'rollback' ERR

# Função de rollback
rollback() {
    echo -e "\n⛔️ Erro durante a restauração. Revertendo..."
    if [ -n "$PRE_RESTORE_BACKUP" ] && [ -f "$PRE_RESTORE_BACKUP" ]; then
        echo "Restaurando backup pré-restauração..."
        sudo omd stop "$OMD_SITE" 2>/dev/null || true
        sudo omd rm "$OMD_SITE" 2>/dev/null || true
        sudo omd restore "$PRE_RESTORE_BACKUP"
        sudo omd start "$OMD_SITE"
        echo "✅ Rollback concluído. Site restaurado ao estado anterior."
    else
        echo "⚠️ Nenhum backup pré-restauração encontrado para rollback."
    fi
    exit 1
}

# Verificar se o site existe
if omd sites | grep -qw "$OMD_SITE"; then
    SITE_EXISTS=1
else
    SITE_EXISTS=0
fi

# Criar backup pré-restauração se o site existir
TIMESTAMP=$(date +%Y%m%d%H%M%S)
PRE_RESTORE_BACKUP=""

if [ $SITE_EXISTS -eq 1 ]; then
    echo "Criando backup pré-restauração do site $OMD_SITE..."
    sudo mkdir -p "$BACKUP_DIR"
    PRE_RESTORE_BACKUP="$BACKUP_DIR/${OMD_SITE}_${TIMESTAMP}_pre_restore.tar.gz"
    sudo omd backup "$OMD_SITE" "$PRE_RESTORE_BACKUP"
    echo "✅ Backup pré-restauração criado: $(basename "$PRE_RESTORE_BACKUP")"
fi

# Listar e formatar cópias de segurança
echo -e "\nProcurando cópias de segurança para $OMD_SITE em $BACKUP_DIR..."
backups=()
while IFS= read -r -d $'\0' backup; do
    backups+=("$backup")
done < <(find "$BACKUP_DIR" -name "${OMD_SITE}_*.tar.gz" -print0 | sort -zr)

if [ ${#backups[@]} -eq 0 ]; then
    echo "⛔️ Nenhuma cópia de segurança encontrada para $OMD_SITE."
    exit 1
fi

# Mostrar backups com detalhes
echo -e "\nCópias de segurança disponíveis:"
for i in "${!backups[@]}"; do
    backup_path="${backups[$i]}"
    filename=$(basename "$backup_path")
    
    # Extrair timestamp e tipo
    if [[ "$filename" == *"_pre_restore"* ]]; then
        tipo="🛡️ Preventivo"
        timestamp=$(echo "$filename" | grep -oP '\d{14}')
    else
        tipo="🔄 Normal"
        timestamp=$(echo "$filename" | grep -oP '\d{14}')
    fi
    
    # Converter para data legível
    data_formatada=$(date -d "${timestamp:0:8} ${timestamp:8:4}" +"%d/%m/%Y %H:%M")
    
    # Tamanho do arquivo
    size=$(du -h "$backup_path" | cut -f1)
    
    printf "%2d. [%s] %s | %s | Tamanho: %s\n" \
        $((i+1)) "$tipo" "$data_formatada" "$filename" "$size"
done

# Seleção do utilizador
read -p $'\nEscolha o número da cópia para restaurar: ' num

# Validar escolha
if [[ ! "$num" =~ ^[0-9]+$ ]] || [ "$num" -lt 1 ] || [ "$num" -gt ${#backups[@]} ]; then
    echo "⛔️ Escolha inválida."
    exit 1
fi

selected_backup="${backups[$((num-1))]}"

# Remover site existente (se aplicável)
if [ $SITE_EXISTS -eq 1 ]; then
    echo -e "\nParando e removendo site existente..."
    sudo omd stop "$OMD_SITE"
    sudo omd rm "$OMD_SITE"
fi

# Restaurar cópia selecionada
echo -e "\nRestaurando: $(basename "$selected_backup")..."
sudo omd restore "$selected_backup"

# Iniciar site
echo -e "\nIniciando site $OMD_SITE..."
sudo omd start "$OMD_SITE"

echo -e "\n✅ Restauração concluída com sucesso!"
echo -e "🌐 URL: http://$(hostname -I | awk '{print $1}')/$OMD_SITE"
