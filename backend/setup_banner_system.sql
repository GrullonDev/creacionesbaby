-- Create app_config table if not exists (for texts and simple settings)
create table if not exists public.app_config (
  key text primary key,
  value text
);
alter table public.app_config enable row level security;

-- Policies for app_config
create policy "Public config is viewable by everyone."
  on public.app_config for select
  using ( true );

create policy "Admins can update config."
  on public.app_config for update
  using ( auth.role() = 'authenticated' )
  with check ( auth.role() = 'authenticated' );

create policy "Admins can insert config."
  on public.app_config for insert
  with check ( auth.role() = 'authenticated' );

-- Create banners table (for multiple banners or advanced config) 
-- Or stick to app_config for simplicity for now?
-- Let's stick to app_config for 'home_banner_image_url' key to keep it simple as requested.

-- Create storage bucket for banner images
insert into storage.buckets (id, name, public)
values ('banners', 'banners', true)
on conflict (id) do nothing;

-- Storage Policies for banners bucket
create policy "Public Access Banners"
  on storage.objects for select
  using ( bucket_id = 'banners' );

create policy "Admin Upload Banners"
  on storage.objects for insert
  with check ( bucket_id = 'banners' and auth.role() = 'authenticated' );

create policy "Admin Update Banners"
  on storage.objects for update
  with check ( bucket_id = 'banners' and auth.role() = 'authenticated' );

create policy "Admin Delete Banners"
  on storage.objects for delete
  using ( bucket_id = 'banners' and auth.role() = 'authenticated' );
