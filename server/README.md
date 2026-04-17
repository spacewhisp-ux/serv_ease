# Serv Ease Server

Node.js backend scaffold for the Serv Ease customer support app.

## Stack

- NestJS
- Prisma
- PostgreSQL
- JWT auth with access/refresh tokens
- Yarn

## Quick Start

```bash
yarn install
cp .env.example .env
yarn prisma:generate
yarn build
yarn dev
```

## Local Database

A local PostgreSQL setup is provided via Docker Compose.

```bash
docker compose up -d
```

The default database settings match `.env.example`:
- host: `localhost`
- port: `5432`
- database: `serv_ease`
- user: `postgres`
- password: `postgres`

Compose file:
- `server/docker-compose.yml`

## Prisma Workflow

Generate client:

```bash
yarn prisma:generate
```

Apply migrations to a running local database:

```bash
yarn prisma:migrate:dev --name init
```

Seed sample FAQ and agent data:

```bash
yarn prisma:seed
```

An initial SQL migration has already been generated at:
- `server/prisma/migrations/202604171645_init/migration.sql`

## Commands

```bash
yarn dev
yarn build
yarn prisma:generate
yarn prisma:migrate:dev --name init
yarn prisma:seed
```

## Health Check

```bash
curl http://localhost:3000/v1/health
```

## Implemented API Surface

### Auth
- `POST /v1/auth/register`
- `POST /v1/auth/login`
- `POST /v1/auth/refresh`
- `POST /v1/auth/logout`

### Users
- `GET /v1/users/me`
- `PATCH /v1/users/me`
- `DELETE /v1/account`

### FAQ
- `GET /v1/faq-categories`
- `GET /v1/faqs`
- `GET /v1/faqs/:id`

### Tickets
- `POST /v1/tickets`
- `GET /v1/tickets`
- `GET /v1/tickets/:id`
- `POST /v1/tickets/:id/messages`
- `PATCH /v1/tickets/:id/close`

### Uploads
- `POST /v1/uploads/ticket-attachments`
- `POST /v1/uploads/:attachmentId/complete`

## Notes

- `users`, `tickets`, and `uploads` routes are protected by JWT.
- Attachments currently use a placeholder upload URL and are designed to be replaced with S3-compatible signed uploads later.
- Ticket attachments now support pre-upload, so the client can upload files before ticket creation.
- FAQ and ticket flows already use real Prisma queries; auth persists refresh-token sessions in the database.
