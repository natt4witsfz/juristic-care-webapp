from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

out = Path("outputs/mockup-website-overview.png")
out.parent.mkdir(exist_ok=True)

W, H = 1440, 980
img = Image.new("RGB", (W, H), "#f4f8f6")
d = ImageDraw.Draw(img)

font_regular = "C:/Windows/Fonts/LeelawUI.ttf"
font_bold = "C:/Windows/Fonts/tahomabd.ttf"
f10 = ImageFont.truetype(font_regular, 10)
f11 = ImageFont.truetype(font_regular, 11)
f12 = ImageFont.truetype(font_regular, 12)
f13 = ImageFont.truetype(font_regular, 13)
f14 = ImageFont.truetype(font_bold, 14)
f16 = ImageFont.truetype(font_bold, 16)
f18 = ImageFont.truetype(font_bold, 18)
f22 = ImageFont.truetype(font_bold, 22)
f28 = ImageFont.truetype(font_bold, 28)


def rr(xy, r, fill, outline=None, width=1):
    d.rounded_rectangle(xy, radius=r, fill=fill, outline=outline, width=width)


def text(xy, s, font=f12, fill="#17352d"):
    d.text(xy, s, font=font, fill=fill)


def pill(x, y, label, fill, fg="#0f3a30", font=f11):
    bbox = d.textbbox((0, 0), label, font=font)
    w = bbox[2] - bbox[0] + 22
    rr((x, y, x + w, y + 28), 14, fill)
    text((x + 11, y + 6), label, font, fg)
    return x + w + 8


def section(x, y, w, h, title, subtitle=""):
    rr((x, y, x + w, y + h), 18, "#ffffff", "#dce8e3")
    text((x + 24, y + 20), title, f18)
    if subtitle:
        text((x + 24, y + 48), subtitle, f11, "#7c8a84")


# Sidebar
rr((0, 0, 280, H), 0, "#ffffff", "#dfe8e3")
rr((32, 32, 78, 78), 14, "#08745b")
text((48, 43), "J", f28, "#ffffff")
text((92, 42), "Juristic Care", f18)
text((92, 66), "Admin Dashboard", f10, "#83928c")

nav = [
    ("▦", "ภาพรวม", True),
    ("▧", "งานส่วนกลาง", False),
    ("▨", "งานของลูกบ้าน", False),
    ("◎", "Pool งานกลาง", False),
    ("✓", "งานของฉัน", False),
    ("⚒", "งานช่างอาคาร", False),
    ("✦", "งานแม่บ้าน", False),
    ("♙", "ทีมงาน", False),
    ("▤", "ลูกบ้าน", False),
    ("▣", "ประกาศ", False),
    ("☰", "Admin Log", False),
]
y = 116
for icon, label, active in nav:
    if active:
        rr((24, y - 8, 256, y + 38), 12, "#e6f4ef")
        fg = "#08745b"
    else:
        fg = "#41534c"
    text((42, y), icon, f14, fg)
    text((72, y), label, f13, fg)
    y += 52

# Top
text((320, 34), "ภาพรวม", f28)
text((320, 72), "ภาพรวมงานส่วนกลางและงานสำคัญที่นิติและคณะกรรมการกำลังดูแล", f12, "#7c8a84")
pill(1090, 42, "วันนี้", "#e6f4ef", "#08745b", f12)
pill(1158, 42, "7 วัน", "#ffffff", "#60706a", f12)
pill(1230, 42, "30 วัน", "#ffffff", "#60706a", f12)
rr((1320, 34, 1384, 78), 14, "#ffffff", "#dce8e3")
text((1341, 46), "EN", f14, "#08745b")

# Stat cards
stats = [
    ("เปิดงาน", "2", "#fff4d9", "#c97900"),
    ("กำลังดำเนินการ", "2", "#e3efff", "#256fd6"),
    ("เสร็จแล้ว", "0", "#e4f4ee", "#007a5a"),
    ("ประกาศ", "4", "#f1edff", "#6b3fd4"),
]
x = 320
for title, val, bg, fg in stats:
    rr((x, 112, x + 245, 220), 18, "#ffffff", "#dce8e3")
    rr((x + 18, 132, x + 58, 172), 12, bg)
    text((x + 74, 132), title, f12, "#60706a")
    text((x + 74, 156), val, f28, fg)
    text((x + 74, 190), "อัปเดตล่าสุดวันนี้", f10, "#8a9892")
    x += 265

# Main category overview
section(320, 250, 1040, 340, "ภาพรวมตามประเภทหลักของเหตุที่เกิดขึ้น", "แบ่งงานส่วนกลางและงานลูกบ้านตามสถานะ: เสร็จแล้ว / กำลังดำเนินการ / เปิดงานใหม่")


def main_row(y, label):
    rr((352, y, 1328, y + 116), 16, "#fbfdfc", "#dce8e3")
    text((380, y + 42), label, f16)
    text((380, y + 70), "2 งานในช่วง 30 วัน", f10, "#7c8a84")
    rr((520, y + 34, 574, y + 88), 14, "#e4f4ee")
    text((539, y + 50), "2", f22, "#08745b")
    rr((610, y + 22, 1298, y + 48), 999, "#dfe7e3")
    d.rounded_rectangle((610, y + 22, 790, y + 48), radius=999, fill="#007A5A")
    d.rectangle((778, y + 22, 960, y + 48), fill="#256FD6")
    d.rounded_rectangle((948, y + 22, 1298, y + 48), radius=999, fill="#D99100")
    cards = [("0", "0%", "เสร็จแล้ว", "#007A5A"), ("1", "50%", "กำลังดำเนินการ", "#256FD6"), ("1", "50%", "เปิดงานใหม่", "#D99100")]
    cx = 610
    for n, pct, label2, color in cards:
        rr((cx, y + 62, cx + 200, y + 104), 12, "#ffffff", "#dce8e3")
        d.ellipse((cx + 14, y + 78, cx + 24, y + 88), fill=color)
        text((cx + 34, y + 70), n, f22)
        text((cx + 154, y + 75), pct, f12, "#8a9892")
        text((cx + 34, y + 94), label2, f10, "#6f7f78")
        cx += 218


main_row(330, "งานส่วนกลาง")
main_row(458, "งานลูกบ้าน")

# Incident cards
section(320, 620, 660, 300, "ภาพรวมตามประเภทของเหตุที่เกิดขึ้น", "สรุปหมวดปัญหาที่แจ้งเข้ามาในช่วงวันที่เลือก")
for i, (title, total, top, chips) in enumerate([
    ("รวมทั้งหมด", "4", "โครงสร้างอาคาร", ["โครงสร้างอาคาร 2", "ประปา 1", "ระบบความปลอดภัย 1"]),
    ("งานส่วนกลาง", "2", "โครงสร้างอาคาร", ["โครงสร้างอาคาร 1", "ระบบความปลอดภัย 1"]),
]):
    x = 344 + i * 310
    rr((x, 690, x + 286, 890), 16, "#ffffff", "#dce8e3")
    text((x + 18, 714), title, f16)
    rr((x + 222, 706, x + 268, 752), 14, "#e4f4ee")
    text((x + 239, 718), total, f22, "#08745b")
    rr((x + 18, 764, x + 268, 810), 12, "#f7fbf9", "#dce8e3")
    text((x + 36, 778), top, f13)
    rr((x + 18, 828, x + 268, 840), 999, "#dfe7e3")
    d.rounded_rectangle((x + 18, 828, x + 118, 840), radius=999, fill="#6B3FD4")
    d.rectangle((x + 118, 828, x + 178, 840), fill="#006FD6")
    d.rounded_rectangle((x + 178, 828, x + 268, 840), radius=999, fill="#25466F")
    cx = x + 18
    for chip in chips[:2]:
        cx = pill(cx, 852, chip, "#eef4ff", "#256fd6", f10)

# Announcements
section(1010, 620, 350, 300, "ประกาศ", "เอกสารและรูปภาพสำหรับทีมงาน")
for i, (title, color) in enumerate([("ประกาศปิดน้ำอาคาร A", "#397ccb"), ("ประชุมคณะกรรมการ", "#6b3fd4")]):
    y = 690 + i * 98
    rr((1034, y, 1336, y + 78), 12, "#fbfdfc", "#dce8e3")
    rr((1050, y + 14, 1118, y + 64), 8, color)
    text((1132, y + 16), title, f13)
    text((1132, y + 40), "คลิกเพื่อดูเอกสารหน้าแรก", f10, "#7c8a84")
    pill(1260, y + 36, "PDF", "#e6f4ef", "#08745b", f10)

img.save(out)
print(out.resolve())
