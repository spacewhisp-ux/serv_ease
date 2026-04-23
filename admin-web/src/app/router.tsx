import { createBrowserRouter, Navigate } from 'react-router-dom';

import { AdminLayout } from './AdminLayout';
import { LoginPage } from '../modules/auth/LoginPage';
import { RequireAuth } from '../modules/auth/RequireAuth';
import { CategoryFormPage } from '../modules/faq-categories/CategoryFormPage';
import { CategoryListPage } from '../modules/faq-categories/CategoryListPage';
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
          { path: '/tickets', element: <TicketListPage /> },
          { path: '/tickets/:id', element: <TicketDetailPage /> },
          { path: '/logs', element: <LogListPage /> },
        ],
      },
    ],
  },
  { path: '*', element: <Navigate to="/faqs" replace /> },
]);
