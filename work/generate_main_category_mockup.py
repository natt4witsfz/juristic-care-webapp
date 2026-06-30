from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

out = Path("outputs/mockup-main-category-align-v1.png")
out.parent.mkdir(exist_ok=True)

W, H = 980, 460
img = Image.new("RGB", (W, H), "#f5f8f6")
d = ImageDraw.Draw(img)

font_regular = "C:/Windows/Fonts/LeelawUI.ttf"
font_bold = "C:/Windows/Fonts/tahomabd.ttf"
title_font = ImageFont.truetype(font_bold, 18)
small_font = ImageFont.truetype(font_regular, 11)
body_font = ImageFont.truetype(font_bold, 16)
num_font = ImageFont.truetype(font_bold, 24)
pct_font = ImageFont.truetype(font_bold, 12)


def rr(xy, r, fill, outline=None, width=1):
    d.rounded_rectangle(xy, radius=r, fill=fill, outline=outline, width=width)


def text(xy, s, font, fill="#14322a"):
    d.text(xy, s, font=font, fill=fill)


rr((24, 24, W - 24, H - 24), 18, "#ffffff", "#dfe8e3")
text((50, 50), "ภาพรวมตามประเภทหลักของเหตุที่เกิดขึ้น", title_font)
text(
    (50, 78),
    "แบ่งงานส่วนกลางและงานลูกบ้านตามสถานะ: เสร็จแล้ว / กำลังดำเนินการ / เปิดงานใหม่",
    small_font,
    "#7c8a84",
)


def row(y, label):
    rr((50, y, W - 50, y + 150), 16, "#fbfdfc", "#dce8e3")
    text((72, y + 52), label, body_font)
    text((72, y + 82), "2 งานในช่วง 30 วัน", small_font, "#7c8a84")
    rr((225, y + 50, 280, y + 105), 14, "#e4f4ee")
    text((244, y + 65), "2", num_font, "#08745b")

    rr((320, y + 30, W - 75, y + 58), 999, "#dfe7e3")
    d.rounded_rectangle((320, y + 30, 470, y + 58), radius=999, fill="#007A5A")
    d.rectangle((456, y + 30, 610, y + 58), fill="#256FD6")
    d.rounded_rectangle((595, y + 30, W - 75, y + 58), radius=999, fill="#D99100")

    cards = [
        ("0", "0%", "เสร็จแล้ว", "#007A5A"),
        ("1", "50%", "กำลังดำเนินการ", "#256FD6"),
        ("1", "50%", "เปิดงานใหม่", "#D99100"),
    ]
    x = 320
    for n, pct, label2, color in cards:
        rr((x, y + 75, x + 160, y + 135), 12, "#ffffff", "#dce8e3")
        d.ellipse((x + 14, y + 91, x + 24, y + 101), fill=color)
        text((x + 34, y + 84), n, num_font, "#14322a")
        text((x + 120, y + 88), pct, pct_font, "#8a9892")
        text((x + 34, y + 116), label2, small_font, "#6f7f78")
        x += 175


row(115, "งานส่วนกลาง")
row(280, "งานลูกบ้าน")
img.save(out)
print(out.resolve())
