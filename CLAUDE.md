# GyG — instrucciones para Claude

Eres mi ayudante para mantener y mejorar GyG, una app web familiar (PWA) ya publicada que mi familia usa a diario en el móvil. Trabajas directamente en esta carpeta, que es el repositorio gygfamily/GyG clonado con GitHub Desktop. En cada chat te diré la tarea concreta.

## Qué es GyG
- App familiar para 5 personas: Sandri, Lore, Rafa (yo), Papi y Mami (ya no se pueden añadir más). Sustituye la lista de la compra y el cuadrante de tareas de la nevera.
- Pestañas: Compra, Gastos, Tareas, Agenda y Avisos, más Ajustes desde el botón con mi nombre arriba.
- Sin IA dentro de la app. Funciona sin cobertura y sincroniza los cambios para todos.
- Muy simple: mis padres tienen poca soltura con la tecnología.

## Diseño
- Minimalista: fondo casi blanco (#F8F6FA), cabecera y barra inferior blancas con línea fina; morado suave #83389A solo como acento. theme-color #FFFFFF.
- Título "GyG" en Cormorant Garamond; el resto en Nunito.
- Logo: monograma G&G morado (imagen WebP incrustada en la constante LOGO). Iconos icon-192/512 transparentes; icon-180 con fondo blanco.
- Animación de entrada (~1,9 s): logo y "GyG" sobre blanco, luego la app sube suave (clase "entrando"). Iconos de la barra inferior animados al pulsarlos (clase "pop", una animación por pestaña). Todo se desactiva con "reducir movimiento".
- Número del día del calendario centrado (puntos de eventos en posición absoluta).
- Perfiles: 30 colores + "Otro color", foto de perfil desde la galería (200 px, JPEG, en miembros.foto), avatar con inicial si no hay foto.

## Funciones
- Compra: catálogo de 565 productos con iconos propios, buscador, productos a mano, "Lo de siempre", − / + con cantidad y unidad, agrupar por sección o tienda, "En el carro", "Terminar compra" (reinicia y registra fecha, tienda y gasto).
- Gastos: presupuesto mensual, gasto por tienda, historial, compra con foto del ticket (tesseract.js).
- Tareas: sin gamificación (nada de puntos, estrellas, rankings ni recompensas). Duplas Baño + Polvo, Mopa + Fregar y Basura + Aspiradora rotando cada semana entre Sandra, Lorena y Rafa desde el lunes 31/08/2026. "Mi semana" + planning (cada uno solo marca las suyas) + "Algo está mal hecho" (revisión).
- Castigos: sección bajo Mi semana con "Poner un castigo" (quién, tareas de más, esta semana o la próxima, motivo). Son tareas sin repetición con castigo=true, miembro, fecha = lunes, flexible, prioridad alta. Se suman a la semana de esa persona, salen en el planning con borde rojo y etiqueta "Castigo", y si no se hacen quedan como "acumulado".
- Agenda: eventos que se repiten (semanal/mensual/anual). Avisos con "visto" y fijados.

## Técnico
- Hosting: GitHub Pages (gygfamily/GyG, público) → https://gygfamily.github.io/GyG/ . Se publica solo al hacer push a main.
- Backend: Supabase, proyecto nnybcvabmbrloobnzrxo (West EU, gratis). Cuenta familiar única; login solo con contraseña y sesión persistente. La clave "anon" del CONFIG es pública y es normal; protege el login + RLS. Nunca escribas contraseñas en esta carpeta (el repositorio es público).
- index.html: toda la app en un archivo. Los estilos nuevos van en bloques al final del <style> (última: Ronda 26).
- sw.js: red primero para la app; caché primero para jsdelivr y Google Fonts; no guarda datos de Supabase. Caché actual gyg-v25: súbela en cada cambio.
- manifest.webmanifest, logo.svg, icon-180-v2/192-v2/512-v2.png (los icon-180/192/512.png sin -v2 ya no se usan). logo.png y logo-grande.png ya no se usan.
- Si cambia el logo, pon nombres nuevos a los iconos (icon-192-v2.png…) y actualiza manifest e index.html, para que Android cambie el icono sin reinstalar. En iPhone siempre hay que quitarla y volver a añadirla.
- supabase.sql ya ejecutado: NO volver a ejecutarlo. Los cambios de base de datos van en SQL corto aparte.
- Carpeta demo/ (gygfamily.github.io/GyG/demo/, con sus propios index.html, sw.js, manifest e iconos; NUNCA copiar esos archivos a la raíz): demo instalable con datos inventados y Supabase falso, para enseñarla. Usa localStorage con prefijo "demo:" y su propio sw.js (gyg-demo-v2). Se genera desde index.html cambiando la librería de Supabase por un cliente falso.
- CDN: supabase-js@2.45.4, Nunito, Cormorant Garamond, tesseract.js@5.1.1.
- Sin cobertura: todas las escrituras pasan por una cola (db.from / vaciarCola) y se guardan en localStorage (gyg-cola, gyg-cache) hasta que vuelve la señal. Tiempo real con postgres_changes sobre todas las tablas.
- Funciones clave: init, intro, render, tabsHTML, vCompra, vHistorial, vTareas, vCastigos, formCastigo, vCal, vAvisos, vAjustes, formMiembro, procesarFoto, iman, leerTicket, elegirYo.

## Tablas de Supabase (RLS "familia", solo autenticados, todas en supabase_realtime)
- miembros: id, nombre, color, orden, color_ok, foto, forma (= animación de su círculo: ninguna, latido, rebote, flotar, brillo, giro, aura, respirar, columpio, voltereta; valores antiguos cuentan como ninguna). rota sin uso
- compra: id, texto, seccion, emoji, n, unidad, hecho, autor, created_at, updated_at
- productos: id, n (único), nombre, emoji, seccion, unidad, tienda
- tiendas: id, nombre, color, logo (base64), orden
- compras_hechas: id, fecha, quien, tienda, total, notas, productos (jsonb)
- tareas: id, nombre, descripcion, miembro, turnos (jsonb), fecha, hora, repite, flexible, prioridad, revisa, revisa_fecha, autor, castigo
- tareas_hechas: tarea, fecha, hecha_por, hecha_at. PK (tarea, fecha)
- eventos: id, titulo, fecha, hora, miembro, para (jsonb: lista de ids; vacía = toda la familia), notas, repite, autor
- avisos: id, texto, autor, fijado, vistos (jsonb)
- ajustes: clave (PK), valor (jsonb); de momento solo "presupuesto"
- Función marcar_vistos(p_miembro uuid)

## Fallos conocidos
- Dos personas tocando + sin señal en el mismo producto: gana el último valor.
- Al borrar un miembro no se limpian sus turnos.
- Los avisos de borrados en tiempo real son genéricos.
- El ticket descarga varios MB la primera vez y puede detectar productos de más.
- Supabase gratis pausa el proyecto tras 7 días sin uso.
- La primera vez en un móvil, "¿Quién eres?" sale encima de la animación de entrada.

## Ideas pendientes
Notificaciones push (sobre todo para avisos/mensajes), modo fácil para Papi y Mami, productos por voz, precio por producto desde el ticket, recordatorio de tareas el domingo, menú semanal que pase ingredientes a la compra, copia de seguridad exportable, limpiar columnas y logos sin uso.

## Cómo quiero que trabajes
- Respóndeme siempre en español y dame las opciones para elegir como botones cuando se pueda.
- Antes de cambiar algo, dime qué archivos vas a tocar. No rompas lo que funciona: la familia la usa.
- Si un cambio afecta a Supabase, dame el SQL exacto y dime dónde pegarlo (pestaña nueva y en blanco del SQL Editor, nunca la del script grande).
- Cuando cambies archivos de la app, sube tú la versión de caché de sw.js.
- Si se puede, actualiza también demo/ para que pueda probarlo antes.
- Explícame los pasos de forma sencilla: no soy programador profesional.
- Céntrate solo en la tarea; no hagas cambios ni revisiones que no te pida.
- Al terminar, recuérdame hacer Commit to main y Push origin en GitHub Desktop (o hazlo tú si te lo pido) y actualiza este CLAUDE.md con lo que haya cambiado.

## Multas
- Tabla multas (id, miembro, concepto, importe, fecha, pagada, autor, created_at). Solo para Sandra, Lorena y Rafa; 1 € por defecto.

## Ronda 16
- Botón luna/sol arriba a la derecha (junto a Ajustes) para cambiar entre claro y oscuro; en Ajustes sigue el modo Automático.
- Colores por sección siempre visibles en la barra: Compra verde, Gastos dorado, Tareas azul, Agenda rojo, Avisos naranja.
- Logos de tienda: al subirlos se recortan solos (quita el fondo sobrante y los centra); se ven sobre blanco con el mismo redondeo en todas partes.
- Compra: si escribes la tienda detrás del producto ("barbacoa deza o lidl"), apunta "Barbacoa" y guarda Deza como su tienda habitual (la primera que se nombre). El buscador enseña al lado de cada producto dónde se suele comprar.

## Ronda 17
- Cada sección usa sus propios tonos (botones, títulos, chips, selectores) según el color de su pestaña; Ajustes y el título GyG siguen en morado. Se controla con html[data-sec] que pone render().
- Avatar de los avisos sin recuadro de fondo (antes dejaba esquinas sobre la línea de la tarjeta).
- Pendiente posible: tienda "solo esta vez" para un producto (necesitaría columna compra.tienda).

## Ronda 18
- Modo oscuro negro (#000, tarjetas #121212) en lugar del morado oscuro; títulos de cada sección en su color.
- Cantidad de la compra rediseñada: sin cápsula de fondo, solo − y + en el color de la sección.
- Papelera, borde de tareas pendientes, etiqueta "Pendiente" y selectores con el color de la sección (completadas verde, atrasadas rojo).

## Ronda 19
- Título "GyG" de la cabecera como el monograma del logo: G mayúsculas con degradado (morado en claro, plata-lila en oscuro) y la "y" en cursiva más pequeña.

## Ronda 20
- Compra: el visto del círculo va centrado; al marcar, el círculo da un saltito y el visto aparece; al desmarcar, se encoge un momento. Solo se anima el producto tocado (animChk).

## Ronda 21
- Círculo de marcar rediseñado: relleno con degradado del color de la sección, visto dibujado (SVG), onda con chispitas al marcar y vaciado al desmarcar; con margen para que no se corte.
- Debajo de cada producto, el avatar pequeño de quien lo apuntó (como el "Visto por" de avisos), junto a la tienda.

## Ronda 22
- Animaciones en toda la app: botones que se hunden al pulsar; − / + con toque y la cantidad que sube o baja; productos nuevos que entran deslizando (también los que apuntan otros); círculo de tarea hecha con saltito; ventanas que se abren desde abajo; contenido que entra suave al cambiar de pestaña; botón de tema que gira. Todo se quita con "reducir movimiento".

## Ronda 23
- Compra: el círculo de quien apuntó cada producto va justo a la izquierda del −; la cantidad sale apilada (número y unidad debajo) para dejar sitio al nombre; si un nombre no cabe, ajustarNombres() baja la letra solo en ese producto (máximo 3 líneas, mínimo 10,5 px).
- Color beige (#E3CBA5) el primero de la paleta; en colores claros la inicial sale en marrón oscuro.
- Cada persona elige la animación de su círculo en su ficha (Ajustes → Familia): Quieto, Latido, Rebote, Brillo, Giro, Aura o Saludo. Se guarda en miembros.forma, sin SQL nuevo.

## Ronda 24
- Quitado el botón de añadir miembros. Nombres: Sandri y Lore (idSandra acepta "sandra" o "sandri" para las multas).
- Intro: "GyG" con el mismo degradado morado que la cabecera.
- 10 animaciones de círculo (sale "Saludo"; entran Flotar, Ondas, Órbita y Arcoíris). Letra del círculo centrada con text-box.
- Agenda: "Para" con varias personas (columna eventos.para); tarjetas con bloque de fecha grande, puntos de color por persona, casillas más altas y aviso de día vacío.

## Ronda 25
- Fuera Órbita, Ondas y Arcoíris (demasiado llamativas); entran Respirar, Columpio y Voltereta (10 en total con Quieto).
- Ajustes → Familia: los 5 en una fila de 5 columnas, círculos de 46 px y aire para que ninguna animación se corte.
- Al marcar un producto ya no salen chispitas, solo la onda.
- Agenda en oscuro: bloque de fecha con colores más claros.

## Ronda 26
- La inicial de los círculos (iman) se dibuja como SVG con la base calculada por la altura de las mayúsculas: queda centrada en cualquier tamaño, sitio y móvil.
