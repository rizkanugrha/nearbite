# ERD dan API NearBite

Dokumen ini menjadi rujukan skema backend dan endpoint yang dipakai README utama.

## ERD Konseptual

```mermaid
erDiagram
    AUTH_USERS ||--|| USERS : memiliki
    USERS ||--o{ RESTAURANTS : memiliki
    RESTAURANTS ||--o{ MENU_ITEMS : memiliki

    AUTH_USERS {
        uuid id PK
        text email
    }
    USERS {
        uuid id PK
        text email
        text full_name
        timestamptz created_at
    }
    RESTAURANTS {
        uuid id PK
        uuid owner_id FK
        text name
        text description
        text address
        decimal latitude
        decimal longitude
        text photo_url
        text open_hours
        timestamptz created_at
        timestamptz updated_at
    }
    MENU_ITEMS {
        uuid id PK
        uuid restaurant_id FK
        text name
        text description
        integer price
        text photo_url
        boolean is_available
        timestamptz created_at
        timestamptz updated_at
    }
```

## Skema SQL Minimum

> Sesuaikan tipe/constraint dengan migration Supabase yang dipakai pada project. `seed_data.sql` hanya berisi data awal, bukan migration lengkap.

```sql
create table public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  email text unique not null,
  full_name text not null,
  created_at timestamptz not null default now()
);

create table public.restaurants (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.users(id) on delete cascade,
  name text not null,
  description text not null default '',
  address text not null default '',
  latitude double precision not null,
  longitude double precision not null,
  photo_url text,
  open_hours text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.menu_items (
  id uuid primary key default gen_random_uuid(),
  restaurant_id uuid not null references public.restaurants(id) on delete cascade,
  name text not null,
  description text not null default '',
  price integer not null check (price >= 0),
  photo_url text,
  is_available boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

## RLS Minimum

Aktifkan RLS dan sesuaikan policy dengan kebutuhan deployment. Inti policy owner adalah `owner_id = auth.uid()` atau restaurant yang dimiliki oleh user aktif.

```sql
alter table public.users enable row level security;
alter table public.restaurants enable row level security;
alter table public.menu_items enable row level security;

create policy "public can read restaurants"
on public.restaurants for select using (true);

create policy "owner can manage restaurant"
on public.restaurants for all
using (owner_id = auth.uid())
with check (owner_id = auth.uid());

create policy "public can read menu items"
on public.menu_items for select using (true);

create policy "owner can manage menu items"
on public.menu_items for all
using (
  exists (
    select 1 from public.restaurants r
    where r.id = menu_items.restaurant_id
      and r.owner_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.restaurants r
    where r.id = menu_items.restaurant_id
      and r.owner_id = auth.uid()
  )
);
```

## API Contract

Base URL:

```text
https://<project-ref>.supabase.co
```

Headers umum REST:

```http
Content-Type: application/json
apikey: <SUPABASE_ANON_KEY>
Authorization: Bearer <access_token>  # operasi owner
```

### Auth

| Method | Endpoint | Kegunaan |
|---|---|---|
| POST | `/auth/v1/signup` | Register email/password dan metadata nama |
| POST | `/auth/v1/token?grant_type=password` | Login dan memperoleh access token |
| GET | `/auth/v1/user` | Validasi token/session tersimpan |

### Restaurants

| Method | Endpoint | Kegunaan |
|---|---|---|
| GET | `/rest/v1/restaurants?select=*` | Daftar restoran publik |
| GET | `/rest/v1/restaurants?select=*&id=eq.<id>` | Detail restoran |
| GET | `/rest/v1/restaurants?select=*&owner_id=eq.<user_id>` | Restoran milik owner |
| POST | `/rest/v1/restaurants` | Membuat profil restoran |
| PATCH | `/rest/v1/restaurants?id=eq.<id>` | Memperbarui profil restoran |

### Menu

| Method | Endpoint | Kegunaan |
|---|---|---|
| GET | `/rest/v1/menu_items?select=*` | Data menu untuk pencarian publik |
| GET | `/rest/v1/menu_items?select=*&restaurant_id=eq.<id>` | Menu restoran tertentu |
| POST | `/rest/v1/menu_items` | Menambah menu owner |
| PATCH | `/rest/v1/menu_items?id=eq.<id>` | Mengubah menu owner |
| DELETE | `/rest/v1/menu_items?id=eq.<id>&restaurant_id=eq.<restaurant_id>` | Menghapus menu owner |

## Pemetaan Kode

- Auth: [auth_api_client.dart](lib/features/auth/data/remote/auth_api_client.dart)
- Restaurant/menu API: [restaurant_api_client.dart](lib/features/restaurants/data/remote/restaurant_api_client.dart)
- Model: `lib/features/auth/domain/user.dart`, `lib/features/restaurants/domain/restaurant.dart`, dan `lib/features/restaurants/domain/menu_item.dart`
- Seed data: [seed_data.sql](seed_data.sql)
