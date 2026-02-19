-- 1. Create the policy for PUBLIC VIEW access (Everyone can see images)
create policy "Public Access"
  on storage.objects for select
  using ( bucket_id = 'products_image' );


-- 2. Create the policy for AUTHENTICATED UPLOAD access (Admins can upload)
create policy "Admin Upload"
  on storage.objects for insert
  with check ( bucket_id = 'products_image' and auth.role() = 'authenticated' );


-- 3. Create the policy for AUTHENTICATED UPDATE (Admins can update)
create policy "Admin Update"
  on storage.objects for update
  using ( bucket_id = 'products_image' and auth.role() = 'authenticated' );


-- 4. Create the policy for AUTHENTICATED DELETE (Admins can delete)
create policy "Admin Delete"
  on storage.objects for delete
  using ( bucket_id = 'products_image' and auth.role() = 'authenticated' );
