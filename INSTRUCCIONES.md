# GyG: cómo ponerla en marcha

Una sola vez, unos 20 minutos. Mejor desde un ordenador. Todo es gratis.

## 1. Base de datos (Supabase)
1. Entra en https://supabase.com, crea una cuenta y un proyecto nuevo (por ejemplo "gyg"). Región: Europa.
2. Menú izquierdo > **SQL Editor** > **New query**. Pega todo el archivo `supabase.sql` y pulsa **Run**. Debe salir "Success".

## 2. Cuenta de la familia
1. **Authentication > Users > Add user > Create new user**.
2. Pon un correo (el tuyo vale) y una contraseña para toda la familia. Marca **Auto Confirm User**.
3. **Authentication > Sign In / Providers**: desactiva **Allow new users to sign up**.

## 3. Conectar la app
1. **Project Settings > API** (o **Data API** y **API Keys**). Copia la **Project URL** y la clave **anon public**.
2. Abre `index.html` con un editor de texto (Bloc de notas vale). Arriba del código está `CONFIG`. Rellena:
   - `SUPABASE_URL`: la Project URL
   - `SUPABASE_ANON_KEY`: la clave anon public
   - `FAMILY_EMAIL`: el correo del paso 2
3. Guarda el archivo.

## 4. Publicarla (GitHub Pages)
1. Crea una cuenta en https://github.com y un repositorio nuevo **público** llamado `gyg`.
2. **Add file > Upload files** y sube: `index.html`, `manifest.webmanifest`, `sw.js`, `logo.png`, `logo-grande.png`, `logo.svg`, `icon-180.png`, `icon-192.png`, `icon-512.png`.
3. **Settings > Pages** > Branch: `main` y `/ (root)` > **Save**.
4. En 1 o 2 minutos estará en `https://TU-USUARIO.github.io/gyg/`.

## 5. En cada móvil
1. Abre el enlace, pon la contraseña familiar y elige quién eres (y tu color).
2. Instálala:
   - **iPhone (Safari):** Compartir > **Añadir a pantalla de inicio**.
   - **Android (Chrome):** menú ⋮ > **Instalar aplicación**.
3. Ajustes (engranaje) > **Tiendas**: pon el logo de cada tienda con una foto o una captura.

## Bueno saber
- La clave anon puede estar a la vista: sin la contraseña familiar no deja leer ni escribir nada.
- Leer tickets necesita internet la primera vez (descarga el lector). Mejor con luz y el ticket estirado.
- Supabase gratis pausa el proyecto tras 7 días sin ningún uso. Con uso diario no pasa; si ocurre, se reactiva con un clic desde su panel.
- Si cambias algo de la app, vuelve a subir `index.html` a GitHub. Los móviles se actualizan solos al abrirla.
