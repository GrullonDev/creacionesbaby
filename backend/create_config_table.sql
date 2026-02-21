create table if not exists public.app_config (
  key text primary key,
  value text
);

-- Enable RLS
alter table public.app_config enable row level security;

-- Policy: Everyone can read config (needed for Store site)
create policy "Public config is viewable by everyone."
  on public.app_config for select
  using ( true );

-- Policy: Only Authenticated users (Admins) can update config
create policy "Admins can update config."
  on public.app_config for update
  using ( auth.role() = 'authenticated' )
  with check ( auth.role() = 'authenticated' );

-- Policy: Admins can insert config
create policy "Admins can insert config."
  on public.app_config for insert
  with check ( auth.role() = 'authenticated' );

-- Insert default banner text
insert into public.app_config (key, value)
values ('home_banner_text', 'Nueva Colección 2026')
on conflict (key) do nothing;
