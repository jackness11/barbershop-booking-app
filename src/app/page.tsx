import { siteConfig } from '@/config/site.config';

// Home placeholder: confirma que el entorno (Next + Tailwind + tokens) anda.
// Se reemplaza cuando arranque el flujo de reserva.
export default function HomePage() {
  return (
    <main className="container-app section-padding">
      <h1 className="text-4xl sm:text-5xl">{siteConfig.businessName}</h1>
      <p className="mt-3 text-lg text-text-secondary">{siteConfig.tagline}</p>

      <section className="mt-10 max-w-md card">
        <h2 className="text-xl">Horarios</h2>
        <ul className="mt-4 space-y-1 text-sm">
          {siteConfig.businessHours.map(({ day, open, close }) => (
            <li key={day} className="flex justify-between gap-4">
              <span className="text-text-secondary">{day}</span>
              <span>{open && close ? `${open} – ${close}` : 'Cerrado'}</span>
            </li>
          ))}
        </ul>
      </section>
    </main>
  );
}
