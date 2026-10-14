-- ==========================================================
--  GyG · Base de datos (pegar entera en Supabase > SQL Editor > Run)
-- ==========================================================

create table miembros (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  color text not null default '#1E9BE0',
  forma text not null default 'estrella',
  orden int not null default 0,
  rota boolean not null default true,
  color_ok boolean not null default false,
  created_at timestamptz not null default now()
);

create table compra (
  id uuid primary key default gen_random_uuid(),
  texto text not null,
  cantidad text,
  seccion text,
  emoji text,
  n numeric not null default 1,      -- cuánto
  unidad text,                       -- kg, litros, botes…
  hecho boolean not null default false,
  autor uuid references miembros(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table tareas (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  descripcion text,
  miembro uuid references miembros(id) on delete set null,   -- persona asignada
  turnos jsonb not null default '[]',                        -- o varias personas por turnos
  fecha date not null default current_date,
  hora time,
  repite text check (repite in ('diaria','semanal','quincenal','mensual')),
  flexible boolean not null default false,                   -- se puede hacer cualquier día del periodo
  prioridad text not null default 'media' check (prioridad in ('baja','media','alta')),
  revisa uuid references tareas(id) on delete cascade,      -- aviso de algo mal hecho: qué tarea
  revisa_fecha date,                                         -- y de qué semana
  autor uuid references miembros(id) on delete set null,
  created_at timestamptz not null default now()
);

-- Cada vez que se completa una tarea (o una repetición de ella)
create table tareas_hechas (
  tarea uuid not null references tareas(id) on delete cascade,
  fecha date not null,
  hecha_por uuid references miembros(id) on delete set null,
  hecha_at timestamptz not null default now(),
  primary key (tarea, fecha)
);

create table eventos (
  id uuid primary key default gen_random_uuid(),
  titulo text not null,
  fecha date not null,
  hora time,
  miembro uuid references miembros(id) on delete set null,
  notas text,
  repite text check (repite in ('semanal','mensual','anual')),
  autor uuid references miembros(id) on delete set null,
  created_at timestamptz not null default now()
);

create table avisos (
  id uuid primary key default gen_random_uuid(),
  texto text not null,
  autor uuid references miembros(id) on delete set null,
  fijado boolean not null default false,
  vistos jsonb not null default '[]',
  created_at timestamptz not null default now()
);

create table compras_hechas (
  id uuid primary key default gen_random_uuid(),
  fecha date not null default current_date,
  quien uuid references miembros(id) on delete set null,
  tienda text,
  total numeric(10,2),
  notas text,
  productos jsonb not null default '[]',
  created_at timestamptz not null default now()
);

-- Productos que crea la familia (además del catálogo que trae la app)
create table productos (
  id uuid primary key default gen_random_uuid(),
  n text unique not null,            -- nombre normalizado (sin acentos ni mayúsculas)
  nombre text not null,
  emoji text not null default '🛒',
  seccion text,
  unidad text,
  tienda text,                       -- dónde lo solemos comprar
  created_at timestamptz not null default now()
);

-- Tiendas donde compramos (el logo lo pone la familia con una foto)
create table tiendas (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  color text not null default '#2F7A55',
  logo text,
  orden int not null default 0,
  created_at timestamptz not null default now()
);

create table ajustes (
  clave text primary key,
  valor jsonb not null
);

-- Seguridad: solo quien haya entrado con la cuenta familiar puede leer y escribir.
-- Tiempo real: cada cambio se envía al instante a los demás móviles.
do $$
declare t text;
begin
  foreach t in array array['miembros','compra','tareas','tareas_hechas','eventos','avisos','ajustes','compras_hechas','productos','tiendas'] loop
    execute format('alter table %I enable row level security', t);
    execute format('create policy "familia" on %I for all to authenticated using (true) with check (true)', t);
    execute format('alter publication supabase_realtime add table %I', t);
  end loop;
end $$;

-- Marca como vistos todos los avisos para un miembro (de una vez y sin pisar a nadie)
create function marcar_vistos(p_miembro uuid) returns void
language sql security invoker as $$
  update avisos set vistos = vistos || to_jsonb(p_miembro::text)
  where not (vistos ? p_miembro::text);
$$;

-- ==========================================================
--  Datos iniciales (sacados de las hojas de la nevera)
-- ==========================================================
-- Cada uno elige su color al entrar la primera vez (Mami ya tiene el lila).
insert into miembros (nombre, color, forma, orden, rota, color_ok) values
  ('Sandra', '#FF7043', 'circulo', 0, true,  false),
  ('Lorena', '#1E88E5', 'circulo', 1, true,  false),
  ('Rafa',   '#43A047', 'circulo', 2, true,  false),
  ('Papi',   '#F5B700', 'circulo', 3, false, false),
  ('Mami',   '#A78BDA', 'circulo', 4, false, true);

insert into tiendas (nombre, color, orden) values
  ('Mercadona', '#2F7A55', 0), ('Lidl', '#4E7BA8', 1), ('Aldi', '#3E8A88', 2),
  ('Carrefour', '#6A5ACD', 3), ('Deza', '#B5654F', 4), ('Dia', '#C0845A', 5);

-- Las tareas del cuadrante: cada semana, por turnos, desde el lunes 31/08/2026
with m as (select nombre, id::text as id from miembros)
insert into tareas (nombre, turnos, fecha, repite, flexible)
select 'Baño + Polvo', jsonb_build_array((select id from m where nombre='Lorena'),(select id from m where nombre='Sandra'),(select id from m where nombre='Rafa')), date '2026-08-31', 'semanal', true
union all
select 'Mopa + Fregar', jsonb_build_array((select id from m where nombre='Rafa'),(select id from m where nombre='Lorena'),(select id from m where nombre='Sandra')), date '2026-08-31', 'semanal', true
union all
select 'Basura + Aspiradora', jsonb_build_array((select id from m where nombre='Sandra'),(select id from m where nombre='Rafa'),(select id from m where nombre='Lorena')), date '2026-08-31', 'semanal', true;

-- Las semanas pasadas (31/08 a 11/10) ya están hechas, cada una por quien le tocaba
insert into tareas_hechas (tarea, fecha, hecha_por)
select t.id, s::date, (t.turnos ->> (((s::date - t.fecha) / 7) % jsonb_array_length(t.turnos)))::uuid
from tareas t, generate_series(date '2026-08-31', date '2026-10-05', interval '7 days') s
where t.repite = 'semanal';

-- Lo que quedó pendiente de la semana pasada (estaba apuntado a mano en la hoja)
insert into tareas (nombre, descripcion, miembro, fecha, flexible, prioridad)
select 'Baño + Polvo', 'Pendiente de la semana pasada', id, date '2026-10-12', true, 'alta' from miembros where nombre = 'Rafa'
union all
select 'Basura', 'Pendiente de la semana pasada', id, date '2026-10-12', true, 'alta' from miembros where nombre = 'Rafa';

-- La lista de la compra empieza vacía.
