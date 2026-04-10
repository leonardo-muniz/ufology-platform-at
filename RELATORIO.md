# Relatório de Implantação - Ufology Investigation Unit

## **1. Visão Geral e Organização do Projeto**

O projeto foi estruturado seguindo rigorosas boas práticas de Engenharia de Software e DevOps, priorizando a modularidade, separação de responsabilidades e clareza. A árvore de diretórios do repositório reflete uma arquitetura profissional, dividida nos seguintes domínios lógicos:

* `.github/workflows/`: Centraliza todas as esteiras de Integração Contínua (CI), separando as responsabilidades por arquivo (testes, build, variáveis e secrets).

* `app-source/devops2026-ufoTracker/`: Isola o código-fonte da aplicação Java, scripts auxiliares de automação (`build-docker-image.sh`, `docker-run.sh`), definições de dependências (`pom.xml`) e o `Dockerfile`, mantendo o escopo da aplicação limpo e independente da infraestrutura.

* `k8s/`: Agrupa os manifestos declarativos do Kubernetes, categorizados de forma semântica em subdiretórios específicos para cada componente (`app`, `postgres`, `redis`). Essa segregação facilita a manutenção, leitura e futuras escalabilidades do cluster.

* `evidencias/`: Diretório dedicado à documentação de aprovação e prints de execução, mantendo a rastreabilidade do projeto.

* **Scripts na raiz:** Arquivos como `run-kube.sh` fornecem atalhos operacionais para provisionamento rápido do ambiente.

## **2. Infraestrutura e Orquestração (Kubernetes)**

Toda a infraestrutura foi projetada para rodar de forma isolada dentro do namespace exclusivo `ufology`, definido no arquivo `00-namespace.yaml`.

### **2.1. Banco de Dados (PostgreSQL)**
A persistência de dados foi implementada na pasta `k8s/postgres/`.

* Utiliza a imagem customizada `leogloriainfnet/ufodb` por meio de um **Deployment** com 1 réplica.

* O armazenamento é garantido por um PersistentVolumeClaim (PVC) (`pvc.yaml`).

* As credenciais sensíveis e o nome do banco são injetados de forma segura através de um **Secret** e um **ConfigMap** locais.

* O acesso interno é exposto via **Service** na porta padrão do PostgreSQL.

### **2.2. Camada de Cache (Redis)**
Para otimizar o desempenho e reduzir a carga de consultas repetitivas no banco, um sistema de cache foi estruturado na pasta `k8s/redis/`.

* Implantado via **Deployment** (1 réplica) utilizando uma imagem leve baseada em Alpine.

* Exposto para os demais pods do cluster através de um **Service** dedicado.

### **2.3. Aplicação Principal**
Os manifestos da aplicação encontram-se em `k8s/app/`.

* A aplicação foi conteinerizada e sua imagem implantada via **Deployment** (2 réplicas para alta disponibilidade).

* Um **ConfigMap** (`app-config.yaml`) fornece o nome do banco (`POSTGRES_DB`).

* Um Secret (`secret.yaml`) protege e fornece a senha do banco de dados (`POSTGRES_PASSWORD`), evitando hardcode nos manifestos de deployment.

* A aplicação é exposta na rede do cluster por meio do seu respectivo **Service**.

## **3. Integração e Entrega Contínua (CI/CD)**
A automação do repositório foi construída utilizando o GitHub Actions, com workflows dedicados para diferentes gatilhos e validações de segurança:

* `hello.yml`: Workflow básico para validação de execução e logs em eventos de push.

* `tests.yml`: Gatilho configurado para pull requests, garantindo a execução dos testes antes de integrações na branch principal.

* `maven-ci.yml`: Esteira de build disparada em pushes na branch `main`, utilizando o empacotamento do Maven e o cache do JDK 21 (Eclipse Temurin).

* `env-demo.yml`: Demonstração de injeção e uso de variáveis de ambiente (`DEPLOY_ENV=staging`).

* `secret-demo.yml`: Validação segura de secrets de repositório (`API_KEY`), aplicando o princípio do menor privilégio e mascaramento de logs.

## **4. Diferença entre Runners Hospedados pelo GitHub e Auto-hospedados**
A execução dos workflows do GitHub Actions exige máquinas computacionais, chamadas de "Runners". Existem dois modelos principais para provisionar essas máquinas:

### Runners Hospedados pelo GitHub (GitHub-hosted runners)
São máquinas virtuais (VMs) mantidas e gerenciadas integralmente pela própria infraestrutura do GitHub. Sempre que um job é acionado, o GitHub provisiona uma VM totalmente limpa e, ao término da execução, a destrói.

* **Vantagens:**

  * **Zero Manutenção:** Não há necessidade de configurar, atualizar ou aplicar patches de segurança no sistema operacional; o GitHub gerencia a infraestrutura.

  * **Ambiente Limpo:** A VM é descartada após o uso, eliminando o risco de artefatos ou estados de execuções anteriores quebrarem o build atual.

  * **Escalabilidade:** O sistema aloca recursos sob demanda de forma transparente.

* **Desvantagens:**

  * **Custo e Limites:** Depende de uma cota de minutos; após excedê-la, há cobrança financeira. Há também limites rígidos de timeout.

  * **Hardware Padrão:** As opções de hardware são inflexíveis e podem não atender a builds que exigem processamento extremo.

  * **Redes Privadas:** É complexo permitir que esses runners acessem recursos internos protegidos por firewalls corporativos.

### Runners Auto-hospedados (Self-hosted runners)
São servidores (físicos, VMs ou containers) hospedados na infraestrutura do próprio usuário (on-premise ou nuvem privada) onde o agente do GitHub Actions é instalado.

* **Vantagens:**

  * **Controle Total de Hardware:** Permite provisionar máquinas com as especificações exatas necessárias (ex: alta memória, GPUs).

  * **Acesso à Rede Interna:** Como rodam dentro da rede corporativa, acessam facilmente bancos de dados privados e ambientes internos sem expor portas para a internet.

  * **Sem Custo de Minutos no GitHub:** A execução é ilimitada por parte do GitHub, pois o custo recai sobre a infraestrutura própria do usuário.

  * **Cache Persistente:** Permite manter dependências pesadas salvas em disco entre as execuções, acelerando os builds.

* **Desvantagens:**

  * **Custo de Manutenção:** A responsabilidade por atualizações do SO, segurança, patches e monitoramento do servidor é inteiramente da equipe.

  * **Risco de Sujeira no Ambiente:** Se os jobs não limparem o diretório de trabalho corretamente, dados residuais podem causar falhas em builds subsequentes ou expor informações sensíveis entre diferentes pipelines.

## **5. Evidências de Execução e Links Solicitados**

### **5.1. Missão 3 - Dockerização da Aplicação**
Conforme exigido pelo enunciado, seguem as evidências do processo de construção e publicação da imagem da aplicação:

### O Dockerfile criado:
O arquivo completo encontra-se no repositório em `app-source/devops2026-ufoTracker/Dockerfile`.

### Comando utilizado para build da imagem:

```bash
docker build -t leonardocmuniz/ufo-tracker:latest ./app-source/devops2026-ufoTracker
```

### Comando utilizado para push:

```bash
docker push leonardocmuniz/ufo-tracker:latest
```

### Link público da imagem no repositório Docker:

* [Link para o Docker Hub](https://hub.docker.com/r/leonardocmuniz/ufo-tracker)

### **5.2. Partes 2 e 3 - Workflows do GitHub Actions**
Abaixo estão os links para os logs de execução de cada workflow diretamente no GitHub, acompanhados das evidências visuais (prints) armazenadas na pasta `/evidencias`.

* **Hello Workflow (`hello.yml`)**
  * **Link da execução:** [Acessar Log no GitHub](./evidencias/logs/hello)
  * **Evidência:** [Acessar Evidência em Print](./evidencias/say-hello-workflow.png)

* **Tests Workflow (`tests.yml`)**
  * **Link da execução:** [Acessar Log no GitHub](./evidencias/logs/tests)
  * **Evidência:** [Acessar Evidência em Print](./evidencias/test-job-workflow.png)

* **Maven CI Workflow (`maven-ci.yml`)**

  **Nota:** Utilizado Maven no lugar do Gradle, conforme permissão no enunciado.
  * **Link da execução:** [Acessar Log no GitHub](./evidencias/logs/maven-ci)
  * **Evidência:** [Acessar Evidência em Print](./evidencias/maven-build-workflow.png)

* **Environment Variables Demo (`env-demo.yml`)**
  * **Link da execução:** [Acessar Log no GitHub](./evidencias/logs/env-demo)
  * **Evidência:** [Acessar Evidência em Print](./evidencias/env-demo-workflow.png)

* **Secret Demo (`secret-demo.yml`)**
  * **Link da execução:** [Acessar Log no GitHub](./evidencias/logs/secret-demo)
  * **Evidência:** [Acessar Evidência em Print](./evidencias/secret-demo-workflow.png)