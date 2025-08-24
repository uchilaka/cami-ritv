import { createRoot } from 'react-dom/client';
import InvoiceSearchApp from '@/features/InvoiceManager/InvoiceSearch/InvoiceSearch';
import { createElement } from 'react';
const container = document.querySelector<HTMLDivElement>('#invoice-search');
if (container) {
  const root = createRoot(container);
  root.render(createElement(InvoiceSearchApp));
  console.debug('<<< invoice_search_app.tsx entrypoint loaded! >>>');
} else {
  console.warn('<<< invoice_search_app.tsx entrypoint: No container found >>>');
}
