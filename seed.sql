-- ============================================================
-- Seed data para SYM COMPUTER
-- Ejecutar manualmente después de correr el esquema principal.
-- Es idempotente: se puede ejecutar más de una vez. Categorías y marcas se
-- resuelven por slug (no por id), así funciona también sobre bases que ya
-- tenían categorías con otros ids. migrate.js crea las mismas categorías y marcas.
-- Categorías basadas en las de symcomputadores.com; los productos
-- son ejemplos: reemplaza precios, stock y códigos de barras reales.
-- ============================================================

-- ------------------------------------------------------------
-- ROLES
-- ------------------------------------------------------------
INSERT IGNORE INTO `roles` (`id`, `name`, `description`, `permissions`) VALUES
(1, 'admin', 'Administrador de la tienda', JSON_ARRAY('users.read', 'users.write', 'users.delete', 'products.read', 'products.write', 'products.delete', 'categories.read', 'categories.write', 'categories.delete', 'orders.read', 'orders.write', 'orders.delete', 'invoices.read', 'invoices.write', 'settings.read', 'settings.write', 'dashboard.read', 'pos.access', 'pos.sell', 'cash_register.open', 'cash_register.close', 'reports.read')),
(2, 'user', 'Cliente registrado', JSON_ARRAY('orders.own.read', 'profile.read', 'profile.write', 'cart.read', 'cart.write', 'wishlist.read', 'wishlist.write')),
(3, 'guest', 'Cuenta invitada / soporte', JSON_ARRAY()),
(4, 'cashier', 'Cajero punto de venta', JSON_ARRAY('pos.access', 'pos.sell', 'cash_register.open', 'cash_register.close', 'products.read', 'orders.read', 'orders.write'));

-- ------------------------------------------------------------
-- USUARIOS INICIALES
-- IMPORTANTE: cambia las contraseñas de admin y cajero en el primer ingreso
-- y reemplaza los correos/teléfonos por los reales.
-- ------------------------------------------------------------
INSERT IGNORE INTO `users` (`first_name`, `last_name`, `email`, `password_hash`, `role_id`, `phone`, `city`, `province`, `is_active`, `email_verified`) VALUES
('SYM', 'Admin', 'admin@symcomputer.com', '$2a$12$V1fB6UjokcZZoVYABU9zJ.JM3lxw.ASnaS8RU0Z5c5lMGA6oDYWFC', 1, '3133245600', 'Mosquera', 'Cundinamarca', TRUE, TRUE),
  ('Cajero', 'SYM', 'cajero@symcomputer.com', '$2a$12$V1fB6UjokcZZoVYABU9zJ.JM3lxw.ASnaS8RU0Z5c5lMGA6oDYWFC', 4, '3133245601', 'Mosquera', 'Cundinamarca', TRUE, TRUE);


-- ------------------------------------------------------------
-- CATEGORÍAS (por slug). Raíz: PARTES / EQUIPOS / Accesorios / Últimas Unidades
-- ------------------------------------------------------------
INSERT INTO categories (name, slug, description, is_active, sort_order) VALUES
  ('PARTES', 'partes', 'Componentes internos y externos para armar, mejorar y mantener tu equipo', TRUE, 1),
  ('EQUIPOS', 'equipos', 'Computadores completos y monitores', TRUE, 2),
  ('Accesorios', 'accesorios', 'Periféricos y accesorios para tu equipo de cómputo', TRUE, 3),
  ('Últimas Unidades', 'ultimas-unidades', 'Productos con pocas unidades disponibles', TRUE, 4),
  ('AMD 2', 'amd-2', 'Procesadores y productos AMD', TRUE, 1),
  ('Boards', 'boards', 'Tarjetas madre para diferentes gamas y usos', TRUE, 2),
  ('Caja', 'caja', 'Cajas para ensamble de PC', TRUE, 3),
  ('Chasis', 'chasis', 'Chasis y gabinetes para ensamble de PC', TRUE, 4),
  ('Discos Duros', 'discos-duros', 'Unidades de almacenamiento HDD y SSD', TRUE, 5),
  ('Disipadores Aire', 'disipadores', 'Disipadores de aire para procesadores', TRUE, 6),
  ('Fuente', 'fuente', 'Fuentes de poder para tu equipo', TRUE, 7),
  ('Memoria RAM', 'memoria-ram', 'Memorias RAM para desktop y portátiles', TRUE, 8),
  ('Pasta Térmica', 'pasta-termica', 'Pasta térmica para procesadores y disipadores', TRUE, 9),
  ('Procesador', 'procesador', 'Procesadores AMD e Intel', TRUE, 10),
  ('Refrigeración Líquida', 'refrigeracion-disipador', 'Sistemas de refrigeración líquida para CPU', TRUE, 11),
  ('Tarjetas Gráficas', 'tarjetas-graficas', 'Tarjetas de video para gaming y trabajo profesional', TRUE, 12),
  ('Ventilador', 'ventilador', 'Ventiladores para chasis y disipadores', TRUE, 13),
  ('Computadores', 'computadores', 'Portátiles, PC de escritorio y todo en uno', TRUE, 1),
  ('Monitores', 'monitores', 'Monitores para oficina, estudio y gaming', TRUE, 2),
  ('Cámara', 'camara', 'Cámaras web y de videoconferencia', TRUE, 1),
  ('Combos', 'combos', 'Combos de teclado y mouse', TRUE, 2),
  ('Impresoras', 'impresoras', 'Impresoras multifuncionales y láser', TRUE, 3),
  ('Lector', 'lector', 'Lectores de código de barras', TRUE, 4),
  ('Mouse', 'mouse', 'Mouse alámbricos, inalámbricos y gaming', TRUE, 5),
  ('Pad Mouse', 'pad-mouse', 'Pad mouse para oficina y gaming', TRUE, 6),
  ('Parlante', 'parlante', 'Parlantes para computador y portátiles', TRUE, 7),
  ('Reguladores', 'reguladores', 'Reguladores de voltaje para proteger tus equipos', TRUE, 8),
  ('Teclados', 'teclados', 'Teclados mecánicos, de membrana e inalámbricos', TRUE, 9),
  ('UPS', 'ups', 'Sistemas de respaldo de energía', TRUE, 10)
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  description = VALUES(description),
  is_active = IF(deleted_at IS NOT NULL, TRUE, is_active),
  deleted_at = NULL,
  sort_order = VALUES(sort_order);

UPDATE categories c JOIN categories p ON p.slug = 'partes' AND p.deleted_at IS NULL
SET c.parent_id = p.id
WHERE c.deleted_at IS NULL AND c.slug IN ('amd-2', 'boards', 'caja', 'chasis', 'discos-duros', 'disipadores', 'fuente', 'memoria-ram', 'pasta-termica', 'procesador', 'refrigeracion-disipador', 'tarjetas-graficas', 'ventilador');
UPDATE categories c JOIN categories p ON p.slug = 'equipos' AND p.deleted_at IS NULL
SET c.parent_id = p.id
WHERE c.deleted_at IS NULL AND c.slug IN ('computadores', 'monitores');
UPDATE categories c JOIN categories p ON p.slug = 'accesorios' AND p.deleted_at IS NULL
SET c.parent_id = p.id
WHERE c.deleted_at IS NULL AND c.slug IN ('camara', 'combos', 'impresoras', 'lector', 'mouse', 'pad-mouse', 'parlante', 'reguladores', 'teclados', 'ups');
UPDATE categories SET parent_id = NULL
WHERE deleted_at IS NULL AND slug IN ('partes', 'equipos', 'accesorios', 'ultimas-unidades');

-- ------------------------------------------------------------
-- MARCAS (por slug)
-- ------------------------------------------------------------
INSERT INTO brands (name, slug, description, is_active) VALUES
  ('Intel', 'intel', 'Procesadores y componentes Intel', TRUE),
  ('AMD', 'amd', 'Procesadores y gráficos AMD', TRUE),
  ('NVIDIA', 'nvidia', 'Tarjetas gráficas y tecnologías NVIDIA', TRUE),
  ('Genérico', 'generico', 'Accesorios y componentes sin marca específica', TRUE),
  ('ASUS', 'asus', 'Tarjetas madre, gráficas, portátiles y monitores ASUS', TRUE),
  ('MSI', 'msi', 'Componentes y equipos gaming MSI', TRUE),
  ('Cooler Master', 'cooler-master', 'Refrigeración, chasis y fuentes Cooler Master', TRUE),
  ('Toshiba', 'toshiba', 'Almacenamiento Toshiba', TRUE),
  ('LG', 'lg', 'Monitores y electrónica LG', TRUE),
  ('Samsung', 'samsung', 'Monitores, memorias y almacenamiento Samsung', TRUE),
  ('Acer', 'acer', 'Portátiles, equipos y monitores Acer', TRUE),
  ('Epson', 'epson', 'Impresoras y consumibles Epson', TRUE),
  ('HP', 'hp', 'Equipos e impresoras HP', TRUE),
  ('Gigabyte', 'gigabyte', 'Tarjetas madre y gráficas Gigabyte', TRUE),
  ('Wacom', 'wacom', 'Tabletas gráficas Wacom', TRUE),
  ('Canon', 'canon', 'Impresoras y cámaras Canon', TRUE),
  ('Kingston', 'kingston', 'Memorias y almacenamiento Kingston', TRUE)
ON DUPLICATE KEY UPDATE description = VALUES(description), is_active = TRUE;

-- ------------------------------------------------------------
-- PRODUCTOS DE EJEMPLO (EAN-13 válidos de prueba, prefijo 770)
-- category_id y brand_id se resuelven por slug.
-- Las zonas de envío las crea el esquema/migrate.js.
-- ------------------------------------------------------------
INSERT IGNORE INTO `products` (
  `category_id`, `brand_id`, `name`, `slug`, `sku`, `barcode`, `short_description`, `description`,
  `specifications`, `features`, `warranty`, `price`, `original_price`, `discount_percent`,
  `cost_price`, `stock`, `min_stock`, `weight`, `dimensions`, `is_active`, `is_featured`,
  `is_new`, `is_on_sale`, `meta_title`, `meta_description`
) VALUES
((SELECT id FROM categories WHERE slug = 'procesador' LIMIT 1), (SELECT id FROM brands WHERE slug = 'intel' LIMIT 1),
 'Intel Core i5-12400F', 'intel-core-i5-12400f', 'PROC-001', '7700001000018',
 'Procesador Intel Core i5 de 12.ª generación para gaming y productividad.',
 '<p>6 núcleos y 12 hilos, 2.5 GHz base y hasta 4.4 GHz en turbo. Socket LGA 1700. No incluye gráficos integrados: requiere tarjeta gráfica dedicada.</p>',
 JSON_OBJECT('Núcleos', '6', 'Hilos', '12', 'Socket', 'LGA 1700', 'Frecuencia', '2.5 GHz - 4.4 GHz', 'Gráficos integrados', 'No'),
 JSON_ARRAY('12.ª generación', 'Gaming y productividad', 'Incluye disipador'),
 '3 años', 899000, NULL, 0, 720000, 15, 3, 0.18, '11.5 x 7.5 x 3.5 cm',
 TRUE, TRUE, FALSE, FALSE, 'Intel Core i5-12400F', 'Procesador Intel Core i5 de 12.ª generación para gaming y productividad.'),

((SELECT id FROM categories WHERE slug = 'procesador' LIMIT 1), (SELECT id FROM brands WHERE slug = 'amd' LIMIT 1),
 'AMD Ryzen 5 5600X', 'amd-ryzen-5-5600x', 'PROC-002', '7700001000025',
 'Procesador AMD Ryzen 5 5600X, 6 núcleos para gaming.',
 '<p>6 núcleos y 12 hilos con arquitectura Zen 3, socket AM4 y hasta 4.6 GHz en boost. Incluye disipador Wraith Stealth.</p>',
 JSON_OBJECT('Núcleos', '6', 'Hilos', '12', 'Socket', 'AM4', 'Frecuencia', '3.7 GHz - 4.6 GHz', 'Gráficos integrados', 'No'),
 JSON_ARRAY('Arquitectura Zen 3', 'Alto rendimiento en gaming', 'Incluye disipador'),
 '3 años', 749000, NULL, 0, 650000, 20, 5, 0.17, '11 x 11 x 3 cm',
 TRUE, FALSE, TRUE, FALSE, 'AMD Ryzen 5 5600X', 'Procesador AMD Ryzen 5 5600X, 6 núcleos para gaming.'),

((SELECT id FROM categories WHERE slug = 'amd-2' LIMIT 1), (SELECT id FROM brands WHERE slug = 'amd' LIMIT 1),
 'AMD Ryzen 5 5600GT', 'amd-ryzen-5-5600gt', 'AMD-001', '7700001000032',
 'Procesador AMD Ryzen 5 5600GT con gráficos integrados Radeon.',
 '<p>6 núcleos y 12 hilos, socket AM4, hasta 4.6 GHz y gráficos Radeon integrados: ideal para armar un equipo sin tarjeta gráfica dedicada.</p>',
 JSON_OBJECT('Núcleos', '6', 'Hilos', '12', 'Socket', 'AM4', 'Frecuencia', '3.6 GHz - 4.6 GHz', 'Gráficos integrados', 'Radeon Graphics'),
 JSON_ARRAY('Gráficos integrados', 'Incluye disipador', 'Ideal para oficina y estudio'),
 '3 años', 619000, NULL, 0, 520000, 10, 3, 0.17, '11 x 11 x 3 cm',
 TRUE, FALSE, FALSE, FALSE, 'AMD Ryzen 5 5600GT', 'Procesador AMD Ryzen 5 5600GT con gráficos integrados Radeon.'),

((SELECT id FROM categories WHERE slug = 'boards' LIMIT 1), (SELECT id FROM brands WHERE slug = 'asus' LIMIT 1),
 'ASUS PRIME B660M-K D4', 'asus-prime-b660m-k-d4', 'BOARD-001', '7700001000049',
 'Tarjeta madre Micro-ATX LGA 1700 con memoria DDR4.',
 '<p>Tarjeta madre para procesadores Intel de 12.ª y 13.ª generación (la 13.ª puede requerir actualizar la BIOS). Formato Micro-ATX, memoria DDR4, ranura M.2 y puertos USB 3.2.</p>',
 JSON_OBJECT('Socket', 'LGA 1700', 'Chipset', 'Intel B660', 'Formato', 'Micro-ATX', 'Memoria', 'DDR4'),
 JSON_ARRAY('Soporte DDR4', 'Ranura M.2', 'Puertos USB 3.2'),
 '3 años', 489000, NULL, 0, 360000, 10, 2, 0.6, '24 x 20 x 5 cm',
 TRUE, FALSE, FALSE, FALSE, 'ASUS PRIME B660M-K D4', 'Tarjeta madre Micro-ATX LGA 1700 con memoria DDR4.'),

((SELECT id FROM categories WHERE slug = 'caja' LIMIT 1), (SELECT id FROM brands WHERE slug = 'generico' LIMIT 1),
 'Caja ATX Mid Tower Frontal Mesh', 'caja-atx-mid-tower-frontal-mesh', 'CAJA-001', '7700001000056',
 'Caja ATX mid tower con frontal en malla para mejor flujo de aire.',
 '<p>Caja con espacio para tarjetas madre ATX, frontal en malla y ventilador trasero preinstalado.</p>',
 JSON_OBJECT('Formato', 'Mid Tower ATX', 'Material', 'Acero SPCC', 'Ventiladores', '1x 120 mm'),
 JSON_ARRAY('Frontal en malla', 'Buen flujo de aire', 'Gestión de cables'),
 '1 año', 169000, NULL, 0, 100000, 12, 3, 4.8, '41 x 19 x 43 cm',
 TRUE, FALSE, FALSE, FALSE, 'Caja ATX Mid Tower Frontal Mesh', 'Caja ATX mid tower con frontal en malla para mejor flujo de aire.'),

((SELECT id FROM categories WHERE slug = 'chasis' LIMIT 1), (SELECT id FROM brands WHERE slug = 'generico' LIMIT 1),
 'Chasis Mid Tower RGB Vidrio Templado', 'chasis-mid-tower-rgb', 'CHASIS-001', '7700001000063',
 'Gabinete mid tower con panel lateral de vidrio templado y ventiladores RGB.',
 '<p>Chasis para tarjetas madre ATX con panel lateral de vidrio templado, 3 ventiladores ARGB preinstalados y espacio para tarjetas gráficas largas.</p>',
 JSON_OBJECT('Formato', 'Mid Tower', 'Material', 'SPCC + vidrio templado', 'Ventiladores', '3x 120 mm ARGB'),
 JSON_ARRAY('Vidrio templado', 'Iluminación ARGB', 'Espacio para GPU largas'),
 '1 año', 219000, NULL, 0, 110000, 15, 3, 5.5, '42 x 20 x 45 cm',
 TRUE, TRUE, FALSE, FALSE, 'Chasis Mid Tower RGB Vidrio Templado', 'Gabinete mid tower con panel lateral de vidrio templado y ventiladores RGB.'),

((SELECT id FROM categories WHERE slug = 'discos-duros' LIMIT 1), (SELECT id FROM brands WHERE slug = 'kingston' LIMIT 1),
 'SSD NVMe Kingston NV2 1TB', 'ssd-nvme-kingston-nv2-1tb', 'DISCO-001', '7700001000070',
 'Unidad SSD NVMe PCIe 4.0 de 1TB, lectura de hasta 3500 MB/s.',
 '<p>SSD M.2 NVMe PCIe 4.0 con lectura de hasta 3500 MB/s. Ideal para el sistema operativo y para reducir tiempos de carga.</p>',
 JSON_OBJECT('Capacidad', '1TB', 'Interfaz', 'NVMe PCIe 4.0', 'Formato', 'M.2 2280', 'Lectura', 'Hasta 3500 MB/s'),
 JSON_ARRAY('Alta velocidad', 'Bajo consumo', 'Formato M.2'),
 '3 años', 259000, NULL, 0, 150000, 25, 5, 0.01, '8 x 2.2 x 0.4 cm',
 TRUE, TRUE, FALSE, FALSE, 'SSD NVMe Kingston NV2 1TB', 'Unidad SSD NVMe PCIe 4.0 de 1TB, lectura de hasta 3500 MB/s.'),

((SELECT id FROM categories WHERE slug = 'discos-duros' LIMIT 1), (SELECT id FROM brands WHERE slug = 'toshiba' LIMIT 1),
 'Disco Duro Toshiba P300 1TB 7200 RPM', 'disco-duro-toshiba-p300-1tb', 'DISCO-002', '7700001000087',
 'Disco duro interno de 3.5" y 1TB, SATA III a 7200 RPM.',
 '<p>Disco duro de escritorio de 1TB con interfaz SATA III, 7200 RPM y 64 MB de caché. Almacenamiento confiable para el día a día.</p>',
 JSON_OBJECT('Capacidad', '1TB', 'Interfaz', 'SATA III 6 Gb/s', 'Velocidad', '7200 RPM', 'Caché', '64 MB', 'Formato', '3.5"'),
 JSON_ARRAY('7200 RPM', 'Para escritorio', 'Gran capacidad'),
 '2 años', 229000, NULL, 0, 150000, 20, 4, 0.45, '14.7 x 10.2 x 2.6 cm',
 TRUE, FALSE, FALSE, FALSE, 'Disco Duro Toshiba P300 1TB 7200 RPM', 'Disco duro interno de 3.5" y 1TB, SATA III a 7200 RPM.'),

((SELECT id FROM categories WHERE slug = 'disipadores' LIMIT 1), (SELECT id FROM brands WHERE slug = 'generico' LIMIT 1),
 'Disipador de Aire RGB 120 mm', 'disipador-aire-rgb', 'DISIP-001', '7700001000094',
 'Disipador de aire con iluminación RGB, compatible con Intel y AMD.',
 '<p>Disipador con 4 tubos de calor y ventilador PWM de 120 mm con iluminación RGB.</p>',
 JSON_OBJECT('Tamaño', '120 mm', 'Compatibilidad', 'Intel / AMD', 'Tubos de calor', '4'),
 JSON_ARRAY('Iluminación RGB', 'Alto flujo de aire', 'Bajo ruido'),
 '1 año', 129000, NULL, 0, 65000, 30, 8, 0.45, '13 x 10 x 15 cm',
 TRUE, FALSE, FALSE, FALSE, 'Disipador de Aire RGB 120 mm', 'Disipador de aire con iluminación RGB, compatible con Intel y AMD.'),

((SELECT id FROM categories WHERE slug = 'fuente' LIMIT 1), (SELECT id FROM brands WHERE slug = 'generico' LIMIT 1),
 'Fuente de Poder 650W 80 Plus Gold Semi-modular', 'fuente-poder-650w-80-plus-gold', 'FUENTE-001', '7700001000100',
 'Fuente de 650W con certificación 80 Plus Gold y cableado semi-modular.',
 '<p>Fuente de poder de 650W con certificación 80 Plus Gold y diseño semi-modular para un cableado más ordenado. Incluye protecciones OCP y OVP.</p>',
 JSON_OBJECT('Potencia', '650W', 'Certificación', '80 Plus Gold', 'Cableado', 'Semi-modular'),
 JSON_ARRAY('Alta eficiencia', 'Cableado semi-modular', 'Protecciones OCP/OVP'),
 '3 años', 289000, NULL, 0, 180000, 18, 4, 1.5, '16 x 15 x 8.6 cm',
 TRUE, FALSE, FALSE, FALSE, 'Fuente de Poder 650W 80 Plus Gold Semi-modular', 'Fuente de 650W con certificación 80 Plus Gold y cableado semi-modular.'),

((SELECT id FROM categories WHERE slug = 'memoria-ram' LIMIT 1), (SELECT id FROM brands WHERE slug = 'kingston' LIMIT 1),
 'Memoria RAM Kingston FURY Beast 16GB DDR4 3200 MHz', 'memoria-ram-kingston-fury-beast-16gb-ddr4', 'RAM-001', '7700001000117',
 'Módulo de memoria RAM de 16GB DDR4 a 3200 MHz para desktop.',
 '<p>Módulo DIMM de 16GB DDR4 a 3200 MHz compatible con tarjetas madre Intel y AMD de la plataforma DDR4.</p>',
 JSON_OBJECT('Capacidad', '16GB', 'Tipo', 'DDR4 DIMM', 'Frecuencia', '3200 MHz'),
 JSON_ARRAY('Alta frecuencia', 'Compatible Intel/AMD', 'Plug and play'),
 'Garantía del fabricante', 145000, NULL, 0, 80000, 50, 10, 0.03, '13 x 4 x 1.3 cm',
 TRUE, FALSE, TRUE, FALSE, 'Memoria RAM Kingston FURY Beast 16GB DDR4 3200 MHz', 'Módulo de memoria RAM de 16GB DDR4 a 3200 MHz para desktop.'),

((SELECT id FROM categories WHERE slug = 'pasta-termica' LIMIT 1), (SELECT id FROM brands WHERE slug = 'generico' LIMIT 1),
 'Pasta Térmica 4g', 'pasta-termica-4g', 'PASTA-001', '7700001000124',
 'Pasta térmica de alto rendimiento para CPU y GPU.',
 '<p>Jeringa de 4 g de pasta térmica para mejorar la transferencia de calor entre el procesador y el disipador.</p>',
 JSON_OBJECT('Contenido', '4 g', 'Uso', 'CPU / GPU'),
 JSON_ARRAY('Fácil aplicación', 'Alta conductividad térmica'),
 '30 días', 15000, NULL, 0, 6000, 60, 10, 0.02, '10 x 3 x 2 cm',
 TRUE, FALSE, FALSE, FALSE, 'Pasta Térmica 4g', 'Pasta térmica de alto rendimiento para CPU y GPU.'),

((SELECT id FROM categories WHERE slug = 'refrigeracion-disipador' LIMIT 1), (SELECT id FROM brands WHERE slug = 'generico' LIMIT 1),
 'Refrigeración Líquida AIO 240 mm', 'refrigeracion-liquida-240mm', 'REFR-001', '7700001000131',
 'Kit de refrigeración líquida todo en uno de 240 mm para CPU.',
 '<p>Sistema AIO con radiador de 240 mm, bomba de alta presión y dos ventiladores PWM de 120 mm. Compatible con Intel y AMD.</p>',
 JSON_OBJECT('Radiador', '240 mm', 'Compatibilidad', 'Intel / AMD', 'Ventiladores', '2x 120 mm PWM'),
 JSON_ARRAY('Alto rendimiento', 'Fácil instalación', 'Control PWM'),
 '2 años', 459000, 499000, 8, 280000, 12, 3, 1.2, '27 x 12 x 5 cm',
 TRUE, TRUE, FALSE, TRUE, 'Refrigeración Líquida AIO 240 mm', 'Kit de refrigeración líquida todo en uno de 240 mm para CPU.'),

((SELECT id FROM categories WHERE slug = 'tarjetas-graficas' LIMIT 1), (SELECT id FROM brands WHERE slug = 'asus' LIMIT 1),
 'ASUS Dual GeForce RTX 4060 OC 8GB GDDR6', 'asus-dual-rtx-4060-oc-8gb', 'GPU-001', '7700001000148',
 'Tarjeta gráfica NVIDIA GeForce RTX 4060 con 8GB GDDR6.',
 '<p>Tarjeta gráfica con arquitectura Ada Lovelace, ideal para gaming en 1080p con Ray Tracing y DLSS 3.</p>',
 JSON_OBJECT('Memoria', '8GB GDDR6', 'Interfaz', 'PCIe 4.0', 'Salidas', 'HDMI + DisplayPort'),
 JSON_ARRAY('Ray Tracing', 'DLSS 3', 'Bajo consumo'),
 '3 años', 1899000, 1999000, 5, 1200000, 8, 2, 0.8, '24 x 12 x 4.5 cm',
 TRUE, TRUE, FALSE, TRUE, 'ASUS Dual GeForce RTX 4060 OC 8GB GDDR6', 'Tarjeta gráfica NVIDIA GeForce RTX 4060 con 8GB GDDR6.'),

((SELECT id FROM categories WHERE slug = 'ventilador' LIMIT 1), (SELECT id FROM brands WHERE slug = 'generico' LIMIT 1),
 'Ventilador 120 mm ARGB', 'ventilador-120mm-argb', 'VENT-001', '7700001000155',
 'Ventilador de 120 mm con iluminación ARGB para chasis.',
 '<p>Ventilador silencioso de 120 mm con iluminación ARGB, ideal para mejorar el flujo de aire del chasis.</p>',
 JSON_OBJECT('Tamaño', '120 mm', 'Iluminación', 'ARGB', 'Conector', '3 pines ARGB + 4 pines PWM'),
 JSON_ARRAY('Iluminación ARGB', 'Bajo ruido'),
 '6 meses', 35000, NULL, 0, 18000, 40, 8, 0.15, '12.5 x 12.5 x 2.5 cm',
 TRUE, FALSE, FALSE, FALSE, 'Ventilador 120 mm ARGB', 'Ventilador de 120 mm con iluminación ARGB para chasis.'),

((SELECT id FROM categories WHERE slug = 'computadores' LIMIT 1), (SELECT id FROM brands WHERE slug = 'asus' LIMIT 1),
 'Portátil Gamer ASUS TUF Gaming A15', 'portatil-gamer-asus-tuf-a15', 'COMP-001', '7700001000162',
 'Portátil gamer con Ryzen 7, RTX 4060 y pantalla de 144Hz.',
 '<p>ASUS TUF Gaming A15 con procesador AMD Ryzen 7, tarjeta gráfica RTX 4060, 16GB de RAM y SSD de 512GB. Pantalla de 15.6" Full HD a 144Hz.</p>',
 JSON_OBJECT('Procesador', 'AMD Ryzen 7', 'GPU', 'NVIDIA RTX 4060', 'RAM', '16GB DDR5', 'Almacenamiento', '512GB NVMe', 'Pantalla', '15.6" FHD 144Hz'),
 JSON_ARRAY('Pantalla 144Hz', 'Teclado retroiluminado', 'Diseño resistente'),
 '1 año', 5499000, NULL, 0, 4200000, 6, 1, 2.3, '36 x 25 x 2.5 cm',
 TRUE, TRUE, FALSE, FALSE, 'Portátil Gamer ASUS TUF Gaming A15', 'Portátil gamer con Ryzen 7, RTX 4060 y pantalla de 144Hz.'),

((SELECT id FROM categories WHERE slug = 'computadores' LIMIT 1), (SELECT id FROM brands WHERE slug = 'generico' LIMIT 1),
 'PC de Escritorio Core i7 + RTX 4060', 'pc-escritorio-i7-rtx4060', 'COMP-002', '7700001000179',
 'Computador de escritorio armado: Core i7, RTX 4060, 16GB RAM y SSD de 1TB.',
 '<p>PC para gaming y productividad con procesador Intel Core i7, tarjeta gráfica RTX 4060, 16GB de RAM y SSD NVMe de 1TB. Ensamblado y probado.</p>',
 JSON_OBJECT('Procesador', 'Intel Core i7', 'GPU', 'NVIDIA RTX 4060', 'RAM', '16GB DDR5', 'Almacenamiento', '1TB NVMe'),
 JSON_ARRAY('Ensamblado y probado', 'Listo para usar'),
 '1 año', 6299000, NULL, 0, 5100000, 4, 1, 8.5, '50 x 25 x 55 cm',
 TRUE, TRUE, FALSE, FALSE, 'PC de Escritorio Core i7 + RTX 4060', 'Computador de escritorio armado: Core i7, RTX 4060, 16GB RAM y SSD de 1TB.'),

((SELECT id FROM categories WHERE slug = 'computadores' LIMIT 1), (SELECT id FROM brands WHERE slug = 'hp' LIMIT 1),
 'Todo en Uno HP 24" Core i5', 'todo-en-uno-hp-24-core-i5', 'COMP-003', '7700001000186',
 'Equipo todo en uno de 24" con Intel Core i5, 8GB RAM y SSD de 512GB.',
 '<p>All-in-one con pantalla Full HD de 24", procesador Intel Core i5, 8GB de RAM y SSD de 512GB. Ideal para oficina y estudio.</p>',
 JSON_OBJECT('Pantalla', '24" FHD', 'Procesador', 'Intel Core i5', 'RAM', '8GB DDR4', 'Almacenamiento', '512GB SSD'),
 JSON_ARRAY('Todo en uno', 'Compacto', 'Cámara web integrada'),
 '1 año', 3499000, NULL, 0, 2800000, 5, 1, 7.8, '55 x 20 x 45 cm',
 TRUE, FALSE, FALSE, FALSE, 'Todo en Uno HP 24" Core i5', 'Equipo todo en uno de 24" con Intel Core i5, 8GB RAM y SSD de 512GB.'),

((SELECT id FROM categories WHERE slug = 'monitores' LIMIT 1), (SELECT id FROM brands WHERE slug = 'lg' LIMIT 1),
 'Monitor LG 24MP400-B 24" IPS Full HD', 'monitor-lg-24mp400-b-24-ips', 'MON-001', '7700001000193',
 'Monitor de 24" IPS Full HD a 75Hz con AMD FreeSync.',
 '<p>Monitor IPS de 23.8" con resolución Full HD, 75Hz y AMD FreeSync. Colores consistentes desde cualquier ángulo para oficina y estudio.</p>',
 JSON_OBJECT('Tamaño', '23.8"', 'Panel', 'IPS', 'Resolución', '1920x1080', 'Refresco', '75Hz'),
 JSON_ARRAY('Panel IPS', 'AMD FreeSync', 'Diseño sin bordes'),
 '1 año', 549000, NULL, 0, 420000, 14, 3, 3.0, '55 x 42 x 18 cm',
 TRUE, FALSE, TRUE, FALSE, 'Monitor LG 24MP400-B 24" IPS Full HD', 'Monitor de 24" IPS Full HD a 75Hz con AMD FreeSync.'),

((SELECT id FROM categories WHERE slug = 'monitores' LIMIT 1), (SELECT id FROM brands WHERE slug = 'generico' LIMIT 1),
 'Monitor Gamer 27" QHD 165Hz', 'monitor-gamer-27-165hz', 'MON-002', '7700001000209',
 'Monitor gamer de 27" con resolución QHD y 165Hz.',
 '<p>Monitor de 27" con panel IPS, resolución QHD (2560x1440), 165Hz de refresco y 1ms de respuesta.</p>',
 JSON_OBJECT('Tamaño', '27"', 'Panel', 'IPS', 'Resolución', '2560x1440', 'Refresco', '165Hz', 'Respuesta', '1ms'),
 JSON_ARRAY('Panel IPS', '165Hz', 'Resolución QHD'),
 '1 año', 1299000, NULL, 0, 980000, 10, 2, 5.2, '62 x 45 x 20 cm',
 TRUE, FALSE, FALSE, FALSE, 'Monitor Gamer 27" QHD 165Hz', 'Monitor gamer de 27" con resolución QHD y 165Hz.'),

((SELECT id FROM categories WHERE slug = 'camara' LIMIT 1), (SELECT id FROM brands WHERE slug = 'generico' LIMIT 1),
 'Cámara Web Full HD 1080p con Micrófono', 'camara-web-full-hd-1080p', 'CAM-001', '7700001000216',
 'Cámara web 1080p con micrófono integrado para videollamadas.',
 '<p>Cámara web Full HD con micrófono integrado, conexión USB plug and play y enfoque fijo.</p>',
 JSON_OBJECT('Resolución', '1920x1080', 'Conexión', 'USB', 'Micrófono', 'Integrado'),
 JSON_ARRAY('Plug and play', 'Micrófono integrado'),
 '6 meses', 79000, NULL, 0, 45000, 25, 5, 0.15, '10 x 6 x 6 cm',
 TRUE, FALSE, FALSE, FALSE, 'Cámara Web Full HD 1080p con Micrófono', 'Cámara web 1080p con micrófono integrado para videollamadas.'),

((SELECT id FROM categories WHERE slug = 'combos' LIMIT 1), (SELECT id FROM brands WHERE slug = 'generico' LIMIT 1),
 'Combo Teclado y Mouse Inalámbrico', 'combo-teclado-mouse-inalambrico', 'COMBO-001', '7700001000223',
 'Combo de teclado y mouse inalámbricos para oficina y hogar.',
 '<p>Combo con teclado de membrana silencioso y mouse ergonómico, conexión inalámbrica con un solo receptor USB.</p>',
 JSON_OBJECT('Tipo', 'Membrana', 'Conectividad', 'Inalámbrico 2.4GHz', 'Alcance', '10 m'),
 JSON_ARRAY('Silencioso', 'Un solo receptor USB', 'Compacto'),
 '6 meses', 119000, NULL, 0, 72000, 35, 8, 0.5, '38 x 10 x 4 cm',
 TRUE, FALSE, FALSE, FALSE, 'Combo Teclado y Mouse Inalámbrico', 'Combo de teclado y mouse inalámbricos para oficina y hogar.'),

((SELECT id FROM categories WHERE slug = 'impresoras' LIMIT 1), (SELECT id FROM brands WHERE slug = 'epson' LIMIT 1),
 'Epson EcoTank L3250 Multifuncional WiFi', 'epson-ecotank-l3250', 'IMP-001', '7700001000230',
 'Impresora multifuncional de tanque de tinta con WiFi.',
 '<p>Impresora multifuncional que imprime, escanea y copia, con sistema de tanque de tinta recargable y conexión WiFi.</p>',
 JSON_OBJECT('Tipo', 'Tanque de tinta', 'Funciones', 'Imprime, escanea y copia', 'Conectividad', 'WiFi / USB'),
 JSON_ARRAY('Tanque de tinta', 'WiFi', 'Bajo costo por página'),
 '1 año', 899000, NULL, 0, 700000, 8, 2, 3.9, '37.5 x 34.7 x 17.9 cm',
 TRUE, TRUE, FALSE, FALSE, 'Epson EcoTank L3250 Multifuncional WiFi', 'Impresora multifuncional de tanque de tinta con WiFi.'),

((SELECT id FROM categories WHERE slug = 'lector' LIMIT 1), (SELECT id FROM brands WHERE slug = 'generico' LIMIT 1),
 'Lector de Código de Barras Láser USB', 'lector-codigo-barras-laser-usb', 'LECT-001', '7700001000247',
 'Lector de código de barras láser con conexión USB para punto de venta.',
 '<p>Lector láser plug and play con conexión USB, ideal para punto de venta e inventarios.</p>',
 JSON_OBJECT('Tipo', 'Láser 1D', 'Conexión', 'USB', 'Soporte', 'Incluido'),
 JSON_ARRAY('Plug and play', 'Para punto de venta'),
 '6 meses', 129000, NULL, 0, 80000, 15, 3, 0.3, '17 x 7 x 10 cm',
 TRUE, FALSE, FALSE, FALSE, 'Lector de Código de Barras Láser USB', 'Lector de código de barras láser con conexión USB para punto de venta.'),

((SELECT id FROM categories WHERE slug = 'mouse' LIMIT 1), (SELECT id FROM brands WHERE slug = 'generico' LIMIT 1),
 'Mouse Inalámbrico Ergonómico', 'mouse-inalambrico-ergonomico', 'MOUSE-001', '7700001000254',
 'Mouse inalámbrico ergonómico con sensor de 2400 DPI.',
 '<p>Mouse inalámbrico con sensor óptico, diseño ergonómico y batería recargable.</p>',
 JSON_OBJECT('DPI', '2400', 'Conectividad', 'Inalámbrico 2.4GHz', 'Batería', 'Recargable'),
 JSON_ARRAY('Ergonómico', 'Silencioso', 'Batería recargable'),
 '6 meses', 89000, NULL, 0, 55000, 50, 10, 0.12, '10 x 6 x 4 cm',
 TRUE, FALSE, FALSE, FALSE, 'Mouse Inalámbrico Ergonómico', 'Mouse inalámbrico ergonómico con sensor de 2400 DPI.'),

((SELECT id FROM categories WHERE slug = 'pad-mouse' LIMIT 1), (SELECT id FROM brands WHERE slug = 'generico' LIMIT 1),
 'Pad Mouse Gamer XL 80x30 cm', 'pad-mouse-gamer-xl-80x30', 'PAD-001', '7700001000261',
 'Pad mouse extendido con base antideslizante.',
 '<p>Pad mouse extendido de 80x30 cm con superficie suave y base de caucho antideslizante.</p>',
 JSON_OBJECT('Tamaño', '80 x 30 cm', 'Base', 'Caucho antideslizante'),
 JSON_ARRAY('Tamaño XL', 'Base antideslizante'),
 '30 días', 35000, NULL, 0, 18000, 40, 8, 0.3, '80 x 30 x 0.3 cm',
 TRUE, FALSE, FALSE, FALSE, 'Pad Mouse Gamer XL 80x30 cm', 'Pad mouse extendido con base antideslizante.'),

((SELECT id FROM categories WHERE slug = 'parlante' LIMIT 1), (SELECT id FROM brands WHERE slug = 'generico' LIMIT 1),
 'Parlante Bluetooth Portátil', 'parlante-bluetooth-portatil', 'PARL-001', '7700001000278',
 'Parlante portátil con Bluetooth y batería recargable.',
 '<p>Parlante portátil con conexión Bluetooth, entrada auxiliar y batería recargable.</p>',
 JSON_OBJECT('Conectividad', 'Bluetooth / Aux', 'Batería', 'Recargable'),
 JSON_ARRAY('Portátil', 'Bluetooth'),
 '6 meses', 89000, NULL, 0, 52000, 20, 5, 0.4, '17 x 7 x 7 cm',
 TRUE, FALSE, FALSE, FALSE, 'Parlante Bluetooth Portátil', 'Parlante portátil con Bluetooth y batería recargable.'),

((SELECT id FROM categories WHERE slug = 'reguladores' LIMIT 1), (SELECT id FROM brands WHERE slug = 'generico' LIMIT 1),
 'Regulador de Voltaje 1000VA 6 Tomas', 'regulador-voltaje-1000va', 'REG-001', '7700001000285',
 'Regulador de voltaje de 1000VA con 6 tomas.',
 '<p>Regulador de voltaje para proteger tus equipos de picos y variaciones de energía, con 6 tomas.</p>',
 JSON_OBJECT('Potencia', '1000VA', 'Tomas', '6'),
 JSON_ARRAY('Protección contra picos', '6 tomas'),
 '1 año', 99000, NULL, 0, 60000, 15, 3, 1.2, '30 x 10 x 8 cm',
 TRUE, FALSE, FALSE, FALSE, 'Regulador de Voltaje 1000VA 6 Tomas', 'Regulador de voltaje de 1000VA con 6 tomas.'),

((SELECT id FROM categories WHERE slug = 'teclados' LIMIT 1), (SELECT id FROM brands WHERE slug = 'generico' LIMIT 1),
 'Teclado Mecánico RGB Switch Red', 'teclado-mecanico-rgb-switch-red', 'TEC-001', '7700001000292',
 'Teclado mecánico gaming con switches Red y retroiluminación RGB.',
 '<p>Teclado mecánico con switches lineales Red, retroiluminación RGB y construcción metálica.</p>',
 JSON_OBJECT('Tipo', 'Mecánico', 'Switch', 'Red', 'Conectividad', 'USB'),
 JSON_ARRAY('Retroiluminación RGB', 'Anti-ghosting', 'Switches lineales'),
 '1 año', 189000, NULL, 0, 95000, 30, 8, 0.8, '44 x 14 x 4 cm',
 TRUE, TRUE, FALSE, FALSE, 'Teclado Mecánico RGB Switch Red', 'Teclado mecánico gaming con switches Red y retroiluminación RGB.'),

((SELECT id FROM categories WHERE slug = 'ups' LIMIT 1), (SELECT id FROM brands WHERE slug = 'generico' LIMIT 1),
 'UPS 750VA con Regulador', 'ups-750va', 'UPS-001', '7700001000308',
 'UPS de 750VA para respaldo de energía de equipos de cómputo.',
 '<p>UPS de 750VA con regulador integrado y varias tomas con respaldo de batería para PC y accesorios.</p>',
 JSON_OBJECT('Potencia', '750VA', 'Tipo', 'Interactivo'),
 JSON_ARRAY('Respaldo de energía', 'Regulador integrado'),
 '1 año', 259000, NULL, 0, 170000, 10, 2, 4.5, '28 x 10 x 14 cm',
 TRUE, FALSE, FALSE, FALSE, 'UPS 750VA con Regulador', 'UPS de 750VA para respaldo de energía de equipos de cómputo.'),

((SELECT id FROM categories WHERE slug = 'accesorios' LIMIT 1), (SELECT id FROM brands WHERE slug = 'generico' LIMIT 1),
 'Diadema Gaming 7.1 Surround', 'diadema-gaming-71-surround', 'AUDIO-001', '7700001000315',
 'Diadema gaming con sonido envolvente 7.1 virtual y micrófono retráctil.',
 '<p>Diadema con controladores de 50 mm, sonido envolvente 7.1 virtual, micrófono retráctil y almohadillas memory foam.</p>',
 JSON_OBJECT('Conectividad', 'USB', 'Sonido', '7.1 virtual', 'Controladores', '50 mm'),
 JSON_ARRAY('Sonido 7.1 virtual', 'Micrófono retráctil', 'Almohadillas memory foam'),
 '6 meses', 159000, NULL, 0, 105000, 25, 5, 0.35, '19 x 17 x 9 cm',
 TRUE, FALSE, FALSE, FALSE, 'Diadema Gaming 7.1 Surround', 'Diadema gaming con sonido envolvente 7.1 virtual y micrófono retráctil.');

-- ------------------------------------------------------------
-- KARDEX: inventario inicial (solo si el producto aún no tiene movimientos)
-- ------------------------------------------------------------
INSERT INTO `stock_movements` (`product_id`, `type`, `quantity`, `reason`, `reference_type`)
SELECT p.`id`, 'in', p.`stock`, 'Inventario inicial', 'manual'
FROM `products` p
WHERE p.`sku` IN ('PROC-001', 'PROC-002', 'AMD-001', 'BOARD-001', 'CAJA-001', 'CHASIS-001', 'DISCO-001', 'DISCO-002', 'DISIP-001', 'FUENTE-001', 'RAM-001', 'PASTA-001', 'REFR-001', 'GPU-001', 'VENT-001', 'COMP-001', 'COMP-002', 'COMP-003', 'MON-001', 'MON-002', 'CAM-001', 'COMBO-001', 'IMP-001', 'LECT-001', 'MOUSE-001', 'PAD-001', 'PARL-001', 'REG-001', 'TEC-001', 'UPS-001', 'AUDIO-001')
  AND p.`stock` > 0
  AND NOT EXISTS (SELECT 1 FROM `stock_movements` sm WHERE sm.`product_id` = p.`id`);

-- Nota: las imágenes de producto se cargan desde el panel admin (Cloudinary)
-- o se insertan en `product_images` con las URLs reales de cada producto.