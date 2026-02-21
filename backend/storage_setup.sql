-- 1. Create the storage bucket named 'products_image'
-- Note: If this fails, go to Storage > New Bucket > Name: products_image > Public: Yes
insert into storage.buckets (id, name, public)
values ('products_image', 'products_image', true);

-- 2. Enable RLS on objects (usually enabled by default, but good to ensure)
alter table storage.objects enable row level security;

-- 3. Policy: Allow anyone (public) to VIEW images in the 'products' bucket
create policy "Public Access"
  on storage.objects for select
  using ( bucket_id = 'products_image' );

-- 4. Policy: Allow authenticated users (Admins) to UPLOAD to 'products' bucket
create policy "Admin Upload"
  on storage.objects for insert
  with check ( bucket_id = 'products' and auth.role() = 'authenticated' );

-- 5. Policy: Allow authenticated users to UPDATE (if needed)
create policy "Admin Update"
  on storage.objects for update
  using ( bucket_id = 'products' and auth.role() = 'authenticated' );

-- 6. Policy: Allow authenticated users to DELETE
create policy "Admin Delete"
  on storage.objects for delete
  using ( bucket_id = 'products' and auth.role() = 'authenticated' );
