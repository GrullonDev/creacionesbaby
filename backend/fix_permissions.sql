-- RUN THIS SCRIPT IN SUPABASE SQL EDITOR TO FIX PERMISSIONS --

-- 1. Create the policy for PUBLIC VIEW access (Everyone can see images)
-- First, try dropping it to avoid 'policy already exists' errors
drop policy if exists "Public Access" on storage.objects;

create policy "Public Access"
  on storage.objects for select
  using ( bucket_id = 'products_image' );


-- 2. Create the policy for AUTHENTICATED UPLOAD access (Admins can upload)
drop policy if exists "Admin Upload" on storage.objects;

create policy "Admin Upload"
  on storage.objects for insert
  with check ( bucket_id = 'products_image' and auth.role() = 'authenticated' );


-- 3. Create the policy for AUTHENTICATED UPDATE (Admins can update)
drop policy if exists "Admin Update" on storage.objects;

create policy "Admin Update"
  on storage.objects for update
  using ( bucket_id = 'products_image' and auth.role() = 'authenticated' );


-- 4. Create the policy for AUTHENTICATED DELETE (Admins can delete)
drop policy if exists "Admin Delete" on storage.objects;

create policy "Admin Delete"
  on storage.objects for delete
  using ( bucket_id = 'products_image' and auth.role() = 'authenticated' );
