import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';

import { App } from './app/App';
import { ConfigurationErrorPage } from './pages/ConfigurationErrorPage';
import { getEnvironment } from './config/environment';
import './styles/index.css';

const rootElement = document.getElementById('root');

if (!rootElement) {
  throw new Error('The application root element was not found.');
}

let application = <App />;

try {
  getEnvironment();
} catch (error: unknown) {
  console.error(
    error instanceof Error ? error.message : 'Invalid public environment configuration.',
  );
  application = <ConfigurationErrorPage />;
}

createRoot(rootElement).render(<StrictMode>{application}</StrictMode>);
