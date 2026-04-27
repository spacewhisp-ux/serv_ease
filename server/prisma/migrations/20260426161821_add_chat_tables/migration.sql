-- CreateTable
CREATE TABLE "chat_questions" (
    "id" UUID NOT NULL,
    "text" VARCHAR(255) NOT NULL,
    "reply" TEXT NOT NULL,
    "link_url" TEXT,
    "link_label" VARCHAR(120),
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "chat_questions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "chat_keywords" (
    "id" UUID NOT NULL,
    "keyword" VARCHAR(120) NOT NULL,
    "reply" TEXT NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "chat_keywords_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "chat_questions_is_active_sort_order_idx" ON "chat_questions"("is_active", "sort_order");

-- CreateIndex
CREATE UNIQUE INDEX "chat_keywords_keyword_key" ON "chat_keywords"("keyword");

-- CreateIndex
CREATE INDEX "chat_keywords_is_active_idx" ON "chat_keywords"("is_active");

-- CreateIndex
CREATE INDEX "chat_keywords_keyword_idx" ON "chat_keywords"("keyword");
