# Identidad visual · Lanositos

Rediseño vectorial del logo original (`logo-original.png`), manteniendo sus elementos: anillo de huellas rellenas y huecas, texto arqueado "PELUQUERÍA CANINA", huella central con textura, gotas de agua y cinta rosa con el nombre.

Mejoras respecto al original: formas limpias y consistentes, texto convertido a trazados (no depende de fuentes instaladas), proporciones ajustadas para que la cinta no tape las huellas, versiones sin fondo, horizontal y de icono de app, y paleta definida.

## Archivos

| Archivo | Uso |
|---|---|
| `logo-lanositos.svg` | Logo principal con fondo turquesa (redes, impresión, pantalla de inicio de la app). |
| `logo-lanositos-transparente.svg` | Mismo logo sin fondo, para colocar sobre fotos o fondos claros/turquesa. |
| `logo-horizontal.svg` | Cabecera de la web y correos (huella + nombre + subtítulo). |
| `icono-app-foreground.svg` | Capa frontal del icono adaptativo de Android (con textura). |
| `icono-app-foreground-plano.svg` | Misma capa sin `<use>`/`<pattern>`: es la que acepta Android Studio al importar como *Vector Asset*. |
| `icono-app-background.svg` | Capa de fondo del icono (turquesa). |
| `icono-app-monochrome.svg` | Icono monocromo para temas de Android 13+ (blanco sobre transparente; el sistema lo tiñe). |
| `icono-app-preview.svg` | Vista previa del icono tal como lo recorta el lanzador (círculo de 72 dp). |
| `png/` | Renders listos: logo 1024 px, horizontal 1500 px, icono 512 px, capa frontal 1024 px. |
| `build_logo.py` | Script que genera todos los SVG (requiere `fonttools`; usa la fuente Fredoka). |

## Paleta

| Nombre | Hex | Uso |
|---|---|---|
| Turquesa | `#18C3CD` | Fondo del logo, color primario de app y web. |
| Morado | `#5B2EE6` | Huellas, iconos, botones secundarios. |
| Morado profundo | `#4A1FD3` | Texto del nombre, contornos. |
| Morado claro | `#A08CFF` | Textura de la huella central, estados hover. |
| Rosa | `#F56BDC` | Cinta, acentos, botones de acción principal. |
| Rosa oscuro | `#C84DB7` | Pliegues de la cinta, hover de botones rosas. |
| Gota | `#B6F2F7` | Gotas, fondos suaves, tarjetas. |
| Tinta | `#1F1A4E` | Texto principal sobre fondos claros y turquesa. |
| Blanco | `#FFFFFF` | Fondos de contenido. |

Contraste: tinta sobre turquesa y sobre blanco supera el nivel AA para texto normal; morado profundo sobre rosa cumple AA para texto grande (el nombre en la cinta). Para texto pequeño sobre rosa usar tinta.

## Tipografía

- **Fredoka** (Google Fonts, licencia OFL, gratis): títulos y nombre de marca (peso 600–700). Es la fuente del logo.
- **Nunito** o **Inter** (Google Fonts, gratis): texto de interfaz en app y web.
- En Android se incluyen como fuentes del proyecto (`res/font`); en la web se cargan desde Google Fonts o se alojan en IONOS.

## Cómo usar el icono en Android Studio

1. `Resource Manager` → `+` → **Image Asset** → *Launcher Icons (Adaptive and Legacy)*.
2. Capa *Foreground*: `png/icono-app-foreground-1024.png` (o `icono-app-foreground-plano.svg` como Vector Asset); escala al 100 % sin recortar.
3. Capa *Background*: color `#18C3CD`.
4. *Monochrome*: `icono-app-monochrome.svg`.
5. Android Studio genera todas las densidades y el icono de 512 px para Google Play.

## Reglas de uso

- No deformar el logo ni cambiar los colores de la huella y la cinta.
- Espacio libre mínimo alrededor: el alto de la cinta.
- Sobre fondos oscuros usar la versión transparente; sobre fotos, la versión con fondo turquesa en una esquina.
- Tamaño mínimo del logo principal: 120 px (pantalla) / 25 mm (impresión); por debajo usar solo la huella (icono).
