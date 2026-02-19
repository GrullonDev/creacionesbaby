-- Force update the banner bucket to handle cases where it was created manually or incorrectly
-- 1. Ensure bucket exists and is public
insert into storage.buckets (id, name, public)
values ('banners', 'banners', true)
on conflict (id) do update set public = true;

-- 2. Ensure RLS is enabled generally (should be already)
-- storage.objects usually has RLS enabled by default.

-- 3. Drop existing policies to avoid conflicts or outdated rules
drop policy if exists "Public Access Banners" on storage.objects;
drop policy if exists "Admin Upload Banners" on storage.objects;
drop policy if exists "Admin Update Banners" on storage.objects;
drop policy if exists "Admin Delete Banners" on storage.objects;
drop policy if exists "Give me access to banners" on storage.objects; -- clean up any random policies

-- 4. Re-create policies ensuring correctness
-- Allow PUBLIC read access to banners
create policy "Public Access Banners"
  on storage.objects for select
  using ( bucket_id = 'banners' );

-- Allow AUTHENTICATED users (admins) to upload/update/delete
-- Note: verification of 'admin' role depends on your auth setup. 
-- Here we assume any authenticated user is an admin for simplicity, or check for specific email/metadata if needed.
create policy "Admin Upload Banners"
  on storage.objects for insert
  with check ( bucket_id = 'banners' and auth.role() = 'authenticated' );

create policy "Admin Update Banners"
  on storage.objects for update
  with check ( bucket_id = 'banners' and auth.role() = 'authenticated' );

create policy "Admin Delete Banners"
  on storage.objects for delete
  using ( bucket_id = 'banners' and auth.role() = 'authenticated' );
