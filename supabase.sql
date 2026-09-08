-- Aatusku Maailma: Supabase schema
-- No application-level admin role is created. All registered users are ordinary users.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null check (char_length(name) between 2 and 60),
  created_at timestamptz not null default now()
);

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  seller_id uuid not null references public.profiles(id) on delete cascade,
  name text not null check (char_length(name) between 2 and 100),
  game text not null check (char_length(game) between 1 and 80),
  description text not null check (char_length(description) between 1 and 2000),
  price numeric(10,2) not null check (price > 0 and price <= 100000),
  paypal_me text,
  status text not null default 'active' check (status in ('active','sold','hidden')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;
alter table public.products enable row level security;

revoke all on public.profiles from anon, authenticated;
revoke all on public.products from anon, authenticated;
grant select on public.profiles to anon, authenticated;
grant select, insert, update, delete on public.products to authenticated;
grant insert, update on public.profiles to authenticated;

create policy "profiles are public" on public.profiles for select to anon, authenticated using (true);
create policy "users create own profile" on public.profiles for insert to authenticated with check (auth.uid() = id);
create policy "users update own profile" on public.profiles for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);

create policy "active products are public" on public.products for select to anon, authenticated using (status = 'active' or seller_id = auth.uid());
create policy "users create own products" on public.products for insert to authenticated with check (seller_id = auth.uid());
create policy "users update own products" on public.products for update to authenticated using (seller_id = auth.uid()) with check (seller_id = auth.uid());
create policy "users delete own products" on public.products for delete to authenticated using (seller_id = auth.uid());

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end; $$;

drop trigger if exists products_updated_at on public.products;
create trigger products_updated_at before update on public.products
for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, name)
  values (new.id, coalesce(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1)));
  return new;
end; $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute function public.handle_new_user();


-- Payment/order records used by the server-side PayPal flow.
create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  buyer_id uuid not null references auth.users(id) on delete cascade,
  product_id uuid not null references public.products(id) on delete restrict,
  paypal_order_id text unique,
  amount numeric(10,2) not null check (amount > 0),
  currency text not null default 'EUR',
  status text not null default 'created'
    check (status in ('created','approved','captured','failed','cancelled')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.orders enable row level security;
revoke all on public.orders from anon, authenticated;
grant select, insert, update on public.orders to authenticated;

create policy "buyers can view own orders" on public.orders
for select to authenticated using (buyer_id = auth.uid());

create policy "buyers can create own orders" on public.orders
for insert to authenticated with check (buyer_id = auth.uid());

create policy "buyers can update own orders" on public.orders
for update to authenticated using (buyer_id = auth.uid()) with check (buyer_id = auth.uid());

drop trigger if exists orders_updated_at on public.orders;
create trigger orders_updated_at before update on public.orders
for each row execute function public.set_updated_at();

-- Keep the Data API grants explicit alongside RLS.
grant select on public.profiles to anon, authenticated;
grant select, insert, update, delete on public.products to authenticated;
grant select, insert, update on public.orders to authenticated;
