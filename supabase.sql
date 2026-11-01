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

-- ===== Part 3: banners + illustrated demo images =====
create table if not exists banners(id uuid primary key default gen_random_uuid(), image text, title text, subtitle text, link text default '#/new', sort int default 0, created_at timestamptz default now());
alter table banners enable row level security;
create policy "read banners" on banners for select using (true);
create policy "admin banners" on banners for all to authenticated using (true) with check (true);
create or replace function seed_shape(k text) returns text language sql immutable as $f$ select case k
when 'suit' then '<path d="M110 70Q150 105 190 70L228 108 208 152 194 138 198 272H102L106 138 92 152 72 108Z"/><path d="M104 272H196L208 388H160L150 318 140 388H92Z"/>'
when 'kurti' then '<path d="M110 60Q150 95 190 60L228 98 208 142 194 128 200 330H100L106 128 92 142 72 98Z"/>'
when 'dress' then '<path d="M118 62Q150 90 182 62L196 140 250 388H50L104 140Z"/>'
when 'shirt' then '<path d="M105 80L135 68 150 92 165 68 195 80 238 130 214 168 198 150 200 300H100L102 150 86 168 62 130Z"/>'
when 'mkurta' then '<path d="M115 66Q150 82 185 66L226 104 206 150 194 134 198 360H102L106 134 94 150 74 104Z"/>'
when 'set' then '<path d="M108 70Q150 100 192 70L222 100 204 138 194 126 198 215H102L106 126 96 138 78 100Z"/><path d="M104 232H196L214 388H158L150 280 142 388H86Z"/>'
when 'bag' then '<path d="M75 170H225L242 350H58Z"/><path d="M112 170Q112 90 150 90 188 90 188 170" fill="none" stroke="#00000066" stroke-width="10"/>'
when 'watch' then '<rect x="128" y="50" width="44" height="90" rx="8"/><rect x="128" y="260" width="44" height="90" rx="8"/><circle cx="150" cy="200" r="62"/>'
when 'shoe' then '<path d="M60 290Q140 290 170 230L182 214 214 330 214 348H60Z"/>'
when 'jewel' then '<circle cx="105" cy="200" r="30"/><circle cx="195" cy="200" r="30"/><rect x="100" y="120" width="10" height="50"/><rect x="190" y="120" width="10" height="50"/>'
when 'scarf' then '<path d="M85 70Q150 40 215 70L235 340Q150 372 65 340Z"/>'
when 'doll' then '<circle cx="150" cy="95" r="42"/><path d="M120 140H180L235 360H65Z"/><rect x="92" y="150" width="14" height="80" rx="6"/><rect x="194" y="150" width="14" height="80" rx="6"/>'
when 'bottle' then '<rect x="100" y="140" width="100" height="190" rx="14"/><rect x="128" y="96" width="44" height="46" rx="6"/>'
else '<rect x="70" y="110" width="160" height="220" rx="6"/><path d="M70 160H230M70 210H230M70 260H230" stroke="#00000033" fill="none"/>' end $f$;
create or replace function art_img(col text, kind text, alt boolean default false) returns text language sql immutable as $f$
 select 'data:image/svg+xml;base64,'||regexp_replace(encode(convert_to('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 400"><defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="'||case when alt then '#dbe8e0' else '#f6eee2' end||'"/><stop offset="1" stop-color="'||case when alt then '#b3cbbf' else '#e0d2bb' end||'"/></linearGradient><pattern id="p" width="14" height="14" patternUnits="userSpaceOnUse"><circle cx="7" cy="7" r="1.8" fill="#fff" fill-opacity=".55"/></pattern><g id="s">'||seed_shape(kind)||'</g></defs><rect width="300" height="400" fill="url(#g)"/><use href="#s" fill="'||col||'" stroke="#00000030" stroke-width="2"/><use href="#s" fill="url(#p)"/><text x="150" y="392" font-size="11" text-anchor="middle" fill="#7a6f5c" font-family="Georgia" letter-spacing="3">CHISHTI FABRICS</text></svg>','UTF8'),'base64'),'\s','','g') $f$;
create or replace function art_banner(c1 text, c2 text, k1 text, g1 text, k2 text, g2 text) returns text language sql immutable as $f$
 select 'data:image/svg+xml;base64,'||regexp_replace(encode(convert_to('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1600 600" preserveAspectRatio="xMidYMid slice"><defs><linearGradient id="g" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="'||c1||'"/><stop offset="1" stop-color="'||c2||'"/></linearGradient><pattern id="p" width="14" height="14" patternUnits="userSpaceOnUse"><circle cx="7" cy="7" r="1.8" fill="#fff" fill-opacity=".5"/></pattern><g id="a">'||seed_shape(k1)||'</g><g id="b">'||seed_shape(k2)||'</g></defs><rect width="1600" height="600" fill="url(#g)"/><g fill="#ffffff" fill-opacity=".14"><circle cx="120" cy="110" r="100"/><circle cx="1400" cy="520" r="150"/><circle cx="760" cy="50" r="70"/><circle cx="980" cy="560" r="90"/><circle cx="1500" cy="90" r="60"/></g><g transform="translate(120 50) scale(1.3)"><use href="#a" fill="'||g1||'" stroke="#00000030" stroke-width="2"/><use href="#a" fill="url(#p)"/></g><g transform="translate(520 100) scale(1.2)"><use href="#b" fill="'||g2||'" stroke="#00000030" stroke-width="2"/><use href="#b" fill="url(#p)"/></g></svg>','UTF8'),'base64'),'\s','','g') $f$;
with m(cat,kind,fixed) as (values ('Embroidered','suit',null),('Printed','suit',null),('Solids','shirt',null),('Co-ords','set',null),('Formals','dress',null),('Kurtis','kurti',null),('Unstitched','fabric',null),('Menswear','mkurta',null),('Fragrances','bottle','#1c1c1c'),('Girls Suits','suit',null),('Watches','watch','#8d98a5'),('Bags','bag','#a9764f'),('Footwear','shoe','#9c2a40'),('Jewellery','jewel','#d4af37'),('Scarves','scarf','#c94c4c'),('Dolls','doll','#f08fc0')),
pal as (select array['#e8b4b8','#9fc5b8','#c7b3e0','#f2c78f','#8fb3d9','#d98f8f','#b5c98f','#3d5a80'] a)
update products p set images=array[art_img(coalesce(m.fixed,pal.a[1+abs(hashtext(p.name))%8]),m.kind),art_img(coalesce(m.fixed,pal.a[1+abs(hashtext(p.name))%8]),m.kind,true)] from m,pal where m.cat=p.category and p.description like 'DEMO PRODUCT%';
with m(cat,kind,fixed) as (values ('Embroidered','suit',null),('Printed','suit',null),('Solids','shirt',null),('Co-ords','set',null),('Formals','dress',null),('Kurtis','kurti',null),('Unstitched','fabric',null),('Menswear','mkurta',null),('Fragrances','bottle','#1c1c1c'),('Girls Suits','suit',null),('Watches','watch','#8d98a5'),('Bags','bag','#a9764f'),('Footwear','shoe','#9c2a40'),('Jewellery','jewel','#d4af37'),('Scarves','scarf','#c94c4c'),('Dolls','doll','#f08fc0')),
pal as (select array['#e8b4b8','#9fc5b8','#c7b3e0','#f2c78f','#8fb3d9','#d98f8f','#b5c98f','#3d5a80'] a)
update categories c set image=art_img(coalesce(m.fixed,pal.a[1+abs(hashtext(c.name))%8]),m.kind) from m,pal where m.cat=c.name;
insert into banners(image,title,subtitle,link,sort) select * from (values
(art_banner('#1d4a3c','#3a8a70','suit','#f4d9dc','dress','#e8c27a'),'Ready to wear','Embroidered and printed lawn collection','#/g/Women',1),
(art_banner('#5a1f3a','#b0587a','dress','#f2d7a0','kurti','#f0c4d4'),'Festive Formals','Silk, chiffon and velvet','#/c/Formals',2),
(art_banner('#1f2a44','#587099','mkurta','#d8dfe8','bottle','#c9a24d'),'Mens Collection','Kurtas and fragrances','#/g/Men',3),
(art_banner('#8a2a22','#e07a4a','shirt','#fbe3c8','bag','#f2c78f'),'Sale up to 40% off','Limited time offers','#/sale',4)
) v(a,b,c,d,e) where not exists (select 1 from banners);
