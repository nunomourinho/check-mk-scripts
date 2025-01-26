#!/bin/bash

# Verificar parâmetro
if [ $# -eq 0 ]; then
    echo "Usage: $0 <OMD_SITE>"
    echo "Escolha um dos sites:"
    omd sites
    exit 1
fi

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
    PRE_RESTORE_BACKUP="$BACKUP_DIR/${OMD_SITE}_${TIMESTAMP}_pre_restore.tar.gz"
    sudo omd backup "$OMD_SITE" "$PRE_RESTORE_BACKUP"
    echo "✅ Backup pré-restauração criado: $PRE_RESTORE_BACKUP"
fi

# Listar cópias de segurança disponíveis (excluindo pré-restauração)
echo "Procurando cópias de segurança para $OMD_SITE em $BACKUP_DIR..."
backups=()
for backup in "$BACKUP_DIR/${OMD_SITE}_"*.tar.gz; do
    if [[ "$backup" != *"_pre_restore"* ]]; then
        backups+=("$backup")
    fi
done

if [ ${#backups[@]} -eq 0 ]; then
    echo "⛔️ Nenhuma cópia de segurança encontrada para $OMD_SITE."
    exit 1
fi

# Ordenar backups do mais recente para o mais antigo
IFS=$'\n' sorted_backups=($(sort -r <<<"${backups[*]}"))
unset IFS
backups=("${sorted_backups[@]}")

# Mostrar opções ao utilizador
echo -e "\nCópias de segurança disponíveis:"
for i in "${!backups[@]}"; do
    echo "$((i+1)). ${backups[$i]##*/}"  # Mostra apenas o nome do arquivo
done

# Solicitar escolha do utilizador
read -p $'\nEscolha o número da cópia para restaurar: ' num

# Validar escolha
if [[ ! "$num" =~ ^[0-9]+$ ]] || [ "$num" -lt 1 ] || [ "$num" -gt ${#backups[@]} ]; then
    echo "⛔️ Escolha inválida."
    exit 1
fi

selected_backup="${backups[$((num-1))]}"

# Parar e remover o site existente (se aplicável)
if [ $SITE_EXISTS -eq 1 ]; then
    echo -e "\nParando o site $OMD_SITE..."
    sudo omd stop "$OMD_SITE"
    echo "Removendo o site $OMD_SITE..."
    sudo omd rm "$OMD_SITE"
fi

# Restaurar cópia selecionada
echo -e "\nRestaurando a cópia ${selected_backup##*/}..."
sudo omd restore "$selected_backup"

# Iniciar o site
echo "Iniciando o site $OMD_SITE..."
sudo omd start "$OMD_SITE"

echo -e "\n✅ Cópia restaurada com sucesso!"
