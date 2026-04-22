import { PrismaClient, UserRole, UserStatus } from '@prisma/client';
import * as bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  const passwordHash = await bcrypt.hash('123456789', 10);

  const category = await prisma.faqCategory.upsert({
    where: { id: '00000000-0000-0000-0000-000000000001' },
    update: {},
    create: {
      id: '00000000-0000-0000-0000-000000000001',
      name: 'Getting Started',
      sortOrder: 1,
    },
  });

  await prisma.faq.upsert({
    where: { id: '00000000-0000-0000-0000-000000000101' },
    update: {},
    create: {
      id: '00000000-0000-0000-0000-000000000101',
      categoryId: category.id,
      question: 'How do I create a support ticket?',
      answer: 'Go to the Tickets tab, tap create, describe your issue, and submit it.',
      keywords: ['ticket', 'support', 'help'],
      sortOrder: 1,
    },
  });

  await prisma.user.upsert({
    where: { email: 'agent@example.com' },
    update: {
      passwordHash,
      displayName: 'Seed Agent',
      role: UserRole.AGENT,
      status: UserStatus.ACTIVE,
    },
    create: {
      email: 'agent@example.com',
      passwordHash,
      displayName: 'Seed Agent',
      role: UserRole.AGENT,
      status: UserStatus.ACTIVE,
    },
  });

  await prisma.user.upsert({
    where: { email: 'admin@163.com' },
    update: {
      passwordHash,
      displayName: 'Seed Admin',
      role: UserRole.ADMIN,
      status: UserStatus.ACTIVE,
    },
    create: {
      email: 'admin@163.com',
      passwordHash,
      displayName: 'Seed Admin',
      role: UserRole.ADMIN,
      status: UserStatus.ACTIVE,
    },
  });
}

main()
  .catch(async (error) => {
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
