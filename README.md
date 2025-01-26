# Checkmk Automated Installation for Ubuntu 24.04

Script para instalação automatizada do Checkmk Raw Edition (CRE) em Ubuntu 24.04 (Noble Numbat).


## Pré-requisitos

- Ubuntu 24.04 LTS (Noble Numbat)
- Acesso sudo/root
- Conexão com Internet
- 2 GB RAM mínimo (recomendado 4 GB)
- 10 GB de espaço em disco

## Instalação

1. **Clonar o repositório (opcional):**
```bash
git clone https://github.com/seu-usuario/checkmk-install.git
cd checkmk-install
```

Tornar o script executável:
```
chmod +x install_checkmk.sh
```

Executar o script:
```
sudo ./install_checkmk.sh
```

Para definir um nome personalizado para o site:

```
sudo OMD_SITE=meu_site_personalizado ./install_checkmk.sh
```

Pós-instalação
Acesse a interface web:

```
http://<IP-DO-SERVIDOR>/<NOME-DO-SITE>/
```

Credenciais iniciais:

```
Usuário: admin
Senha: admin
```

Ações imediatas recomendadas:

Alterar a senha do admin

Configurar HTTPS

Adicionar hosts para monitoração

Configuração Avançada
Variáveis do Script
Variável	Valor Padrão	Descrição
VERSION	2.2.0p12	Versão do Checkmk
UBUNTU_CODENAME	jammy	Release base Ubuntu
OMD_SITE	mysite	Nome do site OMD
Personalização da Instalação
Para instalar uma versão diferente:

```
sudo VERSION="2.2.0p11" ./install_checkmk.sh
```

Para Ubuntu 24.04 (noble) se disponível:

```
sudo UBUNTU_CODENAME="noble" ./install_checkmk.sh
```

Operações Básicas do OMD
Iniciar/Parar serviço:

```
sudo omd start <site>
sudo omd stop <site>
```

Listar sites:
```
sudo omd sites
```

Acessar shell do site:
```
sudo omd su <site>
```

Notas Importantes
⚠️ Segurança:

Altere a senha padrão imediatamente após a instalação

Recomendado configurar certificado SSL

Restrinja acesso à interface web

🔄 Atualização:

Consulte a documentação oficial para atualizações

💾 Backup:

```
sudo omd backup <site>
```

# Script de Atualização do Checkmk

Script seguro para atualização do Checkmk em ambientes Ubuntu 24.04 com sistema de backup e rollback automático.

![Workflow de Atualização](https://img.shields.io/badge/Workflow-Seguro%20Update-brightgreen)

## Pré-requisitos

- Checkmk instalado (versão Raw/Enterprise)
- Ubuntu 24.04 (Noble Numbat)
- Acesso root/sudo
- 5 GB de espaço livre em disco
- Conexão com internet

## Uso Básico

### 1. Baixar o script
```bash
wget https://github.com/seu-usuario/checkmk-update/raw/main/update_checkmk.sh
```
### 2. Tornar executável
```bash
chmod +x update_checkmk.sh
```

### 3. Executar atualização
```bash
sudo ./update_checkmk.sh
```


```bash
Os testes foram bem sucedidos? (s/n)
Resposta s: Aplica update na instalação principal
Resposta n: Rollback automático
```

Verifique status de todos serviços:

```bash
sudo omd status -v $OMD_SITE
```
Confira logs de atualização:

bash
```
sudo tail -n 50 /var/log/checkmk/update.log
```

Rollback Manual
Para restaurar backup específico:

```bash
sudo omd stop $OMD_SITE
sudo omd restore /caminho/do/backup.tar.gz
sudo omd start $OMD_SITE
```

Funcionalidades Principais
✅ Backup automático pré-update

🛡️ Ambiente de teste isolado

🔄 Rollback automático em caso de falha

📊 Monitoramento de recursos durante atualização

🗑️ Limpeza inteligente de arquivos temporários

📅 Rotação automática de backups


# Scripts de Backup e Restore para Checkmk

## 📁 `backup_checkmk.sh`
**Função:** Cria backups completos de sites OMD com gestão automatizada.

### Funcionalidades:
- ✅ Backup com timestamp no formato `YYYYMMDDHHMMSS`
- 📂 Armazenamento em `/var/lib/checkmk/backups`
- 🔒 Verificação de permissões root
- 🔄 Rollback automático em falhas críticas
- 📊 Relatório pós-backup com localização e tamanho
- 🛡️ Validação prévia da existência do site

### Uso:
```bash
sudo ./backup_checkmk.sh <NOME_DO_SITE>
```

### Fluxo:
1. Cria diretório de backups se não existir
2. Para o site OMD temporariamente
3. Gera arquivo `.tar.gz` compactado
4. Reinicia o site após conclusão

---

## 🔄 `restore_checkmk.sh`
**Função:** Restaura sites OMD a partir de backups existentes com confirmação interativa.

### Funcionalidades:
- 📋 Listagem hierárquica de backups disponíveis
- 🗂️ Identificação de backups preventivos vs normais
- ⏳ Exibição de datas formatadas (ex: `2025-01-27 14:30`)
- 🔄 Cria backup pré-restauração como fallback
- 🚨 Sistema de rollback automático em erros
- 📏 Exibição de tamanho dos arquivos de backup

### Uso:
```bash
sudo ./restore_checkmk.sh <NOME_DO_SITE>
```

### Fluxo:
1. Lista backups com detalhes de tipo/data/tamanho
2. Cria backup preventivo do estado atual
3. Remove site existente (se aplicável)
4. Restaura backup selecionado
5. Valida reinicialização do serviço

---


## 🔗 Recursos Relacionados
- [Documentação Oficial Checkmk - Backups](https://docs.checkmk.com/latest/en/backup.html) 
- [Guia de Migração entre Servidores](https://forum.checkmk.com/t/check-mk-english-restore-backup-on-another-server/13385) 
- [Políticas de Retenção Avançadas](https://forum.checkmk.com/t/check-mk-english-checking-if-backups-are-working/11692)


Licença
MIT - Consulte o ficheiro LICENSE para detalhes.
