-- GyG: varias personas en la agenda + nombres nuevos
-- Ejecutar UNA vez en Supabase → SQL Editor → New query, ANTES de subir el nuevo index.html
alter table eventos add column if not exists para jsonb not null default '[]'::jsonb;
update miembros set nombre = 'Lore'   where nombre = 'Lorena';
update miembros set nombre = 'Sandri' where nombre = 'Sandra';
select nombre from miembros order by orden;
