-- Crear tabla de pedidos (orders)
CREATE TABLE IF NOT EXISTS public.orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  customer_email TEXT NOT NULL,
  customer_name TEXT NOT NULL,
  customer_phone TEXT NOT NULL,
  shipping_address TEXT NOT NULL,
  total_amount NUMERIC NOT NULL,
  status TEXT NOT NULL DEFAULT 'pendient', -- pendient, procesando, enviado, entregado, cancelado
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Crear políticas para orders
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Cualquiera puede insertar orders (pedidos)"
  ON public.orders FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Lectura pública de orders"
  ON public.orders FOR SELECT
  USING (true);

CREATE POLICY "Actualizaciones públicas de orders"
  ON public.orders FOR UPDATE
  USING (true);


-- Crear tabla de items de pedido (order_items)
CREATE TABLE IF NOT EXISTS public.order_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  product_id BIGINT NOT NULL, -- no ponemos FK estricta a products por si el producto se borra
  product_name TEXT NOT NULL,
  size TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  unit_price NUMERIC NOT NULL,
  total_price NUMERIC NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Crear políticas para order_items
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Cualquiera puede insertar order_items"
  ON public.order_items FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Lectura pública de order_items"
  ON public.order_items FOR SELECT
  USING (true);

CREATE POLICY "Actualizaciones públicas de order_items"
  ON public.order_items FOR UPDATE
  USING (true);
