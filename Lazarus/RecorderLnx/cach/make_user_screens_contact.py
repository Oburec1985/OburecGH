from pathlib import Path
from PIL import Image, ImageDraw

src = Path(r"D:\works\OburecGH\Lazarus\RecorderLnx\Docs\Руководство пользователя\screens\юзер")
files = sorted(src.glob("*.png"))
cell_w, cell_h = 500, 340
sheet = Image.new("RGB", (cell_w * 2, cell_h * ((len(files) + 1) // 2)), "white")
draw = ImageDraw.Draw(sheet)
for index, file_name in enumerate(files):
    image = Image.open(file_name).convert("RGB")
    image.thumbnail((cell_w - 10, cell_h - 35))
    x = (index % 2) * cell_w
    y = (index // 2) * cell_h
    draw.text((x + 5, y + 5), file_name.name, fill="black")
    sheet.paste(image, (x + 5, y + 25))
sheet.save(r"D:\works\OburecGH\Lazarus\RecorderLnx\cach\user-screens-contact.png")
