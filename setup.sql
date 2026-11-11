-- =====================================================================
--  Website Dua Garis Imagi (DGI): database untuk panel admin
--  Cara pakai: Supabase > SQL Editor > New query > tempel semua isi file ini > Run
--  Aman dijalankan ulang: tidak menghapus isi yang sudah ada.
-- =====================================================================

-- 1. Tabel isi website
create table if not exists public.content (
  key        text primary key,
  value      text not null default '',
  updated_at timestamptz not null default now()
);

create table if not exists public.services (
  id          uuid primary key default gen_random_uuid(),
  title       text not null default '',
  description text not null default '',
  sort_order  int  not null default 0,
  updated_at  timestamptz not null default now()
);

create table if not exists public.projects (
  id          uuid primary key default gen_random_uuid(),
  title       text not null default '',
  tag         text not null default '',
  description text not null default '',
  image_url   text not null default '',
  sort_order  int  not null default 0,
  updated_at  timestamptz not null default now()
);

create table if not exists public.clients (
  id         uuid primary key default gen_random_uuid(),
  name       text not null default '',
  logo_url   text not null default '',
  sort_order int  not null default 0,
  updated_at timestamptz not null default now()
);

-- 2. Hak akses: semua orang boleh membaca, hanya akun tim (login) yang boleh mengubah
alter table public.content  enable row level security;
alter table public.services enable row level security;
alter table public.projects enable row level security;
alter table public.clients  enable row level security;

drop policy if exists "baca publik" on public.content;
drop policy if exists "tim mengubah" on public.content;
create policy "baca publik"  on public.content for select using (true);
create policy "tim mengubah" on public.content for all to authenticated using (true) with check (true);

drop policy if exists "baca publik" on public.services;
drop policy if exists "tim mengubah" on public.services;
create policy "baca publik"  on public.services for select using (true);
create policy "tim mengubah" on public.services for all to authenticated using (true) with check (true);

drop policy if exists "baca publik" on public.projects;
drop policy if exists "tim mengubah" on public.projects;
create policy "baca publik"  on public.projects for select using (true);
create policy "tim mengubah" on public.projects for all to authenticated using (true) with check (true);

drop policy if exists "baca publik" on public.clients;
drop policy if exists "tim mengubah" on public.clients;
create policy "baca publik"  on public.clients for select using (true);
create policy "tim mengubah" on public.clients for all to authenticated using (true) with check (true);

-- 3. Tempat simpan foto proyek dan logo klien
insert into storage.buckets (id, name, public)
values ('media', 'media', true)
on conflict (id) do update set public = true;

drop policy if exists "media baca publik" on storage.objects;
drop policy if exists "media tim unggah" on storage.objects;
drop policy if exists "media tim ubah" on storage.objects;
drop policy if exists "media tim hapus" on storage.objects;
create policy "media baca publik" on storage.objects for select using (bucket_id = 'media');
create policy "media tim unggah"  on storage.objects for insert to authenticated with check (bucket_id = 'media');
create policy "media tim ubah"    on storage.objects for update to authenticated using (bucket_id = 'media');
create policy "media tim hapus"   on storage.objects for delete to authenticated using (bucket_id = 'media');

-- 4. Catat waktu perubahan terakhir
create or replace function public.set_updated_at() returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end $$;

drop trigger if exists t_content_updated on public.content;
create trigger t_content_updated before update on public.content for each row execute function public.set_updated_at();
drop trigger if exists t_services_updated on public.services;
create trigger t_services_updated before update on public.services for each row execute function public.set_updated_at();
drop trigger if exists t_projects_updated on public.projects;
create trigger t_projects_updated before update on public.projects for each row execute function public.set_updated_at();
drop trigger if exists t_clients_updated on public.clients;
create trigger t_clients_updated before update on public.clients for each row execute function public.set_updated_at();

-- 5. Isi awal (sama dengan isi website sekarang)
insert into public.content (key, value) values
  ('hero_line1', 'Dua garis bertemu,'),
  ('hero_line2', 'jadi satu imagi.'),
  ('hero_lead', 'Dua Garis Imagi (DGI) adalah biro advertising dari Yogyakarta. Dari identitas brand, billboard, event, sampai ruang usaha, kami merapikan semuanya supaya apa yang dikatakan sebuah bisnis sama dengan apa yang dirasakan orang.'),
  ('clients_label', 'Dipercaya oleh'),
  ('clients_more', 'and many more'),
  ('services_title', 'Empat hal yang kami kerjakan'),
  ('services_lead', 'Brand yang kuat bukan hanya logo. Ia terlihat di jalan, terasa di ruang, dan hidup di acara tempat orang bertemu langsung.'),
  ('projects_title', 'Proyek pilihan'),
  ('projects_lead', 'Beberapa kerja yang sudah kami hadirkan untuk brand dan bisnis dari berbagai bidang.'),
  ('approach_title', 'Kenapa namanya dua garis'),
  ('approach_lead', 'Setiap brand punya dua garis. Selama keduanya sejajar tanpa pernah bertemu, orang merasa ada yang janggal.'),
  ('line1_title', 'Garis pertama: yang dikatakan'),
  ('line1_text', 'Janji, nilai, dan cerita yang ingin disampaikan bisnis lewat iklan, kemasan, dan media sosial.'),
  ('line2_title', 'Garis kedua: yang dirasakan'),
  ('line2_text', 'Pengalaman nyata pelanggan: suasana ruang, momen di acara, dan layanan sehari-hari.'),
  ('join_text', 'Kerja kami adalah'),
  ('join_highlight', 'mempertemukan keduanya.'),
  ('process_title', 'Cara kami bekerja'),
  ('process_lead', 'Empat tahap, dari ngobrol pertama sampai hasilnya dipakai sehari-hari.'),
  ('step1_title', 'Dengar'),
  ('step1_text', 'Kami mulai dari bisnis Anda: tujuan, pelanggan, dan masalah yang sedang dihadapi.'),
  ('step2_title', 'Petakan'),
  ('step2_text', 'Kami cek di mana kedua garis belum bertemu, lalu menentukan arah brand.'),
  ('step3_title', 'Rancang'),
  ('step3_text', 'Identitas, materi OOH, konsep event, atau desain ruang disusun sesuai arah itu.'),
  ('step4_title', 'Hadirkan'),
  ('step4_text', 'Kami dampingi sampai terpasang, berjalan, dan terlihat hasilnya.'),
  ('cta_title', 'Punya brand yang ingin dirapikan?'),
  ('cta_intro', 'Ceritakan kebutuhan Anda. Isi formulirnya, pesan langsung tersusun di WhatsApp kami.'),
  ('wa_number', '0817-4802-222'),
  ('location', 'Yogyakarta, Indonesia'),
  ('instagram_url', '')
on conflict (key) do nothing;

insert into public.services (title, description, sort_order)
select * from (values
  ('Branding & placement', 'Strategi brand, identitas visual, dan penempatannya di titik yang dilihat pelanggan, supaya brand dikenali di mana pun muncul.', 0),
  ('Media luar ruang (OOH)', 'Billboard, baliho, dan media jalanan yang dirancang supaya pesannya terbaca dalam hitungan detik.', 1),
  ('Aktivasi & event (EO)', 'Aktivasi brand dan event dari konsep sampai hari pelaksanaan, tempat brand bertemu orangnya secara langsung.', 2),
  ('Desain interior', 'Ruang usaha, kantor, dan tempat makan yang dirancang mengikuti karakter brand, bukan sekadar mengikuti tren.', 3)
) v where not exists (select 1 from public.services);

insert into public.projects (title, tag, description, image_url, sort_order)
select * from (values
  ('Media luar ruang', 'OOH', 'Billboard, baliho, dan media jalanan yang terbaca dalam hitungan detik.', 'proyek-ooh.jpg', 0),
  ('Desain interior', 'Interior', 'Ruang usaha dan kantor yang terasa sesuai karakter brand-nya.', 'proyek-interior.jpg', 1),
  ('Aktivasi & event', 'Activation / EO', 'Event dan aktivasi yang mempertemukan brand langsung dengan orangnya.', 'proyek-event.jpg', 2),
  ('Branding & placement', 'Branding / Placement', 'Identitas brand dan penempatannya di titik yang dilihat pelanggan.', 'proyek-branding.jpg', 3)
) v where not exists (select 1 from public.projects);

insert into public.clients (name, logo_url, sort_order)
select * from (values
  ('Djarum', 'klien-djarum.png', 0),
  ('KT&G', 'klien-ktg.png', 1),
  ('Nojorono', 'klien-nojorono.png', 2),
  ('Paragon Corp', 'klien-paragon.png', 3),
  ('Gajah Baru', 'klien-gajahbaru.png', 4),
  ('Wismilak', 'klien-wismilak.png', 5)
) v where not exists (select 1 from public.clients);
