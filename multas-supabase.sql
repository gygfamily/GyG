-- GyG: tabla de multas (ejecutar UNA vez, ANTES de subir el nuevo index.html)
create table if not exists multas (
  id uuid primary key default gen_random_uuid(),
  miembro uuid references miembros(id) on delete cascade,
  concepto text not null,
  importe numeric(6,2) not null,
  fecha date not null default current_date,
  pagada boolean not null default false,
  autor uuid,
  created_at timestamptz default now()
);
alter table multas enable row level security;
create policy "familia" on multas for all to authenticated using (true) with check (true);
alter publication supabase_realtime add table multas;
