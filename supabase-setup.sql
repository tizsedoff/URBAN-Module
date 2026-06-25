-- ============================================================
-- URBAN MODULE — Esquema de base de datos para Supabase
-- ============================================================
-- Instrucciones: copiá TODO este archivo y pegalo en
-- Supabase → SQL Editor → New query → RUN
-- ============================================================

-- Tabla de productos
create table products (
  id bigint generated always as identity primary key,
  name text not null,
  cat text not null,
  price integer not null,
  old_price integer,
  img text not null,
  stock integer not null default 0,
  created_at timestamp with time zone default now()
);

-- Tabla de ventas (se llena sola cuando alguien hace "Finalizar compra")
create table sales (
  id bigint generated always as identity primary key,
  product_id bigint,
  product_name text not null,
  qty integer not null,
  unit_price integer not null,
  total integer not null,
  status text not null default 'pendiente',
  created_at timestamp with time zone default now()
);

-- Habilitar acceso público de lectura/escritura
-- (la seguridad real la da la contraseña del panel, no la base de datos,
-- porque este es un sitio 100% frontend sin servidor propio)
alter table products enable row level security;
alter table sales enable row level security;

create policy "Acceso público total a products"
  on products for all
  using (true)
  with check (true);

create policy "Acceso público total a sales"
  on sales for all
  using (true)
  with check (true);

-- ============================================================
-- Productos iniciales (los mismos que ya tenías en la demo)
-- ============================================================
insert into products (name, cat, price, old_price, img, stock) values
  ('No Days Off Hoodie', 'hoodie', 38000, null, 'public/products/hoodie-nodaysoff.jpg', 5),
  ('Burdeos Club Hoodie', 'hoodie', 36000, 42000, 'public/products/hoodie-burdeos.jpg', 3),
  ('Rituals Skull Tee', 'remera', 24000, null, 'public/products/remera-rituals-back.jpg', 4),
  ('Rituals Brand Tee', 'remera', 24000, null, 'public/products/remera-rituals-front.jpg', 4),
  ('Hydriasis Studio Tee', 'remera', 22000, null, 'public/products/remera-hydriasis.jpg', 2),
  ('Cuarto Motivator Tee', 'remera', 23000, 27000, 'public/products/remera-cuarto.jpg', 6),
  ('Slides Mix Pack', 'sliders', 19000, null, 'public/products/sliders.jpg', 8);

-- ============================================================
-- STORAGE: bucket para las fotos que subís desde el panel
-- ============================================================
-- Este paso NO se puede hacer por SQL Editor común, hay que
-- crearlo a mano (ver instrucciones más abajo). Pero las políticas
-- de acceso sí se configuran acá una vez creado el bucket.

-- Permitir que cualquiera pueda LEER las imágenes (necesario para
-- que se vean en la tienda)
create policy "Lectura pública de fotos de productos"
  on storage.objects for select
  using ( bucket_id = 'product-images' );

-- Permitir que cualquiera pueda SUBIR imágenes
-- (la seguridad real la da la contraseña del panel admin)
create policy "Subida pública de fotos de productos"
  on storage.objects for insert
  with check ( bucket_id = 'product-images' );

create policy "Actualización pública de fotos de productos"
  on storage.objects for update
  using ( bucket_id = 'product-images' );

create policy "Borrado público de fotos de productos"
  on storage.objects for delete
  using ( bucket_id = 'product-images' );
