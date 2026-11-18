-- NEX7 STEP: banco de dados do catálogo. Rode TUDO no Supabase: SQL Editor > New query > Run.

create table if not exists categories (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  name text not null,
  position int not null default 0,
  created_at timestamptz default now()
);

create table if not exists products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text not null default '',
  category_id uuid not null references categories(id) on delete restrict,
  image_url text not null,
  image_path text,               -- caminho no Storage (nulo para imagens antigas de assets/)
  position int not null default 0,
  created_at timestamptz default now()
);

-- Quem é admin (preencher com os 2 usuários, veja o passo a passo)
create table if not exists admins (user_id uuid primary key references auth.users(id) on delete cascade);

create or replace function is_admin() returns boolean
language sql security definer set search_path = public stable
as $$ select exists (select 1 from admins where user_id = auth.uid()) $$;

alter table categories enable row level security;
alter table products   enable row level security;
alter table admins     enable row level security;

create policy "ler categorias" on categories for select using (true);
create policy "ler produtos"   on products   for select using (true);
create policy "admin escreve categorias" on categories for all using (is_admin()) with check (is_admin());
create policy "admin escreve produtos"   on products   for all using (is_admin()) with check (is_admin());
create policy "admin se ve" on admins for select using (user_id = auth.uid());

-- Bucket público de imagens; só admin envia/apaga
insert into storage.buckets (id, name, public) values ('produtos', 'produtos', true) on conflict do nothing;
create policy "imagens publicas" on storage.objects for select using (bucket_id = 'produtos');
create policy "admin envia imagens"  on storage.objects for insert with check (bucket_id = 'produtos' and is_admin());
create policy "admin altera imagens" on storage.objects for update using (bucket_id = 'produtos' and is_admin());
create policy "admin apaga imagens"  on storage.objects for delete using (bucket_id = 'produtos' and is_admin());

-- Dados atuais do site
insert into categories (slug, name, position) values
  ('plaquinhas', 'Plaquinhas NFC e QR Code', 1),
  ('chaveiros',  'Chaveiros', 2)
on conflict (slug) do nothing;

insert into products (name, description, category_id, image_url, position)
select v.n, v.d, c.id, 'assets/' || v.f || '.webp', v.p
from (values
 ('plaquinhas','plaquinha-google','Plaquinha Google','Leva o cliente direto para avaliar sua empresa no Google.',1),
 ('plaquinhas','plaquinha-pix','Plaquinha Pix','Receba pagamentos sem precisar ditar a chave.',2),
 ('plaquinhas','plaquinha-instagram','Plaquinha Instagram','Mais seguidores com um toque ou uma leitura do QR Code.',3),
 ('plaquinhas','plaquinha-whatsapp','Plaquinha WhatsApp','Abre a conversa com o seu cliente na hora.',4),
 ('plaquinhas','plaquinha-wifi','Plaquinha Wi-Fi (PETG)','O cliente conecta na rede sem digitar a senha.',5),
 ('plaquinhas','plaquinha-cardapio','Plaquinha de cardápio','Cardápio digital no celular do cliente.',6),
 ('plaquinhas','plaquinha-tripla','Placa 3 em 1 (a sua escolha)','Você escolhe as 3 funções: Google, Instagram, Pix, WhatsApp, Wi-Fi ou cardápio em uma única peça.',7),
 ('chaveiros','chaveiro-java','Chaveiro Java','Chaveiro de programador em impressão 3D.',8),
 ('chaveiros','chaveiro-codigo','Chaveiro código','Chaveiro de programador em impressão 3D.',9),
 ('chaveiros','chaveiro-github','Chaveiro GitHub','Chaveiro de programador em impressão 3D.',10),
 ('chaveiros','chaveiro-python','Chaveiro Python','Chaveiro de programador em impressão 3D.',11),
 ('chaveiros','chaveiro-javascript','Chaveiro JavaScript','Chaveiro de programador em impressão 3D.',12),
 ('chaveiros','chaveiro-csharp','Chaveiro C#','Chaveiro de programador em impressão 3D.',13),
 ('chaveiros','chaveiro-vscode','Chaveiro vscode','Chaveiro de programador em impressão 3D.',14)
) as v(c, f, n, d, p) join categories c on c.slug = v.c
where not exists (select 1 from products);

-- DEPOIS de criar os 2 usuários em Authentication > Users, rode (troque os e-mails):
-- insert into admins (user_id) select id from auth.users where email in ('admin1@exemplo.com','admin2@exemplo.com');
