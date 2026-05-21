/**
 * site.config.ts
 * -----------------------------------------------------------------------------
 * Business data del template. Para personalizar un cliente nuevo se editan
 * DOS archivos:
 *   1. Este: nombre, contacto, redes, horarios, reglas de booking, SEO.
 *   2. src/app/globals.css: paleta y design tokens (Tailwind v4 @theme).
 *
 * IMPORTANTE:
 *   - Solo data estática. No imports de Next/React.
 *   - Los colores y la tipografía NO viven acá: ver globals.css.
 */

export const siteConfig = {
  // ---------------------------------------------------------------------------
  // Identidad
  // ---------------------------------------------------------------------------
  businessName: 'Leo Aponte Peluquería',
  tagline: 'Cortes, color y uñas en el corazón de la ciudad',
  description:
    'Reservá tu turno online con Leo Aponte. Cortes, color, barba y uñas con turnos en pocos clicks.',

  // ---------------------------------------------------------------------------
  // Contacto
  // ---------------------------------------------------------------------------
  contact: {
    // Formato internacional sin +, sin espacios, sin guiones. Se usa para wa.me.
    whatsappNumber: '5491100000000',
    email: 'hola@ejemplo.com',
    phone: '+54 9 11 0000-0000',
    address: 'Av. Siempre Viva 123, CABA',
    googleMapsUrl: 'https://maps.google.com/?q=Av.+Siempre+Viva+123',
  },

  // ---------------------------------------------------------------------------
  // Redes sociales
  // ---------------------------------------------------------------------------
  social: {
    instagram: 'https://instagram.com/leoaponte.peluqueria',
    facebook: '',
    tiktok: '',
  },

  // ---------------------------------------------------------------------------
  // Horarios del local (fallback informativo y SEO)
  // ---------------------------------------------------------------------------
  // Los horarios efectivos para reservar viven en la tabla staff_schedules
  // (cada profesional define los suyos). Esto es para mostrar en /contacto y
  // como hint visual en la home.
  businessHours: [
    { day: 'Lunes', open: '09:00', close: '20:00' },
    { day: 'Martes', open: '09:00', close: '20:00' },
    { day: 'Miércoles', open: '09:00', close: '20:00' },
    { day: 'Jueves', open: '09:00', close: '20:00' },
    { day: 'Viernes', open: '09:00', close: '20:00' },
    { day: 'Sábado', open: '09:00', close: '18:00' },
    { day: 'Domingo', open: null, close: null }, // null = cerrado
  ],

  // ---------------------------------------------------------------------------
  // Booking — reglas del flujo de turnos
  // ---------------------------------------------------------------------------
  booking: {
    // Granularidad de los slots ofrecidos al cliente (en minutos).
    slotMinutes: 30,
    // Anticipación mínima para reservar (en horas). Evita turnos para "dentro de 5 min".
    minLeadHours: 2,
    // Ventana máxima a futuro (en días) para ver disponibilidad.
    maxAdvanceDays: 60,
  },

  // ---------------------------------------------------------------------------
  // SEO
  // ---------------------------------------------------------------------------
  seo: {
    titleTemplate: '%s | Leo Aponte Peluquería',
    defaultTitle: 'Leo Aponte Peluquería — Reservá tu turno online',
    ogImage: '/og.jpg',
    locale: 'es_AR',
  },
} as const;

export type SiteConfig = typeof siteConfig;
