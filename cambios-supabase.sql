-- GyG: foto de perfil y castigos (ejecutar UNA vez, antes de subir el nuevo index.html)
alter table miembros add column if not exists foto text;
alter table tareas add column if not exists castigo boolean not null default false;
