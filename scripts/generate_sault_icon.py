from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont


ROOT = Path(__file__).resolve().parents[1]
ICON_DIR = ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
SOURCE_SIZE = 1024

BG = "#0F0F10"
BG_DEEP = "#151517"
GOLD = "#D6C3A1"
GOLD_SOFT = "#E7DBCA"
TEXT = "#F5F1E8"
MUTED = "#8A8379"


def load_font(size: int) -> ImageFont.FreeTypeFont:
    candidates = [
        "/System/Library/Fonts/SFNS.ttf",
        "/System/Library/Fonts/SFCompact.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
    ]
    for candidate in candidates:
        path = Path(candidate)
        if path.exists():
            return ImageFont.truetype(str(path), size=size)
    return ImageFont.load_default()


def add_radial_glow(base: Image.Image, center: tuple[float, float], radius: int, color: str, alpha: int) -> None:
    glow = Image.new("RGBA", base.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(glow)
    cx, cy = center
    for step in range(radius, 0, -10):
      opacity = int(alpha * (step / radius) ** 2)
      rgb = tuple(int(color[i : i + 2], 16) for i in (1, 3, 5))
      draw.ellipse(
          (cx - step, cy - step, cx + step, cy + step),
          fill=(*rgb, opacity),
      )
    base.alpha_composite(glow.filter(ImageFilter.GaussianBlur(22)))


def build_source_icon() -> Image.Image:
    image = Image.new("RGBA", (SOURCE_SIZE, SOURCE_SIZE), BG)
    draw = ImageDraw.Draw(image)

    # Layered dark gradient field
    for y in range(SOURCE_SIZE):
        t = y / (SOURCE_SIZE - 1)
        if t < 0.45:
            blend = t / 0.45
            color = tuple(
                int(int(BG[i : i + 2], 16) * (1 - blend) + int(BG_DEEP[i : i + 2], 16) * blend)
                for i in (1, 3, 5)
            )
        else:
            blend = (t - 0.45) / 0.55
            color = tuple(
                int(int(BG_DEEP[i : i + 2], 16) * (1 - blend) + int(BG[i : i + 2], 16) * blend)
                for i in (1, 3, 5)
            )
        draw.line((0, y, SOURCE_SIZE, y), fill=(*color, 255))

    add_radial_glow(image, (812, 176), 240, GOLD, 22)
    add_radial_glow(image, (248, 808), 200, GOLD_SOFT, 10)
    add_radial_glow(image, (512, 456), 180, GOLD, 8)

    title_font = load_font(204)
    title = "SAULT"
    bbox = draw.textbbox((0, 0), title, font=title_font)
    text_w = bbox[2] - bbox[0]
    x = (SOURCE_SIZE - text_w) / 2 - 22
    y = 396

    shadow = Image.new("RGBA", image.size, (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.text((x, y + 4), title, font=title_font, fill=(214, 195, 161, 48))
    image.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(12)))

    draw.text((x, y), title, font=title_font, fill=TEXT)

    dot_x = x + text_w - 18
    dot_y = y + 174
    draw.ellipse((dot_x, dot_y, dot_x + 28, dot_y + 28), fill=GOLD)

    dot_glow = Image.new("RGBA", image.size, (0, 0, 0, 0))
    dot_glow_draw = ImageDraw.Draw(dot_glow)
    dot_glow_draw.ellipse((dot_x - 10, dot_y - 10, dot_x + 38, dot_y + 38), fill=(214, 195, 161, 48))
    image.alpha_composite(dot_glow.filter(ImageFilter.GaussianBlur(12)))
    draw.ellipse((dot_x, dot_y, dot_x + 28, dot_y + 28), fill=GOLD)

    return image.convert("RGB")


def resize_existing_icons(source: Image.Image) -> None:
    for icon_path in ICON_DIR.glob("*.png"):
        size = int(icon_path.stem)
        resized = source.resize((size, size), Image.Resampling.LANCZOS)
        resized.save(icon_path)


def main() -> None:
    ICON_DIR.mkdir(parents=True, exist_ok=True)
    source = build_source_icon()
    resize_existing_icons(source)


if __name__ == "__main__":
    main()
