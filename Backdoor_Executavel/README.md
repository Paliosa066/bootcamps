# Análise de Ameaça: Engenharia Social e Evasão Básica com Backdoors

Este projeto documenta o estudo conceitual e a simulação de uma infecção por backdoor (trojan) em um ambiente Windows. O foco deste laboratório é compreender a *Kill Chain* de um ataque baseado em executáveis maliciosos, analisando as táticas de evasão de controles básicos do sistema operacional e as medidas defensivas necessárias para mitigar a ameaça.

> **Aviso Legal:** Este projeto foi realizado em um ambiente de laboratório estritamente controlado e isolado (VirtualBox). Todas as técnicas aqui documentadas têm fins educacionais e de pesquisa acadêmica em Cibersegurança, com foco em defesa (Blue Team/Purple Team). Não contém instruções acionáveis de exploração.

## Topologia e Ambiente
* **Atacante (C2):** Kali Linux (192.168.56.102)
* **Alvo Vulnerável:** Windows 7 (192.168.56.104)
* **Vetor de Distribuição:** Servidor Web Local (Apache2)

## Fases da Ameaça Analisada (Kill Chain)

### 1. Weaponization (Armamento)
Foi gerado um payload malicioso do tipo *Reverse TCP* embutido em um arquivo executável (`.exe`) de arquitetura 32 bits. Diferente de um *Bind TCP*, que tenta abrir uma porta no alvo (sendo facilmente bloqueado pelo Firewall do Windows), o *Reverse TCP* faz com que a máquina vítima inicie a conexão de saída (outbound) de volta para o servidor de Comando e Controle (C2) do atacante, burlando regras de entrada.

### 2. Delivery e Evasão Básica (Heurística)
O executável foi hospedado em um servidor web interno. Durante os testes, observou-se o comportamento do Controle de Conta de Usuário (UAC) do Windows:
* **Detecção Heurística:** Nomear o artefato como `Update.exe` ativou imediatamente os alertas de segurança do Windows, que exigiu privilégios de Administrador sob a premissa de que "atualizações" alteram o sistema.
* **Evasão Simples:** Ao renomear o artefato para um nome inofensivo e de uso comum no meio corporativo (ex: `planilha.exe`), o controle de heurística básica baseada em nomenclatura foi evadido, permitindo a execução pelo usuário padrão sem acionar o prompt do UAC.

### 3. Command & Control (C2) e Enumeração
Com a execução bem-sucedida no alvo, estabeleceu-se um canal de comunicação criptografado (sessão Meterpreter). A partir deste ponto, foi possível realizar o reconhecimento interno do sistema de arquivos, navegando por diretórios críticos (`C:\Windows`) com os privilégios do usuário comprometido.

## Mitigação e Defesa em Profundidade
Para proteger endpoints e redes corporativas contra esta exata tipologia de ataque, as seguintes camadas de segurança devem ser implementadas:

1. **Endpoint Detection and Response (EDR) / Antivírus:** Soluções de segurança modernas identificam rapidamente assinaturas conhecidas de payloads gerados por frameworks públicos e bloqueiam a execução antes que o artefato seja salvo em disco.
2. **Controle de Execução (AppLocker / WDAC):** Configurar políticas via GPO para bloquear a execução de binários não assinados digitalmente ou que sejam executados a partir de diretórios de usuário (como `Downloads` ou `%Temp%`).
3. **Egress Filtering (Filtro de Saída):** Implementar regras estritas de firewall (Zero Trust Network Access - ZTNA) para bloquear conexões de saída não essenciais em portas altas (ex: 4444), permitindo apenas tráfego legitimado (ex: 80, 443).
4. **Conscientização de Segurança:** Treinamento contínuo dos colaboradores contra táticas de Engenharia Social (Phishing), principal vetor de entrega desse tipo de artefato.
