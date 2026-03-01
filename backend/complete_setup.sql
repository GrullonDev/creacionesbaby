-- COMPREHENSIVE SETUP SCRIPT FOR CREACIONESBABY --

-- 1. App Config Table --
CREATE TABLE IF NOT EXISTS public.app_config (
  key TEXT PRIMARY KEY,
  value TEXT
);

ALTER TABLE public.app_config ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public config is viewable by everyone." ON public.app_config;
CREATE POLICY "Public config is viewable by everyone."
  ON public.app_config FOR SELECT
  USING ( true );

DROP POLICY IF EXISTS "Admins can update config." ON public.app_config;
CREATE POLICY "Admins can update config."
  ON public.app_config FOR ALL
  USING ( auth.role() = 'authenticated' );

-- Insert Environment and Default Banner
INSERT INTO public.app_config (key, value)
VALUES 
  ('environment', 'dev'),
  ('home_banner_text', 'Nueva Colección 2026')
ON CONFLICT (key) DO NOTHING;


-- 2. Coupons Table --
CREATE TABLE IF NOT EXISTS public.coupons (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  code TEXT UNIQUE NOT NULL,
  discount_percentage NUMERIC NOT NULL, -- e.g. 10.0 for 10%
  is_active BOOLEAN DEFAULT true,
  expiration_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.coupons ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Public can view coupons for validation" ON public.coupons;
CREATE POLICY "Public can view coupons for validation"
  ON public.coupons FOR SELECT
  USING ( true );

DROP POLICY IF EXISTS "Admins can manage coupons" ON public.coupons;
CREATE POLICY "Admins can manage coupons"
  ON public.coupons FOR ALL
  USING ( auth.role() = 'authenticated' );

-- Insert Sample Coupon
INSERT INTO public.coupons (code, discount_percentage)
VALUES ('BIENVENIDO10', 10.0)
ON CONFLICT (code) DO NOTHING;


-- 3. Contact Messages Table --
CREATE TABLE IF NOT EXISTS public.contact_messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  subject TEXT,
  message TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.contact_messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can send contact messages" ON public.contact_messages;
CREATE POLICY "Anyone can send contact messages"
  ON public.contact_messages FOR INSERT
  WITH CHECK ( true );

DROP POLICY IF EXISTS "Admins can view messages" ON public.contact_messages;
CREATE POLICY "Admins can view messages"
  ON public.contact_messages FOR SELECT
  USING ( auth.role() = 'authenticated' );


-- 4. Newsletter Subscribers Table --
CREATE TABLE IF NOT EXISTS public.newsletter_subscribers (
  email TEXT PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

ALTER TABLE public.newsletter_subscribers ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can subscribe to newsletter" ON public.newsletter_subscribers;
CREATE POLICY "Anyone can subscribe to newsletter"
  ON public.newsletter_subscribers FOR INSERT
  WITH CHECK ( true );

DROP POLICY IF EXISTS "Admins can view subscribers" ON public.newsletter_subscribers;
CREATE POLICY "Admins can view subscribers"
  ON public.newsletter_subscribers FOR SELECT
  USING ( auth.role() = 'authenticated' );
