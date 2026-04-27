import { createBrowserRouter, Navigate } from 'react-router-dom';

import { AdminLayout } from './AdminLayout';
import { LoginPage } from '../modules/auth/LoginPage';
import { RequireAuth } from '../modules/auth/RequireAuth';
import { CategoryFormPage } from '../modules/faq-categories/CategoryFormPage';
import { CategoryListPage } from '../modules/faq-categories/CategoryListPage';
import { ChatKeywordFormPage } from '../modules/chat-keywords/ChatKeywordFormPage';
import { ChatKeywordListPage } from '../modules/chat-keywords/ChatKeywordListPage';
import { ChatQuestionFormPage } from '../modules/chat-questions/ChatQuestionFormPage';
import { ChatQuestionListPage } from '../modules/chat-questions/ChatQuestionListPage';
import { FaqFormPage } from '../modules/faqs/FaqFormPage';
import { FaqListPage } from '../modules/faqs/FaqListPage';
import { LogListPage } from '../modules/logs/LogListPage';
import { TicketDetailPage } from '../modules/tickets/TicketDetailPage';
import { TicketListPage } from '../modules/tickets/TicketListPage';

export const router = createBrowserRouter([
  { path: '/login', element: <LoginPage /> },
  {
    element: <RequireAuth />,
    children: [
      {
        element: <AdminLayout />,
        children: [
          { index: true, element: <Navigate to="/faqs" replace /> },
          { path: '/faqs', element: <FaqListPage /> },
          { path: '/faqs/new', element: <FaqFormPage /> },
          { path: '/faqs/:id/edit', element: <FaqFormPage /> },
          { path: '/categories', element: <CategoryListPage /> },
          { path: '/categories/new', element: <CategoryFormPage /> },
          { path: '/categories/:id/edit', element: <CategoryFormPage /> },
          { path: '/chat-questions', element: <ChatQuestionListPage /> },
          { path: '/chat-questions/new', element: <ChatQuestionFormPage /> },
          { path: '/chat-questions/:id/edit', element: <ChatQuestionFormPage /> },
          { path: '/chat-keywords', element: <ChatKeywordListPage /> },
          { path: '/chat-keywords/new', element: <ChatKeywordFormPage /> },
          { path: '/chat-keywords/:id/edit', element: <ChatKeywordFormPage /> },
          { path: '/tickets', element: <TicketListPage /> },
          { path: '/tickets/:id', element: <TicketDetailPage /> },
          { path: '/logs', element: <LogListPage /> },
        ],
      },
    ],
  },
  { path: '*', element: <Navigate to="/faqs" replace /> },
]);
