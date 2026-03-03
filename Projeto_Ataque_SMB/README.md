# Simulação de Ataque SMB: Enumeração e Password Spraying com Medusa

Este projeto prático demonstra a execução de um cenário controlado de Ethical Hacking, focando na exploração de credenciais corporativas vulneráveis no protocolo SMB utilizando a ferramenta Medusa. O laboratório aborda desde a enumeração de usuários até a validação de acesso, incluindo a análise crítica de falsos positivos em ferramentas de força bruta.

> **Aviso Legal:** Este projeto foi realizado em um ambiente de laboratório estritamente controlado e isolado (VirtualBox). Todas as técnicas aqui documentadas têm fins única e exclusivamente educacionais e de pesquisa acadêmica em Segurança da Informação. Nunca execute ferramentas de ataque contra sistemas sem autorização explícita e documentada.

## Objetivo do Projeto
Compreender a lógica de tentativa e erro utilizada para comprometer sistemas mal configurados e explorar o impacto de senhas fracas. O projeto também desenvolve uma visão crítica sobre as limitações de ferramentas clássicas em interfaces Web modernas e a importância de validar logs para mitigar falsos positivos.

## Topologia e Ambiente
* **Atacante:** Kali Linux (192.168.56.102)
* **Alvo Vulnerável:** Metasploitable 2 (192.168.56.101)
* **Rede:** Host-only (Isolada via VirtualBox)

## Metodologia

### 1. Reconhecimento e Mapeamento
A comunicação entre atacante e alvo foi validada via ICMP (ping). Em seguida, uma varredura de serviços com Nmap identificou portas abertas críticas:

```bash
nmap -sV -p 21,22,80,445,139 192.168.56.101
```
*Portas de interesse: 139 e 445 (Samba/SMB).*

### 2. Enumeração de Vulnerabilidades (Null Session)
Utilizando o `enum4linux`, foi identificada uma falha crítica de configuração no servidor SMB, permitindo Sessões Nulas (acesso sem credenciais). Isso vazou a lista completa de usuários do sistema.

```bash
enum4linux -a 192.168.56.101 | tee enum4_output.txt
```
*Vazamento crítico identificado:* `[+] Server 192.168.56.101 allows sessions using username '', password ''`

### 3. Criação de Wordlists Customizadas
Com base na enumeração, foram criadas wordlists focadas apenas em usuários reais para otimizar o ataque e evitar bloqueios desnecessários (Password Spraying).
* **smb_user.txt:** user, msfadmin, service
* **senhas_spray.txt:** password, 123456, Welcome123, msfadmin

### 4. Visão Crítica: Limitações e Falsos Positivos em Ataques Web
Durante os testes, o Medusa foi direcionado contra um formulário de login HTTP (`/dvwa/login.php`). A ferramenta apresentou 100% de Falsos Positivos (`[SUCCESS]` em todas as senhas), pois o módulo `-M http` ignora formulários modernos baseados em HTML. O Medusa é excelente para serviços de rede diretos (FTP, SMB, SSH), mas inadequado para Web Forms complexos, onde ferramentas como Hydra ou Burp Suite são recomendadas.

### 5. Execução do Ataque (Password Spraying SMB)
O ataque definitivo foi direcionado ao serviço Samba nativo usando o módulo `smbnt`.

```bash
medusa -h 192.168.56.101 -U smb_user.txt -P senhas_spray.txt -M smbnt -t 2 -T 50
```
* **Resultado:** Credencial comprometida com sucesso.
  * **Usuário:** msfadmin
  * **Senha:** msfadmin
  * **Acesso:** `[SUCCESS (ADMIN$ - Access Allowed)]`

### 6. Validação (Proof of Concept)
Para comprovar o impacto da violação, a ferramenta `smbclient` foi usada para autenticar no servidor alvo e listar os compartilhamentos expostos à rede:

```bash
smbclient -L //192.168.56.101 -U msfadmin
```
* **Impacto:** Acesso validado ao diretório pessoal do usuário (`Home Directories`) e a diretórios de sistema (`tmp`, `opt`), permitindo leitura, escrita e potencial movimentação lateral.

## Mitigação e Boas Práticas
Para proteger um ambiente corporativo contra os vetores explorados neste laboratório, recomenda-se:
1. **Desabilitar Null Sessions:** Configurar o Samba/Windows Server para rejeitar enumerações anônimas (`RestrictAnonymous`).
2. **Políticas de Senhas Fortes:** Implementar complexidade, tamanho mínimo e rotatividade.
3. **Múltiplo Fator de Autenticação (MFA):** Essencial para barrar acessos mesmo que a senha seja comprometida.
4. **Monitoramento e Bloqueio (Rate Limiting):** Configurar bloqueio automático após múltiplas tentativas falhas de login.
