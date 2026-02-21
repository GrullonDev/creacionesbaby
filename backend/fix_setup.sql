-- ==============================================================================
-- FIX SETUP SCRIPT
-- Run this ENTIRE script in your Supabase SQL Editor to fix missing table errors.
-- ==============================================================================

-- 1. Create table 'app_config' if it doesn't exist
CREATE TABLE IF NOT EXISTS public.app_config (
  key text PRIMARY KEY,
  value text
);

-- 2. Enable Security
ALTER TABLE public.app_config ENABLE ROW LEVEL SECURITY;

-- 3. Create/Reset Policies for 'app_config' (Idempotent)
DROP POLICY IF EXISTS "Public config is viewable by everyone." ON public.app_config;
CREATE POLICY "Public config is viewable by everyone." ON public.app_config FOR SELECT USING (true);

DROP POLICY IF EXISTS "Admins can update config." ON public.app_config;
CREATE POLICY "Admins can update config." ON public.app_config FOR UPDATE USING (auth.role() = 'authenticated') WITH CHECK (auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Admins can insert config." ON public.app_config;
CREATE POLICY "Admins can insert config." ON public.app_config FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- 4. Initial Config Values (Only if they don't exist)
INSERT INTO public.app_config (key, value) VALUES ('home_banner_text', 'Nueva Colección 2026') ON CONFLICT (key) DO NOTHING;
INSERT INTO public.app_config (key, value) VALUES ('home_banner_image_url', NULL) ON CONFLICT (key) DO NOTHING;

-- 5. Create Storage Bucket for Banners
INSERT INTO storage.buckets (id, name, public) VALUES ('banners', 'banners', true) ON CONFLICT (id) DO NOTHING;

-- 6. Create/Reset Storage Policies (Idempotent)
DROP POLICY IF EXISTS "Public Access Banners" ON storage.objects;
CREATE POLICY "Public Access Banners" ON storage.objects FOR SELECT USING (bucket_id = 'banners');

DROP POLICY IF EXISTS "Admin Upload Banners" ON storage.objects;
CREATE POLICY "Admin Upload Banners" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'banners' AND auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Admin Update Banners" ON storage.objects;
CREATE POLICY "Admin Update Banners" ON storage.objects FOR UPDATE WITH CHECK (bucket_id = 'banners' AND auth.role() = 'authenticated');

DROP POLICY IF EXISTS "Admin Delete Banners" ON storage.objects;
CREATE POLICY "Admin Delete Banners" ON storage.objects FOR DELETE USING (bucket_id = 'banners' AND auth.role() = 'authenticated');
