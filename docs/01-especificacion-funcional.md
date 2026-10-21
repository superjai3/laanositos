# 01 · Especificación funcional

Versión 1.0 · 21-10-2026 · Proyecto Lanositos (peluquería canina, Chile)

## 1. Objetivo

Que los clientes de Lanositos puedan, desde la app Android, la web o WhatsApp:

- registrarse y mantener la ficha de cada uno de sus perros,
- agendar baños y cortes y ver el historial de cada perro,
- comprar artículos para perros con carrito y pago online,
- recibir recordatorios cuando a su perro "le toca" volver;

y que Paulina (administradora) gestione agenda, historial, tienda, pedidos y recordatorios desde un panel web, recibiendo también sus propios avisos.

Los tres canales (app, web, WhatsApp) comparten la misma base de datos y la misma API, por lo que cualquier cita, compra o cambio hecho en un canal aparece de inmediato en los otros.

## 2. Actores

| Actor | Descripción |
|---|---|
| **Cliente** | Dueño/a de uno o más perros. Usa app, web o WhatsApp. Mayor de 18 años. |
| **Administradora (Paulina)** | Gestiona todo desde el panel web. Recibe avisos por email, WhatsApp (su propio teléfono) y push. |
| **Personal** (futuro) | Peluquero/a adicional con agenda propia. Previsto en el modelo de datos, no en la v1. |
| **Sistema** | Tareas automáticas: recordatorios, avisos, cálculo de disponibilidad, conciliación de pagos. |
| **Bot de WhatsApp** | Atiende al cliente por menús; crea citas y pedidos; deriva a Paulina cuando hace falta. |

## 3. Canales

| Canal | Público | Funciones |
|---|---|---|
| App Android (Kotlin) | Clientes | Todo lo del cliente + notificaciones push. |
| Web pública | Clientes | Las mismas funciones que la app, sin instalar nada. Instalable como PWA. |
| Panel de administración (web, `/admin`) | Paulina | Gestión completa. |
| WhatsApp | Clientes | Agendar, ver citas, comprar, consultar sus perros, hablar con Paulina. |
| Email | Clientes y admin | Confirmaciones, recordatorios, comprobantes, recuperación de contraseña. |

## 4. Requisitos funcionales

### 4.1 Cuentas y perfil (RF-01 a RF-08)

- RF-01 Registro con nombre, email, teléfono móvil chileno (+56 9), contraseña. Verificación del email por enlace.
- RF-02 Inicio de sesión con email o teléfono + contraseña. Recuperación de contraseña por email. (Opcional fase 2: Google Sign-In, gratis.)
- RF-03 Al registrarse el cliente acepta Términos y Condiciones y Política de Privacidad (versión y fecha quedan guardadas) y decide por separado si quiere recordatorios por email y por WhatsApp.
- RF-04 Perfil editable: nombre, teléfono, email, RUT (opcional, solo para boleta), dirección de despacho (opcional).
- RF-05 Desde el perfil el cliente puede descargar sus datos, pedir corrección, eliminar su cuenta y cambiar sus consentimientos (derechos de la Ley 21.719, ver doc 04).
- RF-06 Un cliente que llega primero por WhatsApp puede crear una cuenta mínima (nombre + teléfono) desde el chat; después puede completar email y contraseña en la web o la app.
- RF-07 La administradora puede crear clientes manualmente (para quien llama por teléfono o llega al local).
- RF-08 Roles: `cliente`, `admin`, `staff`.

### 4.2 Perros (RF-10 a RF-14)

- RF-10 Cada cliente registra uno o más perros. Ficha: nombre, raza (lista + "mestizo"), sexo, fecha de nacimiento aproximada, tamaño (pequeño / mediano / grande / gigante) y peso, tipo de pelo (corto, largo, rizado, doble capa…), color, foto.
- RF-11 Datos de cuidado: alergias, temperamento/observaciones (por ejemplo "se asusta con la secadora"), fecha de la última vacuna antirrábica, número de microchip y/o Registro Nacional de Mascotas (opcional; obligatorio para el dueño por la Ley 21.020, no para la peluquería).
- RF-12 Un perro puede marcarse como inactivo (fallecido, regalado) sin borrar su historial.
- RF-13 La administradora ve y edita cualquier ficha; el cliente solo las suyas.
- RF-14 La ficha muestra: próxima cita, última visita, "le toca" (ver recordatorios) y el historial completo.

### 4.3 Historial de visitas (RF-20 a RF-24)

- RF-20 Cada visita registra: fecha, perro, servicios realizados (uno o varios), precio cobrado, peluquera, observaciones (estado del pelo y piel, nudos, comportamiento, recomendaciones), fotos antes/después y "próxima visita recomendada".
- RF-21 Una cita completada genera su visita automáticamente; Paulina completa observaciones y fotos.
- RF-22 Paulina puede registrar visitas sin cita previa (cliente que llega al local).
- RF-23 El cliente ve el historial de cada perro en orden cronológico, con fotos; no puede editarlo.
- RF-24 El historial se puede exportar (PDF/CSV) desde el panel.

### 4.4 Servicios y agenda (RF-30 a RF-41)

- RF-30 Catálogo de servicios configurable: baño, corte, baño + corte, deslanado, corte de uñas, limpieza de oídos, etc. Cada servicio tiene duración y precio **por tamaño de perro**.
- RF-31 Horario de atención configurable por día de la semana, con bloques cerrados (almuerzo) y días festivos/vacaciones.
- RF-32 Capacidad: número de perros atendidos a la vez (1 en v1; preparado para más).
- RF-33 El cliente elige perro → servicio(s) → fecha → hora libre. El sistema calcula los huecos libres con la duración del servicio y el tamaño del perro.
- RF-34 Estados de la cita: `pendiente` → `confirmada` → `en_curso` → `completada`; también `cancelada` y `no_asistio`.
- RF-35 Confirmación: automática o manual por Paulina (configurable). Al confirmar se avisa al cliente por email/push (y WhatsApp si hay ventana gratuita abierta, ver doc 02).
- RF-36 El cliente puede reprogramar o cancelar hasta X horas antes (configurable, por defecto 24 h). Después de ese plazo solo Paulina puede cancelar.
- RF-37 Pago del servicio: en el local (por defecto) o anticipado online (opcional, activable por Paulina). Con pago anticipado la cita queda confirmada al pagar.
- RF-38 Recordatorio de cita 24 h antes (email + push; WhatsApp según coste, ver 4.7).
- RF-39 Paulina ve la agenda por día y semana, crea/edita/mueve citas, marca asistencia y completa la visita.
- RF-40 Notas internas por cita (no visibles para el cliente).
- RF-41 Lista de espera simple: si no hay hueco, el cliente puede pedir aviso cuando se libere uno (fase 2).

### 4.5 Tienda y carrito (RF-50 a RF-61)

- RF-50 Catálogo de productos con categorías, fotos, descripción, precio en CLP con IVA incluido, stock y estado (activo/agotado).
- RF-51 Carrito disponible con y sin sesión iniciada (invitado); al iniciar sesión se fusionan los carritos.
- RF-52 El carrito se comparte entre app y web (vive en el servidor, asociado al usuario).
- RF-53 Checkout: método de entrega (retiro en el local o despacho a domicilio con costo por comuna configurable), datos de contacto, aceptación de T&C y de la política de retracto, resumen con total final.
- RF-54 Pago con Webpay Plus o Mercado Pago (el cliente elige). También "pago en el local" si Paulina lo activa (para retiro).
- RF-55 Estados del pedido: `pendiente_pago` → `pagado` → `preparando` → `listo_para_retiro` / `enviado` → `entregado`; además `cancelado`, `retracto`, `reembolsado`.
- RF-56 Confirmación escrita de la compra por email (obligatoria por ley, ver doc 04) con número de pedido, detalle, precios, entrega y cómo ejercer el retracto.
- RF-57 El stock se descuenta al pagar y se repone si el pedido se cancela o hay retracto.
- RF-58 Paulina gestiona productos, categorías, stock, costos de despacho y pedidos desde el panel; puede marcar pedidos como preparados/enviados/entregados y registrar reembolsos.
- RF-59 Cupones de descuento simples (porcentaje o monto) — fase 2.
- RF-60 Desde WhatsApp el cliente puede añadir productos al carrito y pagar con un enlace; el pedido es el mismo que vería en la app.
- RF-61 Boleta electrónica: cuando la pyme tenga inicio de actividades, cada venta pagada genera su boleta (ver doc 02 §7 y doc 04 §3). Hasta entonces el sistema guarda todo lo necesario para emitirla.

### 4.6 Pagos (RF-70 a RF-75)

- RF-70 Pasarelas: Webpay Plus (Transbank) y Mercado Pago Checkout Pro. Ambas sin coste fijo; comisión por transacción.
- RF-71 Montos en pesos chilenos sin decimales.
- RF-72 Cada intento de pago queda registrado (pasarela, orden de compra, monto, estado, código de autorización, últimos 4 dígitos, respuesta cruda).
- RF-73 Conciliación: los pedidos solo pasan a `pagado` cuando la pasarela lo confirma por su canal oficial (retorno + verificación / webhook), nunca por lo que diga la app.
- RF-74 Anulaciones y reembolsos desde el panel (Webpay permite anular/reembolsar vía API; Mercado Pago también).
- RF-75 Pago en ambiente de pruebas (integración/sandbox) durante el desarrollo, con tarjetas de prueba de cada pasarela.

### 4.7 Recordatorios y avisos (RF-80 a RF-89)

Para el cliente:

- RF-80 **"Le toca a tu perro"**: cada servicio tiene un intervalo recomendado (por ejemplo baño 30 días, corte 60 días; configurable globalmente y por perro). Cuando pasa ese tiempo desde la última visita y no hay cita futura, se envía un recordatorio invitando a agendar, con enlace directo.
- RF-81 Recordatorio de cita 24 h antes y aviso de cita confirmada/cancelada.
- RF-82 Avisos de pedido: pagado, listo para retiro, enviado.
- RF-83 Canales: email (siempre, gratis), push en la app (gratis) y WhatsApp.
  - WhatsApp gratis: solo cuando el cliente escribió en las últimas 24 h (ventana de servicio) o dentro de los 1.000 mensajes gratuitos mensuales.
  - WhatsApp iniciado por el negocio (plantillas) tiene coste por mensaje: **desactivado por defecto** (política de coste cero). En su lugar, el panel muestra a Paulina la lista de "perros a los que les toca" con un botón **Enviar por WhatsApp** que abre su WhatsApp Business con el mensaje ya escrito (gratis, un toque por cliente).
- RF-84 El cliente controla sus consentimientos (email/WhatsApp) y cada mensaje comercial incluye cómo darse de baja.
- RF-85 No se repite un recordatorio del mismo tipo antes de N días (por defecto 14) ni se envía fuera del horario configurado (por defecto 10:00–20:00, hora de Chile).

Para la administradora:

- RF-86 Resumen diario (email + push): citas de hoy, perros a los que les toca volver (con botones de WhatsApp), pedidos pendientes de preparar, pagos recibidos.
- RF-87 Aviso inmediato de nueva cita, cancelación, nuevo pedido pagado y mensaje de WhatsApp que el bot no pudo resolver.
- RF-88 Registro de todos los avisos enviados (canal, destinatario, estado, fecha).
- RF-89 Plantillas de mensajes editables desde el panel (texto con variables: nombre del cliente, del perro, fecha…).

### 4.8 Chatbot de WhatsApp (RF-90 a RF-99)

- RF-90 Bot por menús (botones y listas interactivas de WhatsApp), en español de Chile, sin inteligencia artificial de pago en v1.
- RF-91 Identificación por número de teléfono. Si no existe cliente: alta rápida (nombre) previa aceptación de la política de privacidad; se le ofrece completar su cuenta en la web.
- RF-92 Menú principal: 1) Agendar, 2) Mis citas, 3) Tienda, 4) Mis perros, 5) Hablar con Paulina.
- RF-93 Flujo Agendar: elegir perro (o crear uno con nombre y tamaño) → servicio → día (próximos 14 días con huecos) → hora → confirmación. Crea la cita en estado `pendiente` (o `confirmada` si la confirmación es automática).
- RF-94 Flujo Mis citas: ver próximas, cancelar o reprogramar (mismas reglas que la app).
- RF-95 Flujo Tienda: categorías → productos (lista con precio) → cantidad → carrito → entrega → **enlace de pago** (abre la web con el carrito listo para pagar con Webpay o Mercado Pago). Al confirmarse el pago, el bot avisa.
- RF-96 Flujo Mis perros: ficha resumida y última visita de cada perro.
- RF-97 "Hablar con Paulina": el bot deja de responder en esa conversación durante 2 h (configurable) y avisa a Paulina; ella contesta desde su WhatsApp Business normal.
- RF-98 Si el bot no entiende dos veces seguidas, ofrece el menú y la opción de hablar con Paulina.
- RF-99 Todo lo que el bot hace queda reflejado en el panel (citas, pedidos, conversaciones).

### 4.9 Panel de administración (RF-100 a RF-110)

- RF-100 Dashboard: citas de hoy, ingresos del día/semana/mes, pedidos pendientes, perros "a contactar", últimos mensajes de WhatsApp sin resolver.
- RF-101 Agenda (día/semana), con arrastrar y soltar para mover citas.
- RF-102 Clientes y perros: buscar, ver, editar, historial, consentimientos, solicitudes de datos.
- RF-103 Servicios y precios por tamaño; horarios y días cerrados.
- RF-104 Productos, categorías, stock, despacho.
- RF-105 Pedidos y pagos; anulaciones y reembolsos.
- RF-106 Recordatorios: configuración de intervalos, plantillas, registro de envíos, lista "le toca" con envío por WhatsApp de un toque.
- RF-107 Configuración del negocio: nombre, RUT (cuando exista), dirección, teléfono, textos legales, pasarelas activas, boleta.
- RF-108 Exportaciones CSV/PDF (clientes, visitas, ventas).
- RF-109 Usuarios del panel (Paulina + futuro personal) con roles.
- RF-110 Registro de actividad (quién cambió qué).

## 5. Reglas de negocio

| Regla | Detalle |
|---|---|
| RN-01 Precio por tamaño | El precio y la duración de un servicio dependen del tamaño registrado del perro. Si Paulina cambia el tamaño en la visita, el precio se recalcula y queda constancia. |
| RN-02 Intervalos "le toca" | Por defecto: baño 30 días, corte 60 días, baño + corte 45 días, deslanado 90 días. Configurables por servicio y por perro. |
| RN-03 Sin duplicar recordatorios | No se envía recordatorio si hay cita futura para ese perro, ni antes de 14 días del anterior del mismo tipo. |
| RN-04 Cancelación | Gratuita hasta 24 h antes. Después, solo Paulina puede cancelar; una cita no cancelada y no asistida se marca `no_asistio`. |
| RN-05 Huecos | Se calcula con la duración del servicio, el horario de atención, las citas existentes y la capacidad. Mínimo de antelación para reservar: 2 h (configurable). |
| RN-06 Pago confirmado solo por la pasarela | Nunca por el cliente ni por la app. |
| RN-07 Stock | Se descuenta al confirmarse el pago. Si el stock llega a 0, el producto se muestra "agotado". |
| RN-08 Precios | En CLP, sin decimales, IVA incluido y así se muestran siempre (obligatorio por ley). |
| RN-09 Retracto | Productos: 10 días desde la recepción. Servicios: el cliente puede retractarse hasta antes de la prestación, salvo exclusión informada. Si no se envía confirmación escrita de la compra, el plazo se amplía a 90 días (por eso RF-56 es obligatorio). |
| RN-10 Mayores de edad | Solo se registran mayores de 18 años (declaración en el registro). |
| RN-11 Zona horaria | Todo en `America/Santiago`. |
| RN-12 Consentimiento para WhatsApp | Solo se envían mensajes iniciados por el negocio a quien dio su consentimiento explícito y registrado. |

## 6. Requisitos no funcionales

- Idioma: español (Chile). Moneda CLP. Formato de teléfono +56 9 XXXX XXXX. Validación de RUT (módulo 11) cuando se informe.
- Rendimiento: adecuado a hosting compartido (consultas indexadas, caché de catálogo y de disponibilidad, imágenes optimizadas y redimensionadas al subir).
- Seguridad: HTTPS obligatorio, contraseñas con hash (bcrypt/argon2), tokens con caducidad para la app, limitación de intentos, protección CSRF en la web, validación de todo lo que entra por API y por WhatsApp, cifrado en reposo de RUT y teléfono, registros sin datos personales innecesarios.
- Disponibilidad: copias de seguridad diarias de base de datos y fotos (script en cron + copia descargada a `E:\Proyectos\Lanositos\_respaldos`).
- Accesibilidad básica: contraste suficiente, tamaños de toque de 48 dp en la app, etiquetas en formularios.
- App: tolerante a mala conexión (cache local del catálogo y del historial), tamaño contenido, Android 8.0 (API 26) o superior.
- Observabilidad: registro de errores en servidor y app (herramientas gratuitas: logs de Laravel, Firebase Crashlytics gratis).

## 7. Fuera del alcance de la v1

iOS, varias sucursales, programa de puntos/fidelización, chat con inteligencia artificial, marketplace de terceros, facturación a empresas (factura electrónica), pasarela de suscripciones.

## 8. Preguntas abiertas para Paulina

1. Lista de servicios con precio y duración por tamaño; intervalos recomendados de vuelta.
2. Horario de atención, días cerrados, cuántos perros atiende a la vez.
3. ¿Confirmación de citas automática o quiere revisarlas ella?
4. ¿Cobro anticipado online de los servicios o siempre en el local?
5. Catálogo inicial de productos (fotos, precios con IVA, stock) y política de despacho (comunas y costo) o solo retiro.
6. Número de WhatsApp para el bot: ¿el actual del negocio (se migra a la API) o uno nuevo? El número de la API no puede usarse a la vez en la app WhatsApp normal.
7. Dominio: ¿compra `lanositos.cl` (≈ CLP 10.000/año) o usamos un subdominio gratuito de un dominio que ya tenemos?
8. Publicación en Google Play (US$ 25 una sola vez) o distribución gratuita del APK desde la web para empezar.
9. Fecha prevista de inicio de actividades en el SII.
10. Nombre legal y datos de contacto que irán en Términos y Condiciones.
