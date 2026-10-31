-- Supabase > SQL Editor mein poora paste karke Run karein
create table if not exists products(
  id uuid primary key default gen_random_uuid(),
  name text not null, category text default 'Ready to Wear',
  price int not null, sale_price int, sizes text[] default '{}',
  description text, images text[] default '{}', featured boolean default false,
  in_stock boolean default true, created_at timestamptz default now());
create table if not exists orders(
  id uuid primary key default gen_random_uuid(),
  customer jsonb, items jsonb, total int, status text default 'new',
  created_at timestamptz default now());
alter table products enable row level security;
alter table orders enable row level security;
create policy "read products" on products for select using (true);
create policy "admin write products" on products for all to authenticated using (true) with check (true);
create policy "anyone place order" on orders for insert with check (true);
create policy "admin read orders" on orders for select to authenticated using (true);
create policy "admin update orders" on orders for update to authenticated using (true);
insert into storage.buckets (id,name,public) values ('products','products',true) on conflict do nothing;
create policy "public view images" on storage.objects for select using (bucket_id='products');
create policy "admin upload images" on storage.objects for insert to authenticated with check (bucket_id='products');
create policy "admin delete images" on storage.objects for delete to authenticated using (bucket_id='products');
