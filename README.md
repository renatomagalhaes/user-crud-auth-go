# User CRUD with OAuth2 Authentication (Golang)

## 📋 Descrição

Aplicação CRUD de usuários com autenticação OAuth2 desenvolvida em Golang, utilizando arquitetura hexagonal, DDD e CQRS.

## 🏗️ Arquitetura

- **Hexagonal Architecture** (Ports & Adapters)
- **Domain-Driven Design (DDD)**
- **CQRS** (Command Query Responsibility Segregation)
- **Clean Architecture** e **SOLID** principles

## 🛠️ Tecnologias

- **Golang** 1.19+
- **MySQL 8**
- **Docker & Docker Compose**
- **OAuth2** com JWT
- **Swagger** (OpenAPI 3)

## 📊 Status

🚧 **Em Desenvolvimento** - MVP em construção

## 🚀 Como Iniciar

### Pré-requisitos
- Docker e Docker Compose instalados
- Make (opcional, mas recomendado)

### Estrutura do Projeto
```
project/
├── cmd/api/           # Código da aplicação
├── docker/            # Configurações Docker por ambiente
│   ├── dev/               # Ambiente de desenvolvimento
│   │   ├── Dockerfile.dev
│   │   └── docker-compose.yml
│   ├── production/        # Ambiente de produção (futuro)
│   └── README.md          # Documentação Docker
├── Makefile           # Comandos de automação
└── README.md
```

### Comandos Básicos

```bash
# Iniciar a aplicação
make up

# Ver logs em tempo real
make logs

# Parar a aplicação
make down

# Reconstruir containers
make build

# Acessar shell do container
make shell
```

### Testando a API

Após iniciar com `make up`, acesse:
- **URL**: http://localhost:8080
- **Resposta**: `{"message": "Hello World!"}`

### Hot Reload

O projeto está configurado com Air para hot reload. Modifique qualquer arquivo `.go` e veja as mudanças refletidas automaticamente sem reiniciar o container.

### Container

O container de desenvolvimento se chama `user-crud-auth-go-dev` para facilitar identificação e gerenciamento.

---

*Para informações detalhadas sobre arquitetura, requisitos e regras de desenvolvimento, consulte o arquivo [PROJECT_RULES.md](./PROJECT_RULES.md).*