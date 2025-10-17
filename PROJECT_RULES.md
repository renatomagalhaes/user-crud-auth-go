# Projeto: CRUD de Usuários com Autenticação OAuth2 (Golang)

## 📋 Índice

- [1. Objetivo](#1-objetivo)
- [2. Escopo Funcional](#2-escopo-funcional)
- [3. Modelagem de Domínio (DDD)](#3-modelagem-de-domínio-ddd)
- [4. Modelagem de Dados (MySQL)](#4-modelagem-de-dados-mysql)
- [5. Arquitetura e Organização](#5-arquitetura-e-organização)
- [6. Padrões e Convenções](#6-padrões-e-convenções)
- [7. Infraestrutura](#7-infraestrutura)
- [8. Autenticação e Segurança](#8-autenticação-e-segurança)
- [9. Documentação da API](#9-documentação-da-api)
- [10. Testes e Benchmark](#10-testes-e-benchmark)
- [11. Repositório e Git](#11-repositório-e-git)
- [12. Entregas e Roadmap](#12-entregas-e-roadmap)
- [13. Regras para Cursor AI](#13-regras-para-cursor-ai)

---

## 1. Objetivo

Desenvolver uma aplicação CRUD de usuários com autenticação OAuth2, utilizando:

- **Arquitetura**: Hexagonal, DDD, CQRS
- **Padrões**: Use Cases, DTOs, Value Objects
- **Tecnologias**: Golang, Docker, Docker Compose, Makefile, Swagger, MySQL

### 🎯 Meta Principal

Criar uma aplicação robusta e limpa que servirá de base para **comparação de desempenho** com versões equivalentes em:
- Laravel Swoole
- Hyperf Swoole

---

## 2. Escopo Funcional

### 📝 Requisitos Funcionais

| ID | Descrição |
|---|---|
| **RF01** | Permitir o cadastro de usuários (nome, e-mail, senha) |
| **RF02** | Implementar autenticação OAuth2 com grant types `password` e `client_credentials` |
| **RF03** | Permitir login e refresh de token |
| **RF04** | Permitir atualização e exclusão de usuários autenticados |
| **RF05** | Permitir listagem paginada de usuários |
| **RF06** | Registrar logs de autenticação |
| **RF07** | Expor documentação da API via Swagger |
| **RF08** | Permitir opt-in para newsletter no cadastro (single opt-in) |
| **RF09** | Permitir unsubscribe de newsletter via link único |
| **RF10** | Gerenciar sessões ativas por dispositivo |
| **RF11** | Visualizar dispositivos logados |
| **RF12** | Deslogar de um ou todos dispositivos |
| **RF13** | Alterar senha com opção de deslogar todos dispositivos |
| **RF14** | Versionamento de API (suporte a múltiplas versões) |

### ⚙️ Requisitos Não Funcionais

| ID | Descrição |
|---|---|
| **RNF01** | Utilizar Arquitetura Hexagonal (Ports & Adapters) com DDD e CQRS |
| **RNF02** | Banco de dados MySQL 8 |
| **RNF03** | Containerização via Docker e orquestração via Docker Compose |
| **RNF04** | Automação via Makefile (build, run, test, lint) |
| **RNF05** | Testes unitários e de integração obrigatórios |
| **RNF06** | Código seguindo SOLID, Clean Code, Clean Architecture |
| **RNF07** | Ambiente local isolado |
| **RNF08** | Autenticação JWT com Refresh Token |
| **RNF09** | Comparar métricas de performance com outras linguagens via Locust |

---

## 3. Modelagem de Domínio (DDD)

### 🏗️ Contexto Principal
**Domínio de Usuário (User)**

### 📦 Entidades

#### UserEntity
```go
type UserEntity struct {
    ID        uuid.UUID
    Name      string
    Email     EmailVO
    Password  HashedPasswordVO
    CreatedAt time.Time
    UpdatedAt time.Time
}
```

### 🎯 Value Objects

| VO | Responsabilidade |
|---|---|
| **EmailVO** | Valida e encapsula endereço de e-mail |
| **HashedPasswordVO** | Criptografa e valida senha |

### 🌳 Agregado Raiz
**UserAggregate** - Gerencia a consistência das operações do usuário e garante as regras de negócio do agregado.

### 📡 Eventos de Domínio

- `UserCreated`
- `UserAuthenticated`
- `UserUpdated`
- `UserDeleted`

### 🔧 Casos de Uso (Use Cases)

| Use Case | Tipo | Descrição |
|---|---|---|
| `CreateUserUseCase` | Command | Criar usuário |
| `AuthenticateUserUseCase` | Command | Autenticar usuário |
| `UpdateUserUseCase` | Command | Atualizar usuário |
| `DeleteUserUseCase` | Command | Deletar usuário |
| `ListUsersUseCase` | Query | Listar usuários |
| `SubscribeNewsletterUseCase` | Command | Inscrever em newsletter |
| `UnsubscribeNewsletterUseCase` | Command | Desinscrever de newsletter |
| `ListUserSessionsUseCase` | Query | Listar sessões do usuário |
| `RevokeSessionUseCase` | Command | Revogar sessão específica |
| `RevokeAllSessionsUseCase` | Command | Revogar todas as sessões |
| `ChangePasswordUseCase` | Command | Alterar senha |

### 📋 Padrão CQRS

**Commands** (Modificação de dados):
- Create, Update, Delete

**Queries** (Consulta de dados):
- List, Find

> **Nota**: Cada caso de uso deve possuir input/output DTO e seguir princípios CQRS

---

## 4. Modelagem de Dados (MySQL)

### 📊 Tabela: `users`

| Campo | Tipo | Descrição | Constraints |
|---|---|---|---|
| `id` | `CHAR(36)` | UUID do usuário | PRIMARY KEY |
| `name` | `VARCHAR(150)` | Nome do usuário | NOT NULL |
| `email` | `VARCHAR(150)` | E-mail do usuário | UNIQUE, NOT NULL |
| `password` | `VARCHAR(255)` | Senha criptografada | NOT NULL |
| `newsletter_subscribed` | `BOOLEAN` | Opt-in para newsletter | DEFAULT FALSE |
| `newsletter_subscribed_at` | `DATETIME` | Data de inscrição newsletter | NULL |
| `newsletter_unsubscribe_token` | `CHAR(36)` | Token para unsubscribe | UNIQUE, NULL |
| `created_at` | `DATETIME` | Data de criação | NOT NULL |
| `updated_at` | `DATETIME` | Data de atualização | NOT NULL |

### 🔐 Tabela: `oauth_clients`

| Campo | Tipo | Descrição | Constraints |
|---|---|---|---|
| `id` | `INT` | ID do cliente OAuth | PRIMARY KEY, AUTO_INCREMENT |
| `name` | `VARCHAR(100)` | Nome do cliente | NOT NULL |
| `secret` | `VARCHAR(255)` | Secret do cliente | NOT NULL |
| `redirect_uri` | `VARCHAR(255)` | URI de redirecionamento | NULL |
| `grant_types` | `VARCHAR(100)` | Tipos de grant permitidos | NOT NULL |

### 📱 Tabela: `user_sessions`

| Campo | Tipo | Descrição | Constraints |
|---|---|---|---|
| `id` | `CHAR(36)` | UUID da sessão | PRIMARY KEY |
| `user_id` | `CHAR(36)` | FK para users | FOREIGN KEY, NOT NULL |
| `device_id` | `CHAR(36)` | UUID do dispositivo | NOT NULL |
| `device_name` | `VARCHAR(100)` | Nome do dispositivo | NOT NULL |
| `device_type` | `ENUM` | Tipo: mobile/desktop/tablet | NOT NULL |
| `ip_address` | `VARCHAR(45)` | Endereço IP | NOT NULL |
| `user_agent` | `TEXT` | User Agent do browser | NOT NULL |
| `refresh_token_hash` | `VARCHAR(255)` | Hash do refresh token | NOT NULL |
| `expires_at` | `DATETIME` | Data de expiração (90 dias) | NOT NULL |
| `last_used_at` | `DATETIME` | Último uso da sessão | NOT NULL |
| `created_at` | `DATETIME` | Data de criação | NOT NULL |

---

## 5. Arquitetura e Organização

### 🏛️ Padrão Arquitetural
**Hexagonal Architecture + DDD + CQRS**

### 📁 Estrutura de Diretórios

```
project/
├── cmd/
│   └── api/
│       └── main.go
├── internal/
│   ├── domain/
│   │   ├── user/
│   │   │   ├── entity.go
│   │   │   ├── entity_test.go
│   │   │   ├── value_objects.go
│   │   │   ├── value_objects_test.go
│   │   │   └── repository.go
│   │   └── auth/
│   │       ├── session.go
│   │       ├── session_test.go
│   │       └── repository.go
│   ├── application/
│   │   ├── command/
│   │   │   ├── create_user.go
│   │   │   └── create_user_test.go
│   │   └── query/
│   ├── infrastructure/
│   │   ├── persistence/
│   │   │   └── mysql/
│   │   ├── http/
│   │   │   ├── v1/
│   │   │   │   ├── user_handler.go
│   │   │   │   └── auth_handler.go
│   │   │   └── middleware/
│   │   └── oauth/
│   └── config/
├── docker/
│   ├── dev/
│   │   ├── Dockerfile.dev
│   │   └── docker-compose.yml
│   └── production/
│       ├── Dockerfile.prod (futuro)
│       └── docker-compose.prod.yml (futuro)
├── scripts/
│   ├── schema.sql
│   └── seed.sql
├── .air.toml
├── Makefile
├── go.sum
└── go.mod
```

### 🎯 Descrição das Camadas

| Camada | Responsabilidade |
|---|---|
| **`domain/`** | Contém regras de negócio puras, entidades, VO e eventos |
| **`application/`** | Contém os casos de uso (use cases) e orquestra o fluxo |
| **`interfaces/`** | Define as portas (input/output) para interação com adaptadores |
| **`infrastructure/`** | Implementa os adaptadores concretos (DB, HTTP, OAuth, etc) |
| **`cmd/`** | Ponto de entrada da aplicação (main, bootstrap, DI) |

---

## 6. Padrões e Convenções

### 📝 Nomenclatura

| Tipo | Sufixo | Exemplo |
|---|---|---|
| **Entities** | `Entity` | `UserEntity` |
| **Value Objects** | `VO` | `EmailVO`, `HashedPasswordVO` |
| **Use Cases** | `UseCase` | `CreateUserUseCase` |
| **DTOs** | `DTO` | `CreateUserDTO`, `UserResponseDTO` |
| **Repository Interfaces** | `Repository` | `UserRepository` |

### 🎯 Padrões Arquiteturais

- ✅ **Código organizado de fora para dentro**, protegendo o domínio
- ✅ **Use Cases independentes de frameworks**
- ✅ **Dependências injetadas via interface**
- ✅ **DTOs para comunicação entre camadas**
- ✅ **VO para validação e consistência de valores**

### 🔧 Regras de Desenvolvimento

1. **Domínio puro**: Sem dependências externas
2. **Inversão de dependência**: Interfaces no domínio, implementações na infraestrutura
3. **Separação de responsabilidades**: Cada camada tem sua responsabilidade específica
4. **Testabilidade**: Fácil criação de mocks e testes unitários

---

## 7. Infraestrutura

### 🛠️ Ferramentas Utilizadas

| Ferramenta | Versão | Propósito |
|---|---|---|
| **Docker & Docker Compose** | Latest | Containerização e orquestração |
| **Air** | v1.40.4 | Hot reload para desenvolvimento |
| **Makefile** | - | Automação de tarefas |
| **Swagger** | OpenAPI 3 | Documentação da API |
| **MySQL** | 8.x | Banco de dados |
| **Go Modules** | 1.22+ | Gerenciamento de dependências |
| **Wire** | Latest | Injeção de dependências (opcional) |

### 🐳 Serviços Docker Compose

| Serviço | Container | Descrição | Porta |
|---|---|---|---|
| **`user-crud-auth-go`** | `user-crud-auth-go-dev` | Container da aplicação Go (desenvolvimento) | `8080` |
| **`db`** | `user-crud-auth-go-db` | MySQL 8 (futuro) | `3306` |
| **`swagger-ui`** | `user-crud-auth-go-swagger` | Documentação da API (futuro) | `8081` |

### ⚙️ Comandos Makefile

#### Desenvolvimento
| Comando | Descrição |
|---|---|
| `make up` | Inicia containers de desenvolvimento |
| `make down` | Para containers de desenvolvimento |
| `make build` | Recompila aplicação (desenvolvimento) |
| `make logs` | Visualiza logs dos containers |
| `make shell` | Acessa shell do container |
| `make clean` | Remove containers e volumes |

#### Banco de Dados (Futuro)
| Comando | Descrição |
|---|---|
| `make test` | Executa testes |
| `make lint` | Verifica estilo de código |
| `make db-setup` | Cria estrutura do banco (schema.sql) |
| `make db-seed` | Insere dados iniciais (seed.sql) |
| `make db-reset` | Apaga e recria banco (setup + seed) |

### 🐳 Organização Docker

**Estrutura por Ambiente:**
```
docker/
├── dev/                    # Ambiente de desenvolvimento
│   ├── Dockerfile.dev      # Dockerfile para desenvolvimento local
│   └── docker-compose.yml  # Orquestração para desenvolvimento
└── production/             # Ambiente de produção (futuro)
    └── Dockerfile.prod     # Dockerfile para produção (futuro)
```

**Características por Ambiente:**

#### Desenvolvimento (`docker/dev/`)
- **Dockerfile.dev**: Air para hot reload, volume mounts, debugging
- **docker-compose.yml**: Porta 8080, volumes para live reload, variáveis Go
- **Hot Reload**: Configurado com Air v1.40.4 para desenvolvimento ágil

#### Produção (`docker/production/`) - Futuro
- **Dockerfile.prod**: Multi-stage build, binário otimizado, imagem mínima

### 🔥 Hot Reload com Air

**Configuração:**
- Arquivo `.air.toml` na raiz do projeto
- Watch automático de arquivos `.go`
- Exclusão de `tmp/`, `vendor/`, e arquivos de teste
- Build para `tmp/main` binary
- Restart automático em mudanças

**Vantagens:**
- Desenvolvimento ágil sem restart manual
- Feedback imediato de mudanças
- Configuração otimizada para Go

### 🗄️ Gerenciamento de Schema

**Estratégia:**
- Não usar migrations neste MVP
- Arquivo `scripts/schema.sql` com DDL completo
- Arquivo `scripts/seed.sql` com dados iniciais
- Comando Makefile: `make db-setup` (executa schema.sql)
- Comando Makefile: `make db-seed` (executa seed.sql)

---

## 8. Autenticação e Segurança

### 🔐 Protocolo
**OAuth2**

### 🔄 Fluxos Implementados

| Grant Type | Descrição | Uso |
|---|---|---|
| **Password Grant** | Usuário/senha | Login de usuários |
| **Client Credentials Grant** | Cliente/secret | Integrações de sistema |

### 🎫 Tokens

| Token | Duração | Propósito |
|---|---|---|
| **JWT Access Token** | 1 hora | Autenticação de requisições |
| **Refresh Token** | 90 dias | Renovação do access token (com rotation) |

### 📚 Bibliotecas Recomendadas (Go)

| Biblioteca | Versão | Propósito |
|---|---|---|
| `golang.org/x/oauth2` | Latest | Implementação OAuth2 |
| `github.com/golang-jwt/jwt/v5` | v5.x | Manipulação de JWT |
| `github.com/go-playground/validator/v10` | v10.x | Validação de dados |
| `github.com/gorilla/mux` | Latest | HTTP router |

---

## 9. Documentação da API

### 📖 Ferramenta
**Swagger (OpenAPI 3.0)**

### 🌐 Endpoint
```
GET /api/docs
```

### 🔧 Geração
Swagger gerado automaticamente no build ou via script Makefile.

### 🛣️ Endpoints Principais

| Método | Endpoint | Descrição |
|---|---|---|
| `POST` | `/auth/register` | Cadastro de usuário |
| `POST` | `/auth/login` | Login de usuário |
| `POST` | `/auth/refresh` | Renovação de token |
| `GET` | `/users` | Listagem de usuários |
| `GET` | `/users/{id}` | Buscar usuário por ID |
| `PUT` | `/users/{id}` | Atualizar usuário |
| `DELETE` | `/users/{id}` | Deletar usuário |

### 🔄 Versionamento de API

**Estratégia:**
- Versionamento em rotas: `/api/v1/`, `/api/v2/`
- Mesma infraestrutura compartilhada
- Máximo de 2-3 versões ativas simultaneamente
- Handlers organizados por versão: `infrastructure/http/v1/`, `infrastructure/http/v2/`
- Deprecation via headers: `X-API-Deprecation: true`
- Documentação Swagger separada por versão: `/api/v1/docs`, `/api/v2/docs`

---

## 10. Testes e Benchmark

### 🧪 Testes Unitários

**Obrigatórios para:**
- ✅ Camada `domain`
- ✅ Camada `application`

**Estratégia (Padrão Go):**
- **Arquivos `_test.go` no mesmo diretório do código** (não usar diretório `tests/` separado)
- Testes focados em regras de negócio (domain/application)
- **Sem uso de mocks** para testes unitários de domínio
- Testes de Value Objects, Entities e Use Cases puros
- Cobertura mínima de 80%

**Exemplo:**
```
internal/domain/user/
├── entity.go          → lógica da entidade
└── entity_test.go     → testes unitários
```

### 🔗 Testes de Integração

**Implementação:**
- HTTP endpoints via testcontainers ou requests locais
- Testes de fluxo completo (end-to-end)

### 📊 Benchmark

**Ferramenta:** Locust (repositório separado)

**Métricas Comparadas:**
- **RPS** (Requests Per Second)
- **Tempo médio** de resposta
- **P95** (95º percentil)
- **P99** (99º percentil)
- **Taxa de erro**

---

## 11. Repositório e Git

### 📦 Repositório
```
github.com/renatomagalhaes/user-crud-go
```

### 🌿 Estratégia de Branches

| Branch | Descrição |
|---|---|
| **`main`** | Produção estável |
| **`develop`** | Branch principal de desenvolvimento |
| **`feature/*`** | Funcionalidades novas |
| **`hotfix/*`** | Correções emergenciais |

### 📝 Convenção de Commits
**Conventional Commits**

**Exemplo:**
```
feat(auth): add jwt token validation
fix(user): resolve password hashing issue
docs(api): update swagger documentation
```

**Tipos:**
- `feat`: Nova funcionalidade
- `fix`: Correção de bug
- `docs`: Documentação
- `style`: Formatação
- `refactor`: Refatoração
- `test`: Testes
- `chore`: Tarefas de manutenção

---

## 12. Entregas e Roadmap

### 🚀 Fases de Desenvolvimento

| Fase | Descrição | Status |
|---|---|---|
| **1** | Configuração inicial do ambiente (Docker, Makefile, Air, Hot Reload) | ✅ |
| **2** | Implementação do domínio (Entity, VO, Repository Interface) | ⏳ |
| **3** | Implementação dos Use Cases | ⏳ |
| **4** | Implementação da camada de infraestrutura | ⏳ |
| **5** | Implementação da autenticação OAuth2 | ⏳ |
| **6** | Testes unitários e de integração | ⏳ |
| **7** | Testes de carga com Locust | ⏳ |
| **8** | Documentação final e comparação de desempenho | ⏳ |

### 📋 Critérios de Aceitação

- ✅ Código seguindo padrões SOLID e Clean Architecture
- ✅ Cobertura de testes mínima de 80%
- ✅ Documentação Swagger completa
- ✅ Performance benchmarks documentados
- ✅ Ambiente Docker funcional
- ✅ Autenticação OAuth2 implementada

---

## 13. Regras para Cursor AI

### 📋 Diretrizes de Desenvolvimento

1. **Sempre seguir a arquitetura hexagonal** definida neste documento
2. **Usar nomenclatura em inglês** para métodos e funções [[memory:2187488]]
3. **Nomes de campos do banco em inglês** [[memory:2172720]]
4. **Usar bibliotecas confiáveis e amplamente adotadas** [[memory:2172718]]
5. **Executar comandos via Docker Compose** quando possível [[memory:2172742]]
6. **Não incluir INSERTs em migrations** - usar seeders [[memory:2187484]]
7. **Documentação em português** com termos técnicos em inglês [[memory:2172729]]
8. **Testes no mesmo diretório** com sufixo `_test.go` (padrão Go - não usar diretório `tests/` separado)
9. **Testes unitários sem mocks** para camada domain
10. **Access token: 1 hora, Refresh token: 90 dias** com rotation
11. **Newsletter: single opt-in** (aceita no cadastro)
12. **Sessões: tabela `user_sessions`** para controle de dispositivos
13. **Versionamento: mesmo projeto**, rotas `/api/v1`, `/api/v2`
14. **SQL: usar `scripts/schema.sql`** e `scripts/seed.sql`
15. **Docker: organizar por ambiente** em `docker/dev/` e `docker/production/`
16. **Hot Reload: usar Air v1.40.4** para desenvolvimento com `.air.toml`
17. **Go: versão 1.22+** para compatibilidade com Air

### 🔧 Padrões Técnicos

- **Entities**: Sufixo `Entity`
- **Value Objects**: Sufixo `VO`
- **Use Cases**: Sufixo `UseCase`
- **DTOs**: Sufixo `DTO`
- **Repositories**: Sufixo `Repository`
- **Commits**: Conventional Commits
- **Testes**: Obrigatórios para domain e application
- **Cobertura**: Mínima de 80%

### 🏗️ Estrutura Obrigatória

```
project/
├── cmd/api/         # Ponto de entrada da aplicação
├── internal/        # Código interno da aplicação
│   ├── domain/      # Regras de negócio puras
│   │   ├── user/    # Contexto de usuário
│   │   └── auth/    # Contexto de autenticação
│   ├── application/ # Use cases e orquestração
│   │   ├── command/ # Commands CQRS
│   │   └── query/   # Queries CQRS
│   ├── infrastructure/ # Adaptadores concretos
│   │   ├── persistence/ # Implementações de repositório
│   │   ├── http/    # Handlers HTTP
│   │   │   ├── v1/  # API v1
│   │   │   └── v2/  # API v2
│   │   └── oauth/   # Implementação OAuth
│   └── config/      # Configurações
├── docker/          # Configurações Docker por ambiente
│   ├── dev/         # Ambiente de desenvolvimento
│   └── production/  # Ambiente de produção (futuro)
├── scripts/         # Scripts de banco de dados
├── .air.toml        # Configuração do Air para hot reload
├── Makefile         # Comandos de automação
└── go.mod           # Módulo Go
```

---

*Documento criado para servir como referência completa do projeto e regras para desenvolvimento com Cursor AI.*