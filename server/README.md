# Serv Ease Server

Node.js backend scaffold for the Serv Ease customer support app.

## Stack

- NestJS
- Prisma
- PostgreSQL
- JWT-based auth scaffold

## Setup

```bash
yarn install
cp .env.example .env
yarn prisma:generate
yarn build
yarn dev
```

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

## Scope

This scaffold currently includes:
- health endpoint
- auth/users/faqs/tickets module skeletons
- shared response and error handling
- Prisma schema for the first customer-support data model

The first pass is contract-first and keeps business logic intentionally light.
