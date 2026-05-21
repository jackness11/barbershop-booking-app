import type { Metadata } from 'next';
import { Inter, Playfair_Display } from 'next/font/google';
import { siteConfig } from '@/config/site.config';
import './globals.css';

const inter = Inter({
  subsets: ['latin'],
  variable: '--font-inter',
  display: 'swap',
});

const playfair = Playfair_Display({
  subsets: ['latin'],
  variable: '--font-playfair',
  display: 'swap',
});

// Resuelve la URL base para Open Graph / Twitter Cards.
// Prioridad: NEXT_PUBLIC_SITE_URL (dominio prod) > VERCEL_URL (preview/prod auto) > localhost.
const siteUrl =
  process.env.NEXT_PUBLIC_SITE_URL ??
  (process.env.VERCEL_URL ? `https://${process.env.VERCEL_URL}` : 'http://localhost:3000');

export const metadata: Metadata = {
  metadataBase: new URL(siteUrl),
  title: {
    default: siteConfig.seo.defaultTitle,
    template: siteConfig.seo.titleTemplate,
  },
  description: siteConfig.description,
  openGraph: {
    title: siteConfig.seo.defaultTitle,
    description: siteConfig.description,
    locale: siteConfig.seo.locale,
    type: 'website',
    images: [{ url: siteConfig.seo.ogImage }],
  },
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="es" className={`${inter.variable} ${playfair.variable}`}>
      <body>{children}</body>
    </html>
  );
}
