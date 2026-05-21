import Link from 'next/link';
import { siteConfig } from '@/config/site.config';

export default function HomePage() {
  return (
    <main className="container-app section-padding">
      <div className="max-w-3xl">
        <h1 className="text-5xl md:text-6xl lg:text-7xl">{siteConfig.businessName}</h1>
        <p className="mt-6 text-lg text-text-secondary">{siteConfig.tagline}</p>
        <div className="mt-10 flex flex-wrap gap-4">
          <Link href="/turnos" className="btn-primary">
            Reservá tu turno
          </Link>
          <Link href="/servicios" className="btn-outline">
            Ver servicios
          </Link>
        </div>
      </div>
    </main>
  );
}
