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

Suporte
Documentação Oficial Checkmk

Fórum da Comunidade

Issues do GitHub

Licença
MIT - Consulte o ficheiro LICENSE para detalhes.
