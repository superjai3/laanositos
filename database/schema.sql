-- =====================================================================
--  Lanositos · Esquema de base de datos de referencia (MariaDB 10.6+)
--  Versión 1.0 · 21-10-2026
--
--  En el proyecto Laravel este esquema se implementa como migraciones.
--  Las tablas propias de Laravel (sessions, cache, jobs, failed_jobs,
--  password_reset_tokens, personal_access_tokens) las crea el framework
--  y no se repiten aquí.
--
--  Convenciones:
--   - Montos en pesos chilenos (CLP), enteros sin decimales.
--   - Fechas/horas en UTC en la BD; la aplicación muestra America/Santiago.
--   - utf8mb4 para soportar emojis en nombres de perros y mensajes.
-- =====================================================================

SET NAMES utf8mb4;
SET time_zone = '+00:00';

CREATE DATABASE IF NOT EXISTS lanositos
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE lanositos;

-- ---------------------------------------------------------------------
-- 1. Cuentas, consentimientos y derechos del titular
-- ---------------------------------------------------------------------

CREATE TABLE users (
  id                 BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  role               ENUM('cliente','admin','staff') NOT NULL DEFAULT 'cliente',
  name               VARCHAR(120)  NOT NULL,
  email              VARCHAR(190)  NULL,
  email_verified_at  DATETIME      NULL,
  phone              VARCHAR(255)  NULL COMMENT 'E.164 (+569XXXXXXXX), cifrado en la app',
  phone_hash         CHAR(64)      NULL COMMENT 'SHA-256 del teléfono para buscar sin descifrar',
  rut                VARCHAR(255)  NULL COMMENT 'Opcional, solo para boleta; cifrado',
  password           VARCHAR(255)  NULL COMMENT 'NULL si el alta fue solo por WhatsApp',
  is_adult_declared  TINYINT(1)    NOT NULL DEFAULT 0,
  notify_email       TINYINT(1)    NOT NULL DEFAULT 1 COMMENT 'Avisos transaccionales por email',
  marketing_email    TINYINT(1)    NOT NULL DEFAULT 0 COMMENT 'Recordatorios/promos por email',
  marketing_whatsapp TINYINT(1)    NOT NULL DEFAULT 0 COMMENT 'Mensajes iniciados por el negocio por WhatsApp',
  locale             VARCHAR(10)   NOT NULL DEFAULT 'es_CL',
  last_login_at      DATETIME      NULL,
  remember_token     VARCHAR(100)  NULL,
  created_at         DATETIME      NULL,
  updated_at         DATETIME      NULL,
  deleted_at         DATETIME      NULL COMMENT 'Borrado lógico; la supresión real anonimiza',
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_email (email),
  UNIQUE KEY uq_users_phone_hash (phone_hash),
  KEY idx_users_role (role)
) ENGINE=InnoDB;

CREATE TABLE consents (
  id          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id     BIGINT UNSIGNED NOT NULL,
  type        ENUM('terminos','privacidad','marketing_email','marketing_whatsapp','retracto_informado') NOT NULL,
  version     VARCHAR(20)  NOT NULL COMMENT 'Versión del texto aceptado, p. ej. 2026-11',
  granted     TINYINT(1)   NOT NULL DEFAULT 1 COMMENT '1 = otorgado, 0 = retirado',
  channel     ENUM('app','web','whatsapp','admin') NOT NULL,
  ip_address  VARCHAR(45)  NULL,
  user_agent  VARCHAR(255) NULL,
  created_at  DATETIME     NOT NULL,
  PRIMARY KEY (id),
  KEY idx_consents_user_type (user_id, type, created_at),
  CONSTRAINT fk_consents_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE data_requests (
  id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id       BIGINT UNSIGNED NOT NULL,
  type          ENUM('acceso','rectificacion','supresion','oposicion','portabilidad','bloqueo') NOT NULL,
  status        ENUM('pendiente','en_proceso','resuelta','rechazada') NOT NULL DEFAULT 'pendiente',
  details       TEXT         NULL,
  resolution    TEXT         NULL,
  requested_at  DATETIME     NOT NULL,
  due_at        DATETIME     NOT NULL COMMENT 'Plazo legal de respuesta calculado por la app',
  resolved_at   DATETIME     NULL,
  handled_by    BIGINT UNSIGNED NULL,
  PRIMARY KEY (id),
  KEY idx_data_requests_status (status, due_at),
  CONSTRAINT fk_data_requests_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_data_requests_handler FOREIGN KEY (handled_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE addresses (
  id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id       BIGINT UNSIGNED NOT NULL,
  label         VARCHAR(40)  NOT NULL DEFAULT 'Casa',
  street        VARCHAR(150) NOT NULL,
  number        VARCHAR(20)  NOT NULL,
  apartment     VARCHAR(40)  NULL,
  comuna        VARCHAR(80)  NOT NULL,
  region        VARCHAR(80)  NOT NULL,
  instructions  VARCHAR(255) NULL,
  is_default    TINYINT(1)   NOT NULL DEFAULT 0,
  created_at    DATETIME     NULL,
  updated_at    DATETIME     NULL,
  PRIMARY KEY (id),
  KEY idx_addresses_user (user_id),
  CONSTRAINT fk_addresses_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE devices (
  id          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id     BIGINT UNSIGNED NOT NULL,
  platform    ENUM('android','web') NOT NULL DEFAULT 'android',
  fcm_token   VARCHAR(255) NOT NULL,
  app_version VARCHAR(20)  NULL,
  last_seen_at DATETIME    NULL,
  created_at  DATETIME     NULL,
  updated_at  DATETIME     NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_devices_token (fcm_token),
  KEY idx_devices_user (user_id),
  CONSTRAINT fk_devices_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 2. Perros e historial
-- ---------------------------------------------------------------------

CREATE TABLE breeds (
  id    SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name  VARCHAR(80) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_breeds_name (name)
) ENGINE=InnoDB;

CREATE TABLE pets (
  id                 BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id            BIGINT UNSIGNED NOT NULL,
  name               VARCHAR(80)  NOT NULL,
  breed_id           SMALLINT UNSIGNED NULL,
  breed_other        VARCHAR(80)  NULL,
  sex                ENUM('macho','hembra','desconocido') NOT NULL DEFAULT 'desconocido',
  birth_date         DATE         NULL,
  size               ENUM('pequeno','mediano','grande','gigante') NOT NULL,
  weight_kg          DECIMAL(5,2) NULL,
  coat_type          ENUM('corto','medio','largo','rizado','doble_capa','duro','sin_pelo') NULL,
  color              VARCHAR(60)  NULL,
  photo_path         VARCHAR(255) NULL,
  allergies          TEXT         NULL,
  notes              TEXT         NULL COMMENT 'Temperamento, cuidados especiales',
  rabies_vaccine_at  DATE         NULL,
  microchip          VARCHAR(30)  NULL,
  registry_number    VARCHAR(40)  NULL COMMENT 'Registro Nacional de Mascotas (opcional)',
  is_active          TINYINT(1)   NOT NULL DEFAULT 1,
  created_at         DATETIME     NULL,
  updated_at         DATETIME     NULL,
  deleted_at         DATETIME     NULL,
  PRIMARY KEY (id),
  KEY idx_pets_user (user_id, is_active),
  CONSTRAINT fk_pets_user  FOREIGN KEY (user_id)  REFERENCES users(id)  ON DELETE CASCADE,
  CONSTRAINT fk_pets_breed FOREIGN KEY (breed_id) REFERENCES breeds(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 3. Servicios, horarios y citas
-- ---------------------------------------------------------------------

CREATE TABLE services (
  id              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name            VARCHAR(80)  NOT NULL,
  slug            VARCHAR(90)  NOT NULL,
  description     TEXT         NULL,
  interval_days   SMALLINT UNSIGNED NULL COMMENT 'Días recomendados hasta la próxima visita',
  sort_order      SMALLINT     NOT NULL DEFAULT 0,
  is_active       TINYINT(1)   NOT NULL DEFAULT 1,
  created_at      DATETIME     NULL,
  updated_at      DATETIME     NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_services_slug (slug)
) ENGINE=InnoDB;

CREATE TABLE service_prices (
  id            INT UNSIGNED NOT NULL AUTO_INCREMENT,
  service_id    INT UNSIGNED NOT NULL,
  size          ENUM('pequeno','mediano','grande','gigante') NOT NULL,
  price_clp     INT UNSIGNED NOT NULL,
  duration_min  SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_service_size (service_id, size),
  CONSTRAINT fk_service_prices_service FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Intervalo personalizado "le toca" por perro y servicio (si no hay fila, aplica el del servicio)
CREATE TABLE pet_service_intervals (
  pet_id         BIGINT UNSIGNED NOT NULL,
  service_id     INT UNSIGNED    NOT NULL,
  interval_days  SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY (pet_id, service_id),
  CONSTRAINT fk_psi_pet     FOREIGN KEY (pet_id)     REFERENCES pets(id)     ON DELETE CASCADE,
  CONSTRAINT fk_psi_service FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE business_hours (
  id         TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  weekday    TINYINT UNSIGNED NOT NULL COMMENT '1 = lunes … 7 = domingo',
  opens_at   TIME NOT NULL,
  closes_at  TIME NOT NULL,
  PRIMARY KEY (id),
  KEY idx_business_hours_weekday (weekday)
) ENGINE=InnoDB;

CREATE TABLE closures (
  id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  starts_at   DATETIME NOT NULL,
  ends_at     DATETIME NOT NULL,
  reason      VARCHAR(120) NULL,
  created_at  DATETIME NULL,
  PRIMARY KEY (id),
  KEY idx_closures_range (starts_at, ends_at)
) ENGINE=InnoDB;

CREATE TABLE appointments (
  id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id          BIGINT UNSIGNED NOT NULL,
  pet_id           BIGINT UNSIGNED NOT NULL,
  staff_id         BIGINT UNSIGNED NULL,
  scheduled_at     DATETIME NOT NULL,
  ends_at          DATETIME NOT NULL,
  duration_min     SMALLINT UNSIGNED NOT NULL,
  status           ENUM('pendiente','confirmada','en_curso','completada','cancelada','no_asistio') NOT NULL DEFAULT 'pendiente',
  source           ENUM('app','web','whatsapp','admin') NOT NULL,
  total_clp        INT UNSIGNED NOT NULL DEFAULT 0,
  payment_mode     ENUM('local','online') NOT NULL DEFAULT 'local',
  payment_status   ENUM('no_aplica','pendiente','pagado','reembolsado') NOT NULL DEFAULT 'no_aplica',
  customer_notes   VARCHAR(500) NULL,
  internal_notes   TEXT NULL,
  cancelled_at     DATETIME NULL,
  cancelled_by     BIGINT UNSIGNED NULL,
  cancel_reason    VARCHAR(255) NULL,
  reminder_sent_at DATETIME NULL,
  created_at       DATETIME NULL,
  updated_at       DATETIME NULL,
  PRIMARY KEY (id),
  KEY idx_appointments_scheduled (scheduled_at, status),
  KEY idx_appointments_pet (pet_id, scheduled_at),
  KEY idx_appointments_user (user_id),
  CONSTRAINT fk_appointments_user  FOREIGN KEY (user_id)  REFERENCES users(id),
  CONSTRAINT fk_appointments_pet   FOREIGN KEY (pet_id)   REFERENCES pets(id),
  CONSTRAINT fk_appointments_staff FOREIGN KEY (staff_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE appointment_services (
  appointment_id  BIGINT UNSIGNED NOT NULL,
  service_id      INT UNSIGNED NOT NULL,
  price_clp       INT UNSIGNED NOT NULL COMMENT 'Precio aplicado en el momento (histórico)',
  duration_min    SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY (appointment_id, service_id),
  CONSTRAINT fk_as_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE CASCADE,
  CONSTRAINT fk_as_service     FOREIGN KEY (service_id)     REFERENCES services(id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 4. Historial de visitas
-- ---------------------------------------------------------------------

CREATE TABLE visits (
  id                   BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  pet_id               BIGINT UNSIGNED NOT NULL,
  appointment_id       BIGINT UNSIGNED NULL COMMENT 'NULL = visita sin cita previa',
  staff_id             BIGINT UNSIGNED NULL,
  visited_at           DATETIME NOT NULL,
  total_clp            INT UNSIGNED NOT NULL DEFAULT 0,
  size_at_visit        ENUM('pequeno','mediano','grande','gigante') NULL,
  weight_kg            DECIMAL(5,2) NULL,
  groomer_notes        TEXT NULL COMMENT 'Observaciones: pelo, piel, nudos, comportamiento',
  recommendations      TEXT NULL,
  next_visit_suggested DATE NULL,
  created_at           DATETIME NULL,
  updated_at           DATETIME NULL,
  PRIMARY KEY (id),
  KEY idx_visits_pet (pet_id, visited_at),
  UNIQUE KEY uq_visits_appointment (appointment_id),
  CONSTRAINT fk_visits_pet         FOREIGN KEY (pet_id)         REFERENCES pets(id) ON DELETE CASCADE,
  CONSTRAINT fk_visits_appointment FOREIGN KEY (appointment_id) REFERENCES appointments(id) ON DELETE SET NULL,
  CONSTRAINT fk_visits_staff       FOREIGN KEY (staff_id)       REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE visit_services (
  visit_id    BIGINT UNSIGNED NOT NULL,
  service_id  INT UNSIGNED NOT NULL,
  price_clp   INT UNSIGNED NOT NULL,
  PRIMARY KEY (visit_id, service_id),
  CONSTRAINT fk_vs_visit   FOREIGN KEY (visit_id)   REFERENCES visits(id) ON DELETE CASCADE,
  CONSTRAINT fk_vs_service FOREIGN KEY (service_id) REFERENCES services(id)
) ENGINE=InnoDB;

CREATE TABLE visit_photos (
  id         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  visit_id   BIGINT UNSIGNED NOT NULL,
  kind       ENUM('antes','despues','otra') NOT NULL DEFAULT 'otra',
  path       VARCHAR(255) NOT NULL,
  created_at DATETIME NULL,
  PRIMARY KEY (id),
  KEY idx_visit_photos_visit (visit_id),
  CONSTRAINT fk_visit_photos_visit FOREIGN KEY (visit_id) REFERENCES visits(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 5. Tienda
-- ---------------------------------------------------------------------

CREATE TABLE categories (
  id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  parent_id   INT UNSIGNED NULL,
  name        VARCHAR(80)  NOT NULL,
  slug        VARCHAR(90)  NOT NULL,
  sort_order  SMALLINT     NOT NULL DEFAULT 0,
  is_active   TINYINT(1)   NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY uq_categories_slug (slug),
  CONSTRAINT fk_categories_parent FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE products (
  id                 BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  category_id        INT UNSIGNED NULL,
  sku                VARCHAR(40)  NULL,
  name               VARCHAR(150) NOT NULL,
  slug               VARCHAR(160) NOT NULL,
  description        TEXT NULL,
  price_clp          INT UNSIGNED NOT NULL COMMENT 'Precio final al público, IVA incluido',
  compare_price_clp  INT UNSIGNED NULL COMMENT 'Precio tachado (opcional)',
  cost_clp           INT UNSIGNED NULL COMMENT 'Costo interno (no público)',
  stock              INT NOT NULL DEFAULT 0,
  track_stock        TINYINT(1) NOT NULL DEFAULT 1,
  weight_g           INT UNSIGNED NULL,
  is_active          TINYINT(1) NOT NULL DEFAULT 1,
  excluded_from_retracto TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Solo si la ley lo permite y se informó',
  created_at         DATETIME NULL,
  updated_at         DATETIME NULL,
  deleted_at         DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_products_slug (slug),
  UNIQUE KEY uq_products_sku (sku),
  KEY idx_products_category (category_id, is_active),
  CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE product_images (
  id          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  product_id  BIGINT UNSIGNED NOT NULL,
  path        VARCHAR(255) NOT NULL,
  sort_order  SMALLINT NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  KEY idx_product_images_product (product_id),
  CONSTRAINT fk_product_images_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE shipping_zones (
  id         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  comuna     VARCHAR(80) NOT NULL,
  cost_clp   INT UNSIGNED NOT NULL,
  free_from_clp INT UNSIGNED NULL COMMENT 'Despacho gratis desde este monto (opcional)',
  is_active  TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY uq_shipping_comuna (comuna)
) ENGINE=InnoDB;

CREATE TABLE carts (
  id          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id     BIGINT UNSIGNED NULL COMMENT 'NULL = invitado',
  token       CHAR(36) NOT NULL COMMENT 'UUID para carritos de invitado y de WhatsApp',
  source      ENUM('app','web','whatsapp') NOT NULL DEFAULT 'web',
  expires_at  DATETIME NULL,
  created_at  DATETIME NULL,
  updated_at  DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_carts_token (token),
  KEY idx_carts_user (user_id),
  CONSTRAINT fk_carts_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE cart_items (
  id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  cart_id         BIGINT UNSIGNED NOT NULL,
  product_id      BIGINT UNSIGNED NOT NULL,
  quantity        SMALLINT UNSIGNED NOT NULL DEFAULT 1,
  unit_price_clp  INT UNSIGNED NOT NULL,
  created_at      DATETIME NULL,
  updated_at      DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_cart_product (cart_id, product_id),
  CONSTRAINT fk_cart_items_cart    FOREIGN KEY (cart_id)    REFERENCES carts(id) ON DELETE CASCADE,
  CONSTRAINT fk_cart_items_product FOREIGN KEY (product_id) REFERENCES products(id)
) ENGINE=InnoDB;

CREATE TABLE orders (
  id                 BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  number             VARCHAR(20) NOT NULL COMMENT 'Número visible, p. ej. LAN-2026-000123',
  user_id            BIGINT UNSIGNED NOT NULL,
  status             ENUM('pendiente_pago','pagado','preparando','listo_para_retiro','enviado','entregado','cancelado','retracto','reembolsado') NOT NULL DEFAULT 'pendiente_pago',
  source             ENUM('app','web','whatsapp','admin') NOT NULL,
  delivery_method    ENUM('retiro_local','despacho') NOT NULL,
  subtotal_clp       INT UNSIGNED NOT NULL,
  shipping_clp       INT UNSIGNED NOT NULL DEFAULT 0,
  discount_clp       INT UNSIGNED NOT NULL DEFAULT 0,
  total_clp          INT UNSIGNED NOT NULL,
  iva_clp            INT UNSIGNED NOT NULL COMMENT 'IVA incluido en el total (19 %), para la boleta',
  ship_name          VARCHAR(120) NULL,
  ship_phone         VARCHAR(30)  NULL,
  ship_street        VARCHAR(150) NULL,
  ship_number        VARCHAR(20)  NULL,
  ship_apartment     VARCHAR(40)  NULL,
  ship_comuna        VARCHAR(80)  NULL,
  ship_region        VARCHAR(80)  NULL,
  ship_instructions  VARCHAR(255) NULL,
  customer_notes     VARCHAR(500) NULL,
  internal_notes     TEXT NULL,
  terms_version      VARCHAR(20) NOT NULL COMMENT 'T&C aceptados en el checkout',
  confirmation_sent_at DATETIME NULL COMMENT 'Confirmación escrita de la compra (obligatoria)',
  paid_at            DATETIME NULL,
  delivered_at       DATETIME NULL,
  cancelled_at       DATETIME NULL,
  retracto_requested_at DATETIME NULL,
  created_at         DATETIME NULL,
  updated_at         DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_orders_number (number),
  KEY idx_orders_user (user_id, created_at),
  KEY idx_orders_status (status),
  CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE order_items (
  id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id        BIGINT UNSIGNED NOT NULL,
  product_id      BIGINT UNSIGNED NULL,
  product_name    VARCHAR(150) NOT NULL COMMENT 'Copia histórica',
  sku             VARCHAR(40)  NULL,
  quantity        SMALLINT UNSIGNED NOT NULL,
  unit_price_clp  INT UNSIGNED NOT NULL,
  total_clp       INT UNSIGNED NOT NULL,
  PRIMARY KEY (id),
  KEY idx_order_items_order (order_id),
  CONSTRAINT fk_order_items_order   FOREIGN KEY (order_id)   REFERENCES orders(id) ON DELETE CASCADE,
  CONSTRAINT fk_order_items_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE stock_movements (
  id          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  product_id  BIGINT UNSIGNED NOT NULL,
  quantity    INT NOT NULL COMMENT 'Negativo = salida',
  reason      ENUM('venta','cancelacion','retracto','ajuste','compra') NOT NULL,
  order_id    BIGINT UNSIGNED NULL,
  user_id     BIGINT UNSIGNED NULL COMMENT 'Quien hizo el ajuste manual',
  created_at  DATETIME NOT NULL,
  PRIMARY KEY (id),
  KEY idx_stock_product (product_id, created_at),
  CONSTRAINT fk_stock_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  CONSTRAINT fk_stock_order   FOREIGN KEY (order_id)   REFERENCES orders(id)   ON DELETE SET NULL
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 6. Pagos y boletas
-- ---------------------------------------------------------------------

CREATE TABLE payments (
  id                 BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  payable_type       ENUM('order','appointment') NOT NULL,
  payable_id         BIGINT UNSIGNED NOT NULL,
  user_id            BIGINT UNSIGNED NOT NULL,
  gateway            ENUM('webpay_plus','mercadopago','efectivo_local','transferencia') NOT NULL,
  buy_order          VARCHAR(60) NOT NULL COMMENT 'Orden de compra enviada a la pasarela (idempotencia)',
  gateway_token      VARCHAR(120) NULL COMMENT 'token_ws / preference_id',
  gateway_payment_id VARCHAR(120) NULL COMMENT 'id del pago en Mercado Pago',
  amount_clp         INT UNSIGNED NOT NULL,
  status             ENUM('iniciado','autorizado','rechazado','anulado','reembolsado','expirado') NOT NULL DEFAULT 'iniciado',
  authorization_code VARCHAR(20)  NULL,
  card_last4         CHAR(4)      NULL,
  payment_type       VARCHAR(20)  NULL COMMENT 'Débito, crédito, cuotas, saldo MP…',
  response_code      VARCHAR(20)  NULL,
  raw_response       JSON NULL,
  paid_at            DATETIME NULL,
  created_at         DATETIME NULL,
  updated_at         DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_payments_buy_order (buy_order),
  KEY idx_payments_payable (payable_type, payable_id),
  KEY idx_payments_status (status, created_at),
  CONSTRAINT fk_payments_user FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE refunds (
  id             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  payment_id     BIGINT UNSIGNED NOT NULL,
  amount_clp     INT UNSIGNED NOT NULL,
  reason         ENUM('retracto','cancelacion','garantia','error','otro') NOT NULL,
  status         ENUM('solicitado','procesado','rechazado') NOT NULL DEFAULT 'solicitado',
  gateway_ref    VARCHAR(120) NULL,
  requested_by   BIGINT UNSIGNED NULL,
  raw_response   JSON NULL,
  created_at     DATETIME NULL,
  processed_at   DATETIME NULL,
  PRIMARY KEY (id),
  KEY idx_refunds_payment (payment_id),
  CONSTRAINT fk_refunds_payment FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Boletas electrónicas (se llena cuando la pyme tenga inicio de actividades)
CREATE TABLE receipts (
  id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  payable_type  ENUM('order','appointment','visit') NOT NULL,
  payable_id    BIGINT UNSIGNED NOT NULL,
  dte_type      SMALLINT UNSIGNED NOT NULL DEFAULT 39 COMMENT '39 = boleta electrónica afecta',
  folio         BIGINT UNSIGNED NULL,
  issued_at     DATETIME NULL,
  net_clp       INT UNSIGNED NOT NULL,
  iva_clp       INT UNSIGNED NOT NULL,
  total_clp     INT UNSIGNED NOT NULL,
  customer_rut  VARCHAR(255) NULL COMMENT 'Cifrado',
  status        ENUM('pendiente','emitida','anulada') NOT NULL DEFAULT 'pendiente',
  pdf_path      VARCHAR(255) NULL,
  created_at    DATETIME NULL,
  updated_at    DATETIME NULL,
  PRIMARY KEY (id),
  KEY idx_receipts_payable (payable_type, payable_id),
  KEY idx_receipts_status (status)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 7. Recordatorios, plantillas y avisos
-- ---------------------------------------------------------------------

CREATE TABLE reminder_rules (
  id              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  code            VARCHAR(40) NOT NULL COMMENT 'le_toca_volver, cita_24h, pedido_pagado, resumen_admin…',
  name            VARCHAR(100) NOT NULL,
  audience        ENUM('cliente','admin') NOT NULL,
  channel_email   TINYINT(1) NOT NULL DEFAULT 1,
  channel_push    TINYINT(1) NOT NULL DEFAULT 1,
  channel_whatsapp TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Plantillas de pago: desactivado por defecto',
  days_after      SMALLINT UNSIGNED NULL COMMENT 'Para reglas basadas en tiempo',
  min_days_between SMALLINT UNSIGNED NOT NULL DEFAULT 14,
  send_from       TIME NOT NULL DEFAULT '10:00:00',
  send_until      TIME NOT NULL DEFAULT '20:00:00',
  is_active       TINYINT(1) NOT NULL DEFAULT 1,
  updated_at      DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_reminder_rules_code (code)
) ENGINE=InnoDB;

CREATE TABLE message_templates (
  id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  code        VARCHAR(40) NOT NULL,
  channel     ENUM('email','push','whatsapp') NOT NULL,
  subject     VARCHAR(150) NULL,
  body        TEXT NOT NULL COMMENT 'Variables: {cliente}, {perro}, {fecha}, {hora}, {servicio}, {enlace}',
  meta_template_name VARCHAR(100) NULL COMMENT 'Nombre de la plantilla aprobada en Meta (si aplica)',
  updated_at  DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_message_templates (code, channel)
) ENGINE=InnoDB;

CREATE TABLE notifications_log (
  id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id         BIGINT UNSIGNED NULL,
  pet_id          BIGINT UNSIGNED NULL,
  rule_code       VARCHAR(40) NOT NULL,
  channel         ENUM('email','push','whatsapp','whatsapp_manual') NOT NULL,
  recipient       VARCHAR(190) NOT NULL COMMENT 'Email, token o teléfono (enmascarado)',
  status          ENUM('encolado','enviado','entregado','leido','fallido','omitido') NOT NULL DEFAULT 'encolado',
  provider_id     VARCHAR(120) NULL,
  error           VARCHAR(255) NULL,
  related_type    VARCHAR(30)  NULL COMMENT 'appointment, order, visit',
  related_id      BIGINT UNSIGNED NULL,
  sent_at         DATETIME NULL,
  created_at      DATETIME NOT NULL,
  PRIMARY KEY (id),
  KEY idx_notif_user_rule (user_id, rule_code, created_at),
  KEY idx_notif_pet_rule (pet_id, rule_code, created_at),
  CONSTRAINT fk_notif_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_notif_pet  FOREIGN KEY (pet_id)  REFERENCES pets(id)  ON DELETE SET NULL
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 8. WhatsApp
-- ---------------------------------------------------------------------

CREATE TABLE whatsapp_conversations (
  id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  wa_id            VARCHAR(20) NOT NULL COMMENT 'Número del cliente tal como lo entrega Meta',
  user_id          BIGINT UNSIGNED NULL,
  state            VARCHAR(60) NOT NULL DEFAULT 'menu',
  context          JSON NULL COMMENT 'Datos parciales del flujo en curso (perro, servicio, carrito…)',
  bot_paused_until DATETIME NULL COMMENT 'Mientras habla con Paulina',
  last_inbound_at  DATETIME NULL COMMENT 'Inicio de la ventana de 24 h',
  last_outbound_at DATETIME NULL,
  created_at       DATETIME NULL,
  updated_at       DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_wa_conversations_wa_id (wa_id),
  KEY idx_wa_conversations_user (user_id),
  CONSTRAINT fk_wa_conversations_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE whatsapp_messages (
  id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  conversation_id  BIGINT UNSIGNED NOT NULL,
  direction        ENUM('in','out') NOT NULL,
  wa_message_id    VARCHAR(120) NULL,
  type             VARCHAR(20) NOT NULL COMMENT 'text, interactive, image, template…',
  body             TEXT NULL,
  payload          JSON NULL,
  status           ENUM('recibido','enviado','entregado','leido','fallido') NULL,
  is_billable      TINYINT(1) NOT NULL DEFAULT 0 COMMENT 'Según categoría/ventana de Meta',
  created_at       DATETIME NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_wa_messages_id (wa_message_id),
  KEY idx_wa_messages_conversation (conversation_id, created_at),
  CONSTRAINT fk_wa_messages_conversation FOREIGN KEY (conversation_id) REFERENCES whatsapp_conversations(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 9. Configuración y auditoría
-- ---------------------------------------------------------------------

CREATE TABLE settings (
  `key`       VARCHAR(80) NOT NULL,
  `value`     TEXT NULL,
  `group`     VARCHAR(40) NOT NULL DEFAULT 'general',
  updated_at  DATETIME NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB;

CREATE TABLE activity_log (
  id          BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id     BIGINT UNSIGNED NULL,
  action      VARCHAR(60) NOT NULL COMMENT 'cita.creada, pedido.pagado, producto.editado…',
  subject_type VARCHAR(40) NULL,
  subject_id  BIGINT UNSIGNED NULL,
  changes     JSON NULL COMMENT 'Antes/después, sin datos sensibles',
  ip_address  VARCHAR(45) NULL,
  created_at  DATETIME NOT NULL,
  PRIMARY KEY (id),
  KEY idx_activity_subject (subject_type, subject_id),
  KEY idx_activity_user (user_id, created_at)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 10. Datos iniciales (ejemplo; Paulina confirmará precios y duraciones)
-- ---------------------------------------------------------------------

INSERT INTO services (name, slug, interval_days, sort_order) VALUES
  ('Baño',             'bano',           30, 1),
  ('Corte',            'corte',          60, 2),
  ('Baño + corte',     'bano-corte',     45, 3),
  ('Deslanado',        'deslanado',      90, 4),
  ('Corte de uñas',    'corte-unas',     30, 5),
  ('Limpieza de oídos','limpieza-oidos', 30, 6);

INSERT INTO business_hours (weekday, opens_at, closes_at) VALUES
  (1,'10:00:00','19:00:00'),(2,'10:00:00','19:00:00'),(3,'10:00:00','19:00:00'),
  (4,'10:00:00','19:00:00'),(5,'10:00:00','19:00:00'),(6,'10:00:00','14:00:00');

INSERT INTO reminder_rules (code, name, audience, channel_email, channel_push, channel_whatsapp, days_after, min_days_between) VALUES
  ('le_toca_volver', 'Le toca volver a tu perro', 'cliente', 1, 1, 0, NULL, 14),
  ('cita_24h',       'Recordatorio de cita (24 h)', 'cliente', 1, 1, 0, NULL, 0),
  ('cita_confirmada','Cita confirmada',             'cliente', 1, 1, 0, NULL, 0),
  ('pedido_pagado',  'Pedido pagado',               'cliente', 1, 1, 0, NULL, 0),
  ('pedido_listo',   'Pedido listo / enviado',      'cliente', 1, 1, 0, NULL, 0),
  ('resumen_admin',  'Resumen diario',              'admin',   1, 1, 0, NULL, 0),
  ('nueva_cita_admin','Nueva cita / cancelación',   'admin',   1, 1, 0, NULL, 0),
  ('nuevo_pedido_admin','Nuevo pedido pagado',      'admin',   1, 1, 0, NULL, 0);

INSERT INTO settings (`key`, `value`, `group`) VALUES
  ('business.name',            'Lanositos',                      'negocio'),
  ('business.rut',             '',                                'negocio'),
  ('business.address',         '',                                'negocio'),
  ('business.phone',           '',                                'negocio'),
  ('business.email',           '',                                'negocio'),
  ('scheduling.slot_minutes',  '15',                              'agenda'),
  ('scheduling.capacity',      '1',                               'agenda'),
  ('scheduling.min_lead_hours','2',                               'agenda'),
  ('scheduling.cancel_hours',  '24',                              'agenda'),
  ('scheduling.auto_confirm',  '1',                               'agenda'),
  ('shop.allow_pay_in_store',  '1',                               'tienda'),
  ('payments.webpay_enabled',  '1',                               'pagos'),
  ('payments.mercadopago_enabled','1',                            'pagos'),
  ('whatsapp.templates_enabled','0',                              'whatsapp'),
  ('whatsapp.human_pause_hours','2',                              'whatsapp'),
  ('legal.terms_version',      '2026-11',                         'legal'),
  ('legal.privacy_version',    '2026-11',                         'legal');
