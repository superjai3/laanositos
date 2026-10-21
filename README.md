# Laanositos — Peluquería canina

Plataforma para la peluquería canina **Laanositos** (Chile): app Android, web con panel de administración y chatbot de WhatsApp, con agenda de baños y cortes, historial de cada perro, tienda con carrito, pagos online y recordatorios automáticos.

> Estado: **Fase 0 — diseño y decisiones** (completada el 21-10-2026). El código empieza en la Fase 1 (ver `docs/05-plan-de-fases-y-costes.md`).

## Decisiones tomadas

| Tema | Decisión | Motivo |
|---|---|---|
| Servidor | **IONOS Hosting Plus** (hosting compartido Linux que ya tenemos: PHP, MariaDB, SSH, cron) | Coste cero: ya está contratado. No ejecuta Java/Kotlin en el servidor, por eso el backend va en PHP. |
| Backend + web | **PHP con Laravel** (API REST + web + panel admin + webhooks) | Funciona en hosting compartido, SDK oficiales de Transbank y Mercado Pago en PHP, scheduler con el cron de IONOS. |
| Base de datos | **MariaDB** incluida en el plan de IONOS (2 GB por base de datos) | Gratis, sin pausas por inactividad ni límites de uso. |
| App Android | **Kotlin + Jetpack Compose** | Lo pedido; consume la misma API que la web. |
| Web pública | Laravel (Blade + Livewire + Tailwind), responsive, instalable como PWA | Misma base de datos y API que la app → siempre sincronizadas. |
| Chatbot WhatsApp | **WhatsApp Cloud API de Meta** (bot de menús, sin IA de pago) | Oficial y gratis de configurar; 1.000 mensajes de servicio gratis al mes por número. |
| Pagos | **Webpay Plus (Transbank) y Mercado Pago (Checkout Pro)** | Sin coste fijo; solo comisión por venta. El cliente elige al pagar. |
| Email | SMTP de IONOS (incluido) | Gratis. |
| Notificaciones push | Firebase Cloud Messaging | Gratis. |
| Boleta electrónica | Sistema gratuito del SII (pendiente: la pyme aún no tiene inicio de actividades) | Requisito legal previo a vender; ver `docs/04-cumplimiento-legal-chile.md`. |
| Marca | **Laanositos** (con doble A, como el logo) | Confirmado por Jaime. |
| Repositorio y backup | GitHub `superjai3/laanositos` (privado) + copia en `E:\Proyectos\Laanositos` | Regla del proyecto. |
| Coste | **Política de coste cero**: solo herramientas gratuitas | Ver excepciones inevitables en `docs/05-plan-de-fases-y-costes.md`. |

## Estructura del repositorio

```
laanositos/
├── README.md
├── docs/
│   ├── 01-especificacion-funcional.md     Qué hace el sistema (actores, módulos, reglas, flujos)
│   ├── 02-arquitectura-tecnica.md          Cómo se construye (stack, API, integraciones, despliegue)
│   ├── 03-modelo-de-datos.md               Entidades y relaciones
│   ├── 04-cumplimiento-legal-chile.md      Leyes chilenas que aplican y qué hacemos en cada una
│   └── 05-plan-de-fases-y-costes.md        Fases, prerrequisitos y política de coste cero
├── database/
│   └── schema.sql                          Esquema MariaDB de referencia (las migraciones Laravel salen de aquí)
├── branding/
│   ├── README.md                           Paleta, tipografías y uso del logo
│   ├── logo-laanositos.svg                 Logo principal (fondo turquesa)
│   ├── logo-laanositos-transparente.svg    Logo sin fondo
│   ├── logo-horizontal.svg                 Versión horizontal para cabeceras web
│   ├── icono-app-foreground.svg            Capa frontal del icono adaptativo Android
│   ├── icono-app-foreground-plano.svg      Misma capa, apta para importar como Vector Asset
│   ├── icono-app-background.svg            Capa de fondo del icono adaptativo Android
│   ├── icono-app-monochrome.svg            Icono monocromo (temas Android 13+)
│   ├── icono-app-preview.svg               Vista previa del icono recortado
│   ├── logo-original.png                   Logo original recibido
│   ├── build_logo.py                       Script que genera los SVG (texto en trazados)
│   └── png/                                Renders PNG listos para usar
├── backend/                                (Fase 1) Laravel: API, web, panel admin, webhooks, chatbot
└── android/                                (Fase 3) App Kotlin
```

## Cómo seguir

1. Revisar y aprobar los documentos de `docs/` con Paulina (hay una lista de preguntas abiertas al final de `01-especificacion-funcional.md`).
2. Completar los prerrequisitos de `docs/05-plan-de-fases-y-costes.md` (cuentas de Meta, Transbank, Mercado Pago, Google Play, SII).
3. Fase 1: crear el proyecto Laravel en `backend/`, migraciones a partir de `database/schema.sql` y despliegue en IONOS.

## Reglas del proyecto

- Todo el código y la documentación viven en este repositorio y se copian a `E:\Proyectos\Laanositos`.
- Solo herramientas gratuitas; cualquier coste se discute antes y se anota en `docs/05-plan-de-fases-y-costes.md`.
- Cumplimiento de la legislación chilena en todo lo que se construye (ver `docs/04-cumplimiento-legal-chile.md`).
- Cada cambio relevante se registra en el README o en `docs/`.
