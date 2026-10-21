"""Genera los SVG del logo de Lanositos con el texto convertido a trazados.

Uso: python3 -I build_logo.py <ruta Fredoka.ttf> <carpeta salida>
"""
import math
import os
import sys

from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer

FONT_PATH, OUT_DIR = sys.argv[1], sys.argv[2]
os.makedirs(OUT_DIR, exist_ok=True)

# ----------------------------------------------------------------- fuente
base = TTFont(FONT_PATH)
bold = instancer.instantiateVariableFont(base, {"wght": 700, "wdth": 100})
semi = instancer.instantiateVariableFont(TTFont(FONT_PATH), {"wght": 600, "wdth": 100})


class Face:
    def __init__(self, font):
        self.font = font
        self.gs = font.getGlyphSet()
        self.cmap = font.getBestCmap()
        self.upem = font["head"].unitsPerEm
        self.hmtx = font["hmtx"]
        self.cap = font["OS/2"].sCapHeight / self.upem

    def glyph(self, ch, size):
        gname = self.cmap[ord(ch)]
        pen = SVGPathPen(self.gs)
        s = size / self.upem
        self.gs[gname].draw(TransformPen(pen, (s, 0, 0, -s, 0, 0)))
        return pen.getCommands(), self.hmtx[gname][0] * s


BOLD, SEMI = Face(bold), Face(semi)


def text_on_arc(face, text, cx, cy, r, size, spacing=0, fill="#000", opacity=None):
    """Texto centrado en lo alto de un arco de centro (cx,cy) y radio r (base)."""
    glyphs = [face.glyph(c, size) for c in text]
    total = sum(a for _, a in glyphs) + spacing * (len(text) - 1)
    start = -math.pi / 2 - (total / r) / 2
    out, cum = [], 0.0
    for d, adv in glyphs:
        th = start + (cum + adv / 2) / r
        x, y = cx + r * math.cos(th), cy + r * math.sin(th)
        rot = math.degrees(th + math.pi / 2)
        if d:
            op = f' opacity="{opacity}"' if opacity else ""
            out.append(
                f'<path d="{d}" fill="{fill}"{op} transform="translate({x:.2f} {y:.2f}) '
                f'rotate({rot:.2f}) translate({-adv/2:.2f} 0)"/>'
            )
        cum += adv + spacing
    return "\n".join(out)


def text_straight(face, text, x, y, size, spacing=0, fill="#000", anchor="start"):
    glyphs = [face.glyph(c, size) for c in text]
    total = sum(a for _, a in glyphs) + spacing * (len(text) - 1)
    cur = x - (total / 2 if anchor == "middle" else total if anchor == "end" else 0)
    out = []
    for d, adv in glyphs:
        if d:
            out.append(f'<path d="{d}" fill="{fill}" transform="translate({cur:.2f} {y:.2f})"/>')
        cur += adv + spacing
    return "\n".join(out), total


# ----------------------------------------------------------------- paleta
TURQ = "#18C3CD"
PURPLE = "#5B2EE6"
PURPLE_DEEP = "#4A1FD3"
PURPLE_LIGHT = "#A08CFF"
PINK = "#F56BDC"
PINK_DARK = "#C84DB7"
PINK_LIGHT = "#FFB3EE"
DROP = "#B6F2F7"
DROP_HI = "#EAFDFF"
INK = "#1F1A4E"

PAW_SHAPES = (
    '<path d="M0,-18 C30,-18 58,2 58,34 C58,62 38,78 16,80 C7,81 3,75 0,75 '
    'C-3,75 -7,81 -16,80 C-38,78 -58,62 -58,34 C-58,2 -30,-18 0,-18 Z"/>'
    '<ellipse cx="-66" cy="-24" rx="21" ry="29" transform="rotate(-28 -66 -24)"/>'
    '<ellipse cx="-24" cy="-60" rx="21" ry="31" transform="rotate(-9 -24 -60)"/>'
    '<ellipse cx="24" cy="-60" rx="21" ry="31" transform="rotate(9 24 -60)"/>'
    '<ellipse cx="66" cy="-24" rx="21" ry="29" transform="rotate(28 66 -24)"/>'
)
DROP_SHAPE = (
    '<path d="M0,-46 C13,-24 29,-6 29,15 A29,29 0 1,1 -29,15 C-29,-6 -13,-24 0,-46 Z"/>'
)


def defs(prefix=""):
    return f"""<defs>
  <g id="{prefix}paw">{PAW_SHAPES}</g>
  <g id="{prefix}drop">{DROP_SHAPE}</g>
  <pattern id="{prefix}hatch" patternUnits="userSpaceOnUse" width="16" height="16" patternTransform="rotate(40)">
    <rect width="16" height="16" fill="{PURPLE}"/>
    <rect width="5" height="16" fill="{PURPLE_LIGHT}" opacity="0.55"/>
  </pattern>
</defs>"""


def pt(cx, cy, r, th):
    return cx + r * math.cos(th), cy + r * math.sin(th)


def ribbon(cx_band, cy_band, rc, half_angle, half_th, notch, text, text_size, text_spacing):
    """Cinta curvada con cola en cada extremo y texto centrado."""
    ro, ri = rc + half_th, rc - half_th
    ta, tb = -math.pi / 2 - half_angle, -math.pi / 2 + half_angle
    parts = []

    def u(th):
        return math.cos(th), math.sin(th)

    def t(th):
        return -math.sin(th), math.cos(th)

    # colas (detrás)
    for th, sign in ((ta, -1), (tb, 1)):
        ux, uy = u(th)
        tx, ty = t(th)
        drop = 18  # cuánto baja la cola respecto a la cinta
        length = 58
        bx, by = cx_band + (ro - 12) * ux, cy_band + (ro - 12) * uy
        cxp, cyp = cx_band + (ri + 4) * ux, cy_band + (ri + 4) * uy
        p1 = (bx - drop * ux, by - drop * uy)
        p4 = (cxp - drop * ux, cyp - drop * uy)
        p2 = (p1[0] + sign * length * tx, p1[1] + sign * length * ty)
        p3 = (p4[0] + sign * length * tx, p4[1] + sign * length * ty)
        mid = ((p2[0] + p3[0]) / 2 - sign * notch * tx, (p2[1] + p3[1]) / 2 - sign * notch * ty)
        pts = [p1, p2, mid, p3, p4]
        d = "M" + " L".join(f"{x:.2f},{y:.2f}" for x, y in pts) + " Z"
        parts.append(f'<path d="{d}" fill="{PINK_DARK}"/>')

    # cinta principal
    A = pt(cx_band, cy_band, ro, ta)
    B = pt(cx_band, cy_band, ro, tb)
    C = pt(cx_band, cy_band, ri, tb)
    D = pt(cx_band, cy_band, ri, ta)
    ua, uta = u(ta), t(ta)
    ub, utb = u(tb), t(tb)
    Mb = pt(cx_band, cy_band, rc, tb)
    Ma = pt(cx_band, cy_band, rc, ta)
    Nb = (Mb[0] - notch * utb[0], Mb[1] - notch * utb[1])
    Na = (Ma[0] + notch * uta[0], Ma[1] + notch * uta[1])
    d = (
        f"M{A[0]:.2f},{A[1]:.2f} A{ro},{ro} 0 0,1 {B[0]:.2f},{B[1]:.2f} "
        f"L{Nb[0]:.2f},{Nb[1]:.2f} L{C[0]:.2f},{C[1]:.2f} "
        f"A{ri},{ri} 0 0,0 {D[0]:.2f},{D[1]:.2f} L{Na[0]:.2f},{Na[1]:.2f} Z"
    )
    parts.append(f'<path d="{d}" fill="{PINK}"/>')
    # brillo superior
    A2 = pt(cx_band, cy_band, ro - 10, ta + 0.02)
    B2 = pt(cx_band, cy_band, ro - 10, tb - 0.02)
    parts.append(
        f'<path d="M{A2[0]:.2f},{A2[1]:.2f} A{ro-10},{ro-10} 0 0,1 {B2[0]:.2f},{B2[1]:.2f}" '
        f'fill="none" stroke="{PINK_LIGHT}" stroke-width="5" stroke-linecap="round" opacity="0.7"/>'
    )
    # texto centrado verticalmente en la cinta
    cap = BOLD.cap * text_size
    r_text = rc - cap / 2
    parts.append(text_on_arc(BOLD, text, cx_band, cy_band, r_text, text_size, text_spacing, PURPLE_DEEP))
    return "\n".join(parts)


def paw_ring(cx, cy, r, n, scale, prefix="", skip=()):
    out = []
    for i in range(n):
        if i in skip:
            continue
        th = -math.pi / 2 + i * 2 * math.pi / n
        x, y = pt(cx, cy, r, th)
        rot = math.degrees(th + math.pi / 2)
        tr = f'translate({x:.2f} {y:.2f}) rotate({rot:.2f}) scale({scale})'
        if i % 2 == 0:
            out.append(f'<use href="#{prefix}paw" transform="{tr}" fill="{PURPLE}"/>')
        else:
            out.append(
                f'<use href="#{prefix}paw" transform="{tr}" fill="none" stroke="{PURPLE}" '
                f'stroke-width="13" stroke-linejoin="round"/>'
            )
    return "\n".join(out)


def drops(cx, cy, mirror=False, scale=1.0, prefix="", size=None):
    size = scale if size is None else size
    spec = [(-182, 18, 80, 1.0), (-160, -52, 50, 0.72), (-158, 92, 118, 0.66)]
    out = []
    for dx, dy, rot, s in spec:
        if mirror:
            dx, rot = -dx, -rot
        x, y = cx + dx * scale, cy + dy * scale
        out.append(
            f'<g transform="translate({x:.2f} {y:.2f}) rotate({rot}) scale({s*size:.3f})">'
            f'<use href="#{prefix}drop" fill="{DROP}"/>'
            f'<ellipse cx="-9" cy="14" rx="7" ry="11" fill="{DROP_HI}" opacity="0.9" transform="rotate(-20 -9 14)"/></g>'
        )
    return "\n".join(out)


def central_paw(cx, cy, scale, prefix="", hatch=True):
    fill = f"url(#{prefix}hatch)" if hatch else PURPLE
    return (
        f'<use href="#{prefix}paw" transform="translate({cx} {cy}) scale({scale})" fill="{fill}" '
        f'stroke="{PURPLE_DEEP}" stroke-width="6" stroke-linejoin="round"/>'
    )


# ------------------------------------------------------------ logo principal
def logo(with_background=True):
    cx = cy = 512
    bg = f'<rect width="1024" height="1024" rx="190" fill="{TURQ}"/>' if with_background else ""
    top_text = text_on_arc(BOLD, "PELUQUERÍA CANINA", cx, cy, 333, 56, 9, INK)
    body = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">
<title>Lanositos · Peluquería canina</title>
{defs()}
{bg}
{paw_ring(cx, cy, 430, 14, 0.44, skip=(5, 9))}
{top_text}
{drops(cx, 452)}
{drops(cx, 452, mirror=True)}
{central_paw(cx, 452, 1.42)}
{ribbon(512, 2130, 1440, 0.265, 60, 38, "LANOSITOS", 88, 5)}
</svg>
"""
    return body


# -------------------------------------------------------------- horizontal
def horizontal():
    name, name_w = text_straight(BOLD, "Lanositos", 330, 232, 178, 2, PURPLE_DEEP)
    sub, _ = text_straight(SEMI, "PELUQUERÍA CANINA", 338, 318, 54, 12, INK)
    return f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1500 400" width="1500" height="400">
<title>Lanositos · Peluquería canina (horizontal)</title>
{defs("h")}
{drops(165, 200, scale=0.72, prefix="h")}
{drops(165, 200, mirror=True, scale=0.72, prefix="h")}
{central_paw(165, 200, 1.05, prefix="h")}
{name}
{sub}
</svg>
"""


# ------------------------------------------------------------- icono app
def icon_foreground():
    # 108x108 dp → 1024 px; zona segura: círculo central de 66 dp (≈ 626 px)
    return f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">
<title>Lanositos · icono (capa frontal)</title>
{defs("i")}
{drops(512, 512, scale=1.35, size=1.2, prefix="i")}
{drops(512, 512, mirror=True, scale=1.35, size=1.2, prefix="i")}
{central_paw(512, 512, 2.3, prefix="i")}
</svg>
"""


def icon_background():
    return f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">
<title>Lanositos · icono (capa de fondo)</title>
<rect width="1024" height="1024" fill="{TURQ}"/>
<circle cx="512" cy="512" r="400" fill="#FFFFFF" opacity="0.08"/>
</svg>
"""


def icon_monochrome():
    return f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">
<title>Lanositos · icono monocromo</title>
{defs("m")}
{central_paw(512, 512, 2.7, prefix="m", hatch=False).replace(PURPLE, "#FFFFFF").replace(PURPLE_DEEP, "#FFFFFF")}
</svg>
"""


def icon_preview():
    return f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">
<title>Lanositos · icono (vista previa)</title>
{defs("p")}
<!-- Simula el recorte circular del lanzador (72 dp visibles de 108 dp) -->
<circle cx="512" cy="512" r="341" fill="{TURQ}"/>
<circle cx="512" cy="512" r="300" fill="#FFFFFF" opacity="0.08"/>
{drops(512, 512, scale=1.35, size=1.2, prefix="p")}
{drops(512, 512, mirror=True, scale=1.35, size=1.2, prefix="p")}
{central_paw(512, 512, 2.3, prefix="p")}
</svg>
"""



def icon_foreground_flat():
    """Versión sin <use>, <pattern> ni <clipPath>: apta para importar como VectorDrawable."""
    def drop_flat(dx, dy, rot, sc, mirror):
        if mirror:
            dx, rot = -dx, -rot
        x, y = 512 + dx * 1.35, 512 + dy * 1.35
        k = sc * 1.2
        return (f'<g transform="translate({x:.2f} {y:.2f}) rotate({rot}) scale({k:.3f})" fill="{DROP}">'
                f'{DROP_SHAPE}</g>')
    spec = [(-182, 18, 80, 1.0), (-160, -52, 50, 0.72), (-158, 92, 118, 0.66)]
    parts = [drop_flat(*d, False) for d in spec] + [drop_flat(*d, True) for d in spec]
    parts.append(f'<g transform="translate(512 512) scale(2.3)" fill="{PURPLE}" stroke="{PURPLE_DEEP}" '
                 f'stroke-width="6" stroke-linejoin="round">{PAW_SHAPES}</g>')
    body = "\n".join(parts)
    return f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">
<title>Lanositos · icono (capa frontal, plano para VectorDrawable)</title>
{body}
</svg>
"""

files = {
    "logo-lanositos.svg": logo(True),
    "logo-lanositos-transparente.svg": logo(False),
    "logo-horizontal.svg": horizontal(),
    "icono-app-foreground.svg": icon_foreground(),
    "icono-app-foreground-plano.svg": icon_foreground_flat(),
    "icono-app-background.svg": icon_background(),
    "icono-app-monochrome.svg": icon_monochrome(),
    "icono-app-preview.svg": icon_preview(),
}
for name, content in files.items():
    with open(os.path.join(OUT_DIR, name), "w", encoding="utf-8") as fh:
        fh.write(content)
    print("escrito", name, len(content), "bytes")
