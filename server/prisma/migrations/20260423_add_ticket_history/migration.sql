-- CreateEnum
CREATE TYPE "TicketHistoryAction" AS ENUM ('CREATED', 'STATUS_CHANGED', 'ASSIGNED', 'REASSIGNED', 'PRIORITY_CHANGED', 'CATEGORY_CHANGED', 'REPLIED', 'CLOSED', 'REOPENED');

-- CreateEnum
CREATE TYPE "TicketHistoryActorRole" AS ENUM ('USER', 'AGENT', 'ADMIN', 'SYSTEM');

-- CreateTable
CREATE TABLE "ticket_histories" (
    "id" UUID NOT NULL,
    "ticket_id" UUID NOT NULL,
    "action" "TicketHistoryAction" NOT NULL,
    "actor_id" UUID,
    "actor_role" "TicketHistoryActorRole" NOT NULL,
    "old_value" TEXT,
    "new_value" TEXT,
    "metadata" JSONB,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ticket_histories_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "ticket_histories_ticket_id_idx" ON "ticket_histories"("ticket_id");

-- CreateIndex
CREATE INDEX "ticket_histories_created_at_idx" ON "ticket_histories"("created_at");

-- AddForeignKey
ALTER TABLE "ticket_histories" ADD CONSTRAINT "ticket_histories_ticket_id_fkey" FOREIGN KEY ("ticket_id") REFERENCES "tickets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ticket_histories" ADD CONSTRAINT "ticket_histories_actor_id_fkey" FOREIGN KEY ("actor_id") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;
