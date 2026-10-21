# 04 · Cumplimiento legal en Chile

Versión 1.0 · 21-10-2026

> Este documento recoge las normas chilenas que afectan al proyecto y qué hace el sistema para cumplirlas. No sustituye la revisión de un abogado chileno: antes de lanzar, los textos legales (términos y condiciones, política de privacidad, retracto) deben revisarse por un profesional. Fuentes consultadas al final.

## Resumen ejecutivo

| Norma | Qué exige al proyecto | Cómo lo cumplimos |
|---|---|---|
| **Ley 21.719** (nueva protección de datos; en vigor desde el **1-12-2026**, con una posible prórroga a 2027 en trámite) y **Ley 19.628** (vigente hoy) | Base legal para tratar datos, información clara, consentimiento para marketing, derechos ARCO + portabilidad + bloqueo, seguridad, aviso de brechas. | Política de privacidad, consentimientos granulares registrados, funciones de derechos en app/web, cifrado y minimización, registro de solicitudes (`data_requests`). |
| **Ley 19.496** (consumidor), **Ley 21.398** (Pro-Consumidor) y **Reglamento de Comercio Electrónico** (vigente desde 24-03-2022) | Información previa completa, precio total con IVA, confirmación escrita, derecho a retracto de 10 días, garantía legal de 6 meses, T&C aceptados antes de pagar, sin spam. | Checkout con información obligatoria, email de confirmación automático, flujo de retracto en el panel, textos legales, opt-out en cada mensaje comercial. |
| **SII** (inicio de actividades, IVA, boleta electrónica) | Para vender productos y servicios hay que tener inicio de actividades y emitir boleta electrónica por cada venta. | Datos de cada venta preparados para la boleta (`receipts`, IVA desglosado). **Requisito previo al lanzamiento de la tienda y del cobro online.** |
| **Ley 21.020** (tenencia responsable de mascotas) | Obliga al dueño (microchip y registro), no a la peluquería. | Campos opcionales de microchip/registro y vacuna antirrábica en la ficha. |
| **Políticas de Meta / WhatsApp Business** | Consentimiento (opt-in) para mensajes iniciados por el negocio, plantillas aprobadas, verificación del negocio. | Consentimiento registrado antes de cualquier plantilla; bot solo responde a quien escribe. |
| **Políticas de Google Play** | Política de privacidad pública, formulario de seguridad de datos, pruebas cerradas para cuentas nuevas. | Página `/legal/privacidad`, formulario *Data safety*, plan de pruebas con testers. |

## 1. Protección de datos personales

**Hoy** rige la Ley 19.628 (1999). La **Ley 21.719**, publicada el 13-12-2024, la reescribe casi por completo y crea la Agencia de Protección de Datos Personales; entra en vigor el 1 de diciembre de 2026 (24 meses después de su publicación), aunque existe un proyecto para aplazarla a diciembre de 2027 y en mayo de 2026 el Senado rechazó la primera terna del consejo de la Agencia. El sistema se diseña para cumplir desde ya con la 21.719, que es el estándar más exigente.

Qué tratamos: datos de identificación y contacto del cliente (nombre, email, teléfono, dirección), RUT opcional, historial de citas y compras, datos de pago (solo los que devuelve la pasarela: últimos 4 dígitos y autorización; **nunca** el número completo de la tarjeta), mensajes de WhatsApp. Los datos de los perros no son datos personales, pero están vinculados a su dueño.

Qué hace el sistema:

1. **Bases de licitud**: ejecución del contrato (citas, pedidos, avisos transaccionales) y consentimiento expreso para marketing (recordatorios comerciales por email y WhatsApp), registrado con fecha, versión, canal e IP (`consents`).
2. **Información**: política de privacidad accesible desde app, web y bot, en lenguaje claro: responsable, finalidades, plazos de conservación, destinatarios (IONOS en la UE, Meta, Transbank, Mercado Pago, Google/Firebase), transferencias internacionales, derechos y cómo ejercerlos.
3. **Derechos de los titulares** (acceso, rectificación, supresión, oposición, portabilidad, bloqueo): botones en el perfil (app y web) y registro en `data_requests` con plazo de respuesta; la supresión anonimiza la cuenta y conserva solo lo exigido por obligaciones tributarias (ventas y boletas).
4. **Seguridad**: HTTPS, contraseñas con hash, cifrado de teléfono y RUT, control de acceso por rol, registro de actividad, copias de seguridad cifradas, mínimos datos en logs. Procedimiento interno para notificar brechas a la Agencia y a los afectados.
5. **Minimización y conservación**: solo se piden datos necesarios; cuentas inactivas más de 3 años se anonimizan (plazo configurable); registros de WhatsApp conservados 12 meses.
6. **Menores**: la app y la web son para mayores de 18 años (declaración en el registro). Si un menor escribe por WhatsApp no se crean datos de menores.
7. **Transferencias internacionales**: el servidor está en la Unión Europea (IONOS) y las pasarelas/WhatsApp tratan datos fuera de Chile; se informa en la política y se contrata con proveedores que ofrecen garantías (cláusulas y políticas de privacidad propias). Delegado de protección de datos: voluntario para una pyme; se designa a Paulina como responsable de contacto.

## 2. Consumidor y comercio electrónico

Normas: Ley 19.496 sobre Protección de los Derechos de los Consumidores, modificada por la Ley 21.398 (Pro-Consumidor, 2021) y el Reglamento de Comercio Electrónico (vigente desde el 24-03-2022). Fiscaliza el SERNAC.

Obligaciones y cómo se implementan:

| Obligación | Implementación |
|---|---|
| Identificación del proveedor: nombre/razón social, RUT, domicilio, medios de contacto. | Pie de página, T&C y email de confirmación (`settings.business.*`). |
| Información previa: características del producto/servicio, precio total **con IVA**, costo de despacho, plazos de entrega, medios de pago, stock/disponibilidad. | Ficha de producto y resumen del checkout; precios siempre finales (RN-08). |
| Aceptación de términos y condiciones **antes** del pago, con acceso fácil al texto. | Casilla obligatoria en el checkout; versión guardada en `orders.terms_version`. |
| **Confirmación escrita** de la compra (de lo contrario el plazo de retracto sube de 10 a 90 días). | Email automático al pagar con detalle, precios, entrega y cómo ejercer el retracto (`orders.confirmation_sent_at`). |
| **Derecho a retracto**: productos, 10 días desde la recepción, sin expresión de causa; servicios, hasta antes de la prestación salvo exclusión expresa e informada; algunas excepciones por reglamento (productos perecederos, personalizados, sellados por higiene abiertos…). | Botón "Solicitar retracto" en el pedido; estados `retracto`/`reembolsado`; reembolso por la misma pasarela; política de retracto en `/legal/retracto`. Para servicios de peluquería se informa claramente la política de cancelación (RN-04). |
| **Garantía legal de 6 meses** por fallas del producto (cambio, reparación o devolución del dinero a elección del cliente). | Política de cambios y devoluciones; gestión desde el panel. |
| Comprobante de la operación. | Email de confirmación + boleta electrónica cuando aplique. |
| Publicidad y promociones: veracidad, condiciones claras. | Textos del panel; precios tachados solo con precio anterior real. |
| Comunicaciones comerciales (art. 28 B): identificar al remitente, asunto claro y **mecanismo de desuscripción**; no enviar a quien lo rechazó. | Cada email/WhatsApp comercial lleva "responde BAJA" o enlace de baja; consentimiento previo y registro de retiradas. |
| Atención de reclamos. | Canal de contacto visible; respuesta por email y WhatsApp. |

## 3. Tributario (SII)

- Para vender productos y prestar servicios de forma habitual hay que tener **inicio de actividades** en el SII (puede ser persona natural con giro o empresa) y emitir **boleta electrónica** por cada venta; desde 2023 los servicios en general están afectos a IVA (19 %), por lo que la peluquería también.
- **Estado actual: la pyme no tiene inicio de actividades.** Por eso:
  - el desarrollo avanza, pero la **tienda con cobro online y el cobro de servicios por la app no se activan en producción** hasta que exista inicio de actividades y boleta electrónica;
  - el sistema ya guarda, por cada venta, el neto, el IVA y el RUT del cliente (si lo da) para emitir la boleta sin trabajo extra;
  - la emisión se hará con el **sistema gratuito del SII** (coste cero); un proveedor con API sería opcional y de pago.
- Transbank y Mercado Pago no exigen inicio de actividades para contratar, pero sí para la boleta; en cualquier caso se recomienda formalizarse antes de activar cobros.
- Régimen sugerido para consultar con un contador: Pro Pyme (Régimen 14 D) y pago de IVA sobre lo cobrado.

## 4. Mascotas (Ley 21.020, tenencia responsable)

La ley obliga a los dueños a identificar a sus perros con microchip e inscribirlos en el Registro Nacional de Mascotas; no impone obligaciones a la peluquería. La ficha del perro incluye campos opcionales (microchip, número de registro, vacuna antirrábica) como ayuda al dueño y para prevención sanitaria en el local (recomendación, no requisito).

## 5. WhatsApp y Meta

- Uso de la **WhatsApp Business Platform** oficial (nunca librerías no oficiales que automatizan la app normal: violan las condiciones de uso y Meta bloquea el número).
- **Opt-in** explícito y registrado antes de enviar cualquier mensaje iniciado por el negocio; el bot solo responde a quien le escribe.
- Plantillas aprobadas por Meta y correctamente categorizadas (utilidad / marketing); respeto a los bloqueos y a las bajas ("BAJA").
- Verificación del negocio en Meta Business cuando esté formalizado (nombre legal y documentos).
- Costes: ver `05-plan-de-fases-y-costes.md`.

## 6. Google Play

- Cuenta de desarrollador: US$ 25 una sola vez. Decisión (21-10-2026): la cuenta será personal y a nombre de Jaime, que la paga; su nombre legal aparecerá públicamente como desarrollador en la ficha de Play. Aunque la app se publique bajo su cuenta, el **responsable del tratamiento** de los datos de los clientes sigue siendo el negocio de Paulina, y así debe constar en la política de privacidad y en el formulario de seguridad de datos.
- Las cuentas **personales creadas después del 13-11-2023** deben pasar una **prueba cerrada con al menos 12 testers durante 14 días seguidos** antes de poder publicar en producción (las cuentas de organización no, pero exigen número D-U-N-S). Conviene reclutar 15–20 personas (familia, clientes de confianza).
- Política de privacidad pública enlazada en la ficha, formulario *Data safety* coherente con los datos que trata la app, permisos mínimos (notificaciones, cámara/galería solo para fotos).
- Pagos: los bienes físicos y los servicios presenciales pueden cobrarse con pasarelas externas (Webpay/Mercado Pago); no aplica la facturación de Google Play.

## 7. Textos legales a redactar (fase 5)

1. Política de privacidad (Ley 21.719) — app, web y versión corta para WhatsApp.
2. Términos y condiciones de la tienda y de los servicios de peluquería (incluye política de cancelación de citas).
3. Política de retracto, cambios, devoluciones y garantía legal.
4. Aviso de consentimiento para recordatorios por email y WhatsApp (texto del opt-in).
5. Aviso de cookies/tecnologías (informativo; Chile no exige banner, sí informar).
6. Procedimiento interno de derechos del titular y de brechas de seguridad.

## Fuentes consultadas (octubre de 2026)

- Entrada en vigor de la Ley 21.719 el 1 de diciembre de 2026 y proyecto de prórroga: Diario Constitucional (12-06-2026), Global Suite Solutions, AZ Abogados, Academia Judicial.
- Derecho a retracto (10 días; 90 si no hay confirmación escrita), Reglamento de Comercio Electrónico (24-03-2022) y garantía legal de 6 meses (Ley 21.398): SERNAC "Tus derechos en el comercio electrónico", Carey, abogados.com.ar.
- Transbank no exige inicio de actividades para contratar; comisiones Webpay Plus 1,49–2,50 % + IVA y Mercado Pago 2,99 % + IVA: La Tercera (Laboratorio de Contenidos), Transbank (preguntas frecuentes), simplo.cl (tarifas a junio 2026).
- Precios de WhatsApp Business Platform por mensaje (desde julio 2025) y fin de los mensajes de servicio gratuitos ilimitados (1.000 gratis al mes por número desde octubre 2026, luego ≈ CLP 15–22 por mensaje): T13 (02-10-2026), Ecosistema Startup, Wati, Sleekflow.
- Requisito de 12 testers durante 14 días para cuentas personales de Google Play creadas después del 13-11-2023: Centro de ayuda de Google Play Console, Android Developers Blog.
