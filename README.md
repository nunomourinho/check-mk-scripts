# Checkmk Automated Installation for Ubuntu 24.04

Script para instalação automatizada do Checkmk Raw Edition (CRE) em Ubuntu 24.04 (Noble Numbat).

![Checkmk Logo](https://checkmk.com/static/images/checkmk-logo.svg)

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

## Opções Avançadas
Variável de Ambiente	Descrição	Exemplo
NEW_VERSION	Define versão específica	NEW_VERSION="2.2.0p14" ./update_checkmk.sh
UBUNTU_CODENAME	Altera codename Ubuntu	UBUNTU_CODENAME="noble" ./update_checkmk.sh
OMD_SITE	Especifica site manualmente	OMD_SITE="meusite" ./update_checkmk.sh

Fluxo de Atualização
Backup Automático

Cria backup compactado do site atual

Armazena em /var/lib/checkmk/backups/

Instalação Segura

Baixa nova versão

Mantém instalação principal intacta

Ambiente Temporário

Cria clone do site (<site>_temp)

Disponibiliza para testes em:

```
http://<seu-ip>/<site>_temp/
```

```bash
Os testes foram bem sucedidos? (s/n)
Resposta s: Aplica update na instalação principal
Resposta n: Rollback automático
```

Limpeza Final

Remove ambiente temporário

Mantém backups antigos por 7 dias

Pós-Atualização
Verificações Obratórias
Acesse a interface web principal

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

Notas Importantes
⚠️ Melhores Práticas

Sempre teste em ambiente de homologação primeiro

Verifique compatibilidade da nova versão

Backups são mantidos por 7 dias (automática)

Tempo de downtime estimado: 2-5 minutos

🕒 Janela de Manutenção

```bash
# Agendar update (via cron)
0 2 * * * /caminho/update_checkmk.sh > /var/log/cmk_update.log 2>&1
```

Troubleshooting
Erro Comum: Permissões

```bash
chmod +x update_checkmk.sh
chown root:root update_checkmk.sh
```
Download Falhou

```bash
# Verificar versões disponíveis
curl -s https://download.checkmk.com/checkmk/ | grep -oP 'href="\K[^"]+'
```

Rollback Falhou

```bash
Copy
# Listar backups disponíveis
sudo ls -lh /var/lib/checkmk/backups/
```

Suporte
Documentação Oficial Checkmk

Licença
MIT - Consulte o ficheiro LICENSE para detalhes.
