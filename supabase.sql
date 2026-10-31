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

-- ===== Part 2: categories, settings, demo data =====
create table if not exists categories(id uuid primary key default gen_random_uuid(), name text unique not null, group_name text default 'Women', image text, sort int default 0);
create table if not exists settings(key text primary key, value text);
alter table categories enable row level security; alter table settings enable row level security;
create policy "read cats" on categories for select using (true);
create policy "admin cats" on categories for all to authenticated using (true) with check (true);
create policy "read settings" on settings for select using (true);
create policy "admin settings" on settings for all to authenticated using (true) with check (true);
create or replace function seed_img(lbl text, col text) returns text language sql as $f$
 select 'data:image/svg+xml;base64,'||regexp_replace(encode(convert_to('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 400"><defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="'||col||'"/><stop offset="1" stop-color="#ffffff"/></linearGradient></defs><rect width="300" height="400" fill="url(#g)"/><text x="150" y="205" font-size="20" text-anchor="middle" fill="#333" font-family="Georgia">'||lbl||'</text><text x="150" y="240" font-size="13" text-anchor="middle" fill="#555">SAMPLE IMAGE</text></svg>','UTF8'),'base64'),'\s','','g') $f$;
insert into categories(name,group_name,sort,image) select n,g,s,seed_img(n,c) from (values
('Embroidered','Women',1,'#e8c4c4'),('Printed','Women',2,'#c4d8e8'),('Solids','Women',3,'#f0b3c8'),('Co-ords','Women',4,'#e8a98f'),('Formals','Women',5,'#b9a3d6'),('Kurtis','Women',6,'#a9d6c2'),('Unstitched','Women',7,'#f1dc9b'),
('Menswear','Men',8,'#8f9a7a'),('Fragrances','Men',9,'#2b2b2b'),('Girls Suits','Girls',10,'#f2c6d0'),
('Watches','Accessories',11,'#9aa5b1'),('Bags','Accessories',12,'#b58a6a'),('Footwear','Accessories',13,'#a83246'),('Jewellery','Accessories',14,'#e6c46a'),('Scarves','Accessories',15,'#d95a5a'),('Dolls','Accessories',16,'#f7a8d0')
) v(n,g,s,c) on conflict (name) do nothing;
insert into settings(key,value) values ('store_name','CHISHTI FABRICS'),('whatsapp','923001234567'),('email','chishtifebrics@gmail.com'),('announcement','Free delivery on orders above Rs. 5,000 · Cash on Delivery available'),('hero_title','Ready to wear'),('hero_sub','New season collection'),('free_ship_min','5000'),('ship_fee','250'),('currency','Rs.') on conflict do nothing;
insert into products(name,category,price,sale_price,sizes,description,images)
select n,c,p,sp,string_to_array(sz,','),'DEMO PRODUCT - Admin panel se edit ya delete karein.'||E'\nFabric: Cotton\nCare: Dry clean / gentle wash',array[seed_img(n,col),seed_img(n||' back','#d9d2c3')]
from (values
('2 Piece Lawn Suit- Embroidered (Pret)','Embroidered',7990,5990,'XS,S,M,L,XL','#e8c4c4'),('3 Piece Cotton Net Suit- Embroidered','Embroidered',12990,NULL,'S,M,L','#d9a7a7'),
('2 Piece Printed Lawn Suit','Printed',4990,3990,'S,M,L,XL','#c4d8e8'),('Printed Kurta Shalwar','Printed',5490,NULL,'S,M,L','#a8c3dd'),
('Solid Cotton Shirt','Solids',2990,NULL,'S,M,L,XL','#f0b3c8'),('Solid Linen Trouser','Solids',2490,1990,'S,M,L','#e3a1b9'),
('2 Piece Co-ord Set','Co-ords',6990,NULL,'S,M,L','#e8a98f'),('3 Piece Chiffon Suit- Formal','Formals',18990,14990,'S,M,L','#b9a3d6'),
('Silk Kaftan- Embellished','Formals',8990,NULL,'M,L','#a58fc9'),('Cambric Kurti- Embroidered','Kurtis',3990,NULL,'S,M,L,XL','#a9d6c2'),
('Cotton Kurti- Printed','Kurtis',2790,2290,'S,M,L,XL','#8fc7ae'),('3 Piece Unstitched Lawn','Unstitched',6990,NULL,'','#f1dc9b'),
('2 Piece Unstitched Khaddar','Unstitched',5490,4490,'','#e6cc7e'),('Men Cotton Kurta','Menswear',4990,NULL,'S,M,L,XL','#8f9a7a'),
('Men Wash and Wear Shalwar Kameez','Menswear',5990,4990,'M,L,XL','#6f7a5b'),('Cloud99 Eau de Parfum 50ml','Fragrances',3990,NULL,'','#2b2b2b'),
('2 Piece Velvet Suit- Embroidered (Girls)','Girls Suits',11990,NULL,'3-4Y,5-6Y,8-9Y,10-11Y','#8b1e3f'),('2 Piece Cotton Net Suit (Girls)','Girls Suits',6899,4699,'8-9Y,10-11Y,12-13Y','#222222'),
('Ladies Crystal Watch','Watches',5990,NULL,'','#9aa5b1'),('Leather Tote Bag','Bags',4490,3490,'','#b58a6a'),('Pointed Mary Jane Heels','Footwear',3990,NULL,'36,37,38,39,40','#a83246'),
('Pearl Hoop Earrings','Jewellery',1490,NULL,'','#e6c46a'),('Pashmina Shawl','Scarves',3490,NULL,'','#d95a5a'),('Fashion Doll Set','Dolls',1990,1490,'','#f7a8d0')
) v(n,c,p,sp,sz,col) where not exists (select 1 from products);
