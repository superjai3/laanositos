# 05 · Plan de fases, prerrequisitos y costes

Versión 1.0 · 21-10-2026

## 1. Política de coste cero

Regla del proyecto: **solo herramientas gratuitas**. Todo lo que se usa es gratis o ya está pagado (IONOS). Hay tres puntos donde "gratis" tiene límites; dos ya están decididos (los asume Jaime) y el tercero (WhatsApp) queda en modo gratuito:

| Concepto | Coste | Alternativa gratuita | Decisión |
|---|---|---|---|
| Publicar la app en **Google Play** | US$ 25, una sola vez (cuenta de desarrollador) | Descargar el APK desde la web (instalación manual, menos cómoda y sin actualizaciones automáticas) | **Decidido (21-10-2026): Jaime paga los US$ 25 y crea la cuenta de desarrollador a su nombre; la app se publica bajo su propiedad.** |
| **WhatsApp** iniciado por el negocio (recordatorios automáticos por plantilla) | Coste por mensaje (céntimos de dólar; varía por categoría y país). Además, desde octubre de 2026 los mensajes de servicio son gratis solo hasta 1.000 al mes por número; después ≈ CLP 15–22 cada uno | Recordatorios automáticos por **email y push** (gratis) y envío por WhatsApp **manual de un toque** desde el panel con el mensaje ya escrito | Modo gratuito por defecto |
| **Dominio propio** `lanositos.cl` | CLP 9.990 al año (NIC Chile, tarifa vigente desde noviembre de 2023) | Subdominio gratuito de un dominio que ya pagamos | **Decidido (21-10-2026): Jaime compra `lanositos.cl` a su nombre y lo paga él.** |

No son costes de herramientas, pero hay que saberlo: las pasarelas cobran **comisión por venta** (Webpay Plus 1,49–2,50 % + IVA según volumen; Mercado Pago 2,99 % + IVA con tarjeta, tarifas publicadas a junio 2026), descontada de cada abono. No tienen cuota fija ni de alta.

Todo lo demás es gratis: IONOS (ya contratado: hosting, MariaDB, SSL, email SMTP, cron), Laravel, MariaDB, Android Studio, Kotlin, Firebase (Messaging y Crashlytics), GitHub (repos privados y Actions dentro de la cuota), GitHub Actions, Meta WhatsApp Cloud API (configuración y conversaciones iniciadas por el cliente dentro del límite), sistema de boleta gratuito del SII, Mermaid, Postman/Bruno, VS Code, Figma (plan gratuito), ambientes de prueba de Transbank y Mercado Pago.

## 2. Fases

Estimaciones orientativas para dos personas a tiempo parcial (Jaime y Andrés), con ayuda de Claude. Cada fase termina con algo que se puede probar.

| Fase | Entregable | Duración estimada | Depende de |
|---|---|---|---|
| **0 · Diseño** (esta entrega) | Documentos, modelo de datos, logo | Hecho | — |
| **1 · Backend base** | Proyecto Laravel desplegado en IONOS (subdominio de pruebas): migraciones, auth, perros, historial, servicios, agenda y disponibilidad, panel admin básico, API v1, emails | 3–4 semanas | Acceso SSH y BD en IONOS, subdominio |
| **2 · Tienda y pagos** | Catálogo, carrito, checkout, pedidos, Webpay Plus y Mercado Pago en ambiente de pruebas, emails de confirmación, stock, retracto | 2–3 semanas | Cuentas de desarrollador de Transbank y Mercado Pago (gratis) |
| **3 · App Android** | App Kotlin con login, perros, historial, agendar, tienda, carrito, pago en navegador, push; prueba cerrada en Google Play (12 testers, 14 días) o APK | 4–5 semanas | Cuenta Google Play (si se publica), proyecto Firebase |
| **4 · WhatsApp** | Número en la Cloud API, webhook, bot de menús (agendar, citas, tienda, perros, hablar con Paulina), plantillas aprobadas (sin activar) | 2–3 semanas | Meta Business, número dedicado |
| **5 · Recordatorios, legal y salida a producción** | Motor de recordatorios y resumen diario, textos legales revisados, política de privacidad en Play, boleta (si hay SII), copias de seguridad, pruebas con clientes reales, producción | 2–3 semanas | Inicio de actividades en el SII, revisión legal |

Total orientativo: **4 a 5 meses** de trabajo a tiempo parcial. Las fases 3 y 4 pueden solaparse con la 2 si Andrés y Jaime se reparten el trabajo (por ejemplo Jaime backend/web y Andrés app).

### Orden recomendado dentro de la fase 1
1. Proyecto Laravel + Docker/Herd local + repo con GitHub Actions (tests).
2. Migraciones y modelos desde `database/schema.sql`; seeders de ejemplo.
3. Autenticación (web + Sanctum), consentimientos, perfil y derechos.
4. Perros e historial (con fotos).
5. Servicios, horarios, disponibilidad, citas; agenda del panel.
6. Emails (SMTP IONOS) y despliegue en el subdominio de pruebas.

## 3. Prerrequisitos (lo que hay que conseguir, casi todo gratis)

| Qué | Quién | Coste | Cuándo |
|---|---|---|---|
| Subdominio de pruebas en IONOS + base de datos MariaDB + usuario SSH | Jaime | 0 | Fase 1 |
| Dominio `lanositos.cl` registrado en NIC Chile a nombre de Jaime, con DNS apuntando a IONOS | Jaime | CLP 9.990/año (lo paga Jaime) | Fase 1 |
| Email del negocio (en IONOS, p. ej. `hola@…`) | Jaime | 0 | Fase 1 |
| Cuenta de desarrollador Transbank (ambiente de integración) y luego contrato Webpay Plus (código de comercio) | Jaime / Paulina | 0 (solo comisión) | Fase 2 |
| Cuenta Mercado Pago del negocio + credenciales de desarrollador | Paulina / Jaime | 0 (solo comisión) | Fase 2 |
| Proyecto Firebase (Messaging, Crashlytics) | Jaime | 0 | Fase 3 |
| Cuenta de desarrollador de Google Play a nombre de Jaime (cuenta personal nueva: prueba cerrada obligatoria antes de publicar) | Jaime | US$ 25 (lo paga Jaime) | Fase 3 |
| 15–20 testers para la prueba cerrada de Google Play (mínimo 12 durante 14 días seguidos) | Paulina (clientes de confianza y familia) | 0 | Fase 3 |
| Meta Business + app de desarrollador + número de WhatsApp dedicado (SIM o número virtual propio; no puede usarse en la app normal) | Paulina / Jaime | 0 | Fase 4 |
| Inicio de actividades en el SII y boleta electrónica (sistema gratuito del SII) | Paulina (con contador) | 0 (trámite) | Antes de cobrar online |
| Revisión de textos legales por abogado chileno | Paulina | depende | Fase 5 |
| Catálogo de servicios con precios por tamaño, horario, fotos y productos | Paulina | 0 | Fase 1–2 |

## 4. Gestión del proyecto

- **Repositorio**: `superjai3/lanositos` (privado). Ramas: `main` (estable), `develop` (integración), `feature/*`. Pull requests con revisión antes de mezclar a `main`.
- **Copia de seguridad**: después de cada sesión de trabajo se sincroniza `E:\Proyectos\Lanositos` con el repositorio; las copias de la base de datos de producción se guardan en `E:\Proyectos\Lanositos\_respaldos` (cifradas).
- **Tareas**: GitHub Issues + Projects (gratis) con una tarjeta por requisito (RF-xx).
- **Documentación**: `docs/` se actualiza en cada fase; el README registra los cambios relevantes.
- **Pruebas**: PHPUnit/Pest en backend (GitHub Actions), pruebas de UI en Compose, prueba cerrada con usuarios reales antes de producción.

## 5. Riesgos y cómo se mitigan

| Riesgo | Mitigación |
|---|---|
| Hosting compartido limita procesos y recursos | Colas por cron, caché, imágenes optimizadas; si un día se queda corto, migrar a un VPS es un cambio de servidor, no de código. |
| Número de WhatsApp bloqueado o costes inesperados | Uso exclusivo de la API oficial, plantillas desactivadas por defecto, contador de mensajes en el panel con aviso al acercarse a 1.000/mes. |
| La pyme no se formaliza a tiempo | La agenda y el historial pueden salir primero (sin cobros online); la tienda espera al SII. |
| Pocos testers para Google Play | Alternativa APK; o cuenta de organización más adelante. |
| Dependencia de una sola persona | Documentación en `docs/`, código estándar (Laravel, Compose), sin personalizaciones exóticas. |
