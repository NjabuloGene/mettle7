-- METTLE AND REDOLENT — Supabase setup
-- Run this script once in the Supabase SQL Editor.

create extension if not exists pgcrypto;

create table if not exists public.site_settings (
  id integer primary key default 1,
  hero_image_url text,
  announcement_text text,
  payshap_id text,
  account_holder text,
  bank_name text,
  whatsapp_number text,
  shipping_flat_rate integer default 150
);

create table if not exists public.products (
  id text primary key,
  name text not null,
  volume text not null,
  price integer not null check (price >= 0),
  stock_count integer not null default 0 check (stock_count >= 0),
  in_stock boolean generated always as (stock_count > 0) stored,
  image_url text,
  top_notes text,
  heart_notes text,
  base_notes text,
  description text
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_ref text,
  customer_name text not null,
  customer_phone text not null,
  delivery_address text not null,
  items jsonb not null,
  total_zar integer not null check (total_zar >= 0),
  payment_status text not null default 'Pending PayShap',
  created_at timestamptz not null default now()
);

insert into public.site_settings
  (id, announcement_text, payshap_id, account_holder, whatsapp_number, shipping_flat_rate)
values
  (1, 'Crafted in Hazyview • Flat-Rate R150 Courier Nationwide • PayShap Accepted',
   '064 807 2693', 'Mettle and Redolent', '27648072693', 150)
on conflict (id) do update set
  announcement_text = excluded.announcement_text,
  payshap_id = excluded.payshap_id,
  account_holder = excluded.account_holder,
  whatsapp_number = excluded.whatsapp_number,
  shipping_flat_rate = excluded.shipping_flat_rate;

insert into public.products
  (id, name, volume, price, stock_count, image_url, top_notes, heart_notes, base_notes, description)
values
  ('hallucinations', 'Hallucinations', '50ml Premium-Blend Parfum', 450, 12,
   'https://images.unsplash.com/photo-1594035910387-fea47794261f?auto=format&fit=crop&w=1000&q=85',
   'Bergamot, Pink Pepper, Cardamom', 'Iris, Incense, Cashmere Wood', 'White Amber, Sandalwood, Skin Musk',
   'A luminous, enveloping composition with a confident trail and a softly sensual finish.'),
  ('oud-passion', 'Oud Passion', '50ml Eau de Parfum', 380, 12,
   'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?auto=format&fit=crop&w=1000&q=85',
   'Passion Fruit, Saffron', 'Damask Rose, Patchouli', 'Agarwood Oud, Leather, Amber, Vanilla',
   'A vivid meeting of ripe fruit, velvety rose and rich oud.'),
  ('alpha-magnetism', 'Alpha Magnetism', '50ml Eau de Parfum', 350, 12,
   'https://images.unsplash.com/photo-1590736969955-71cc94901144?auto=format&fit=crop&w=1000&q=85',
   'Grapefruit, Black Pepper, Elemi', 'Lavender, Vetiver, Tonka Bean', 'Cedarwood, Ambroxan, Dark Musk',
   'Fresh aromatic notes meet a warm, magnetic woody base.'),
  ('blue-allure', 'Blue Allure', '50ml Eau de Parfum', 320, 12,
   'https://images.unsplash.com/photo-1595425970377-c9703cf48b6d?auto=format&fit=crop&w=1000&q=85',
   'Calabrian Bergamot, Mint, Lemon Zest', 'Ginger, Nutmeg, Jasmine', 'Incense, Cedarwood, White Musk',
   'Bright citrus and cool herbs settle into a clean, quietly captivating finish.'),
  ('i-am-it', 'I AM IT', '50ml Eau de Parfum', 280, 12,
   'https://images.unsplash.com/photo-1594035910387-fea47794261f?auto=format&fit=crop&w=1000&q=85',
   'Saffron, Spun Sugar', 'Damask Rose, Agarwood Oud', 'Warm Vanilla, White Musk',
   'A modern statement of sweet saffron, rose and comforting vanilla.'),
  ('egoist', 'Egoist', '100ml Extrait de Parfum', 1200, 8,
   'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?auto=format&fit=crop&w=1000&q=85',
   'Mandarin, Rosewood, Coriander', 'Cinnamon, Damask Rose, Carnation', 'Sandalwood, Vanilla, Amber, Tobacco',
   'A richly layered extrait, composed for an unmistakable and enduring presence.')
on conflict (id) do update set
  name = excluded.name,
  volume = excluded.volume,
  price = excluded.price,
  image_url = excluded.image_url,
  top_notes = excluded.top_notes,
  heart_notes = excluded.heart_notes,
  base_notes = excluded.base_notes,
  description = excluded.description;

alter table public.site_settings enable row level security;
alter table public.products enable row level security;
alter table public.orders enable row level security;

drop policy if exists "Public can read site settings" on public.site_settings;
create policy "Public can read site settings"
  on public.site_settings for select to anon, authenticated using (true);

drop policy if exists "Authenticated users can update site settings" on public.site_settings;
create policy "Authenticated users can update site settings"
  on public.site_settings for update to authenticated using (true) with check (true);

drop policy if exists "Public can read products" on public.products;
create policy "Public can read products"
  on public.products for select to anon, authenticated using (true);

drop policy if exists "Authenticated users can insert products" on public.products;
create policy "Authenticated users can insert products"
  on public.products for insert to authenticated with check (true);

drop policy if exists "Authenticated users can update products" on public.products;
create policy "Authenticated users can update products"
  on public.products for update to authenticated using (true) with check (true);

drop policy if exists "Authenticated users can delete products" on public.products;
create policy "Authenticated users can delete products"
  on public.products for delete to authenticated using (true);

drop policy if exists "Public can create orders" on public.orders;
create policy "Public can create orders"
  on public.orders for insert to anon, authenticated with check (true);

drop policy if exists "Authenticated users can read orders" on public.orders;
create policy "Authenticated users can read orders"
  on public.orders for select to authenticated using (true);

drop policy if exists "Authenticated users can update orders" on public.orders;
create policy "Authenticated users can update orders"
  on public.orders for update to authenticated using (true) with check (true);

insert into storage.buckets (id, name, public)
values ('perfumes', 'perfumes', true)
on conflict (id) do update set public = true;

drop policy if exists "Authenticated users can upload perfume images" on storage.objects;
create policy "Authenticated users can upload perfume images"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'perfumes');

drop policy if exists "Authenticated users can update perfume images" on storage.objects;
create policy "Authenticated users can update perfume images"
  on storage.objects for update to authenticated
  using (bucket_id = 'perfumes') with check (bucket_id = 'perfumes');

