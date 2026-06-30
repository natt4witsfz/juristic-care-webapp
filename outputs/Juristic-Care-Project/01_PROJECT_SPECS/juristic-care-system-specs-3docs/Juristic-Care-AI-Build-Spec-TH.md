# Juristic Care WebApp — Prompt อธิบายระบบสำหรับให้ AI ตัวอื่นสร้างระบบเดียวกัน

ให้สร้าง WebApp ชื่อ Juristic Care สำหรับบริหารจัดการนิติบุคคลอาคารชุด ใช้รับแจ้งปัญหา ติดตามงาน มอบหมายงาน จัดการลูกบ้าน ทีมงาน สิทธิ์ผู้ใช้ ประกาศ งบการเงิน ปฏิทิน และรายงาน โดย UX/UI อ้างอิงแนวคิดระบบรับแจ้งปัญหาเมือง เช่น Traffy Fondue แต่ปรับให้เหมาะกับอาคารชุด

## เป้าหมาย

สร้าง WebApp สองภาษา ไทย/อังกฤษ โดยภาษาเริ่มต้นเป็นภาษาไทย ผู้ใช้สามารถสลับเป็นภาษาอังกฤษได้ ระบบต้องรองรับ Desktop และ Mobile โดย Detect อุปกรณ์และแสดง layout ที่เหมาะสม

## กลุ่มผู้ใช้

มีผู้ใช้ 4 กลุ่ม:

1. Admin
2. Co-Admin
3. Staff
4. Resident

Admin เข้าถึงทุกอย่างเสมอ Co-Admin ได้สิทธิ์จาก Admin เท่านั้น Staff ได้สิทธิ์ตามแผนกและ Permission Center Resident เห็นเฉพาะภาพรวม งานส่วนกลาง ห้องของฉัน ปฏิทิน งบการเงิน ตามสิทธิ์ที่ Admin เปิดให้

## Login

ทำหน้า Login ให้กรอก:

- เลขห้อง / Staff ID / Admin ID
- รหัสผ่าน
- First-time access / ตั้งรหัสผ่าน
- ปุ่มสลับภาษา

Demo users:

- ADMIN / 1234
- STAFF-01 / 1234
- STAFF-02 / 1234
- A-0201 / 1234

## Sidebar

ระบบมี Sidebar:

- ภาพรวม
- งานส่วนกลาง
- งานของลูกบ้าน
- งบการเงิน
- ปฏิทิน
- Pool งานกลาง
- งานของทีมนิติ
- งานของฉัน
- งานช่างอาคาร
- งานแม่บ้าน
- ห้องของฉัน
- ทีมงาน
- ลูกบ้าน
- Organization Chart
- ประกาศ
- สิทธิ์การใช้งาน
- Staff Log
- Admin Log

เมนูที่แสดงขึ้นอยู่กับสิทธิ์ผู้ใช้

## Permission Center

สร้างหน้า Permission Center เฉพาะ Admin/Co-Admin ที่มีสิทธิ์

ต้องมีสองส่วน:

1. สิทธิ์รายบุคคล
2. สิทธิ์แบบกลุ่ม Bulk Permission

### สิทธิ์รายบุคคล

แสดงรายชื่อผู้ใช้ ค้นหาชื่อ/ชื่อเล่น/รหัส/เลขห้องได้ Filter ตามแผนกได้

แต่ละคนมี checkbox:

Sidebar access:

- dashboard
- commonWork
- residentWork
- finance
- calendar
- pool
- juristicTeam
- myjobs
- technicianJobs
- housekeepingJobs
- roomjobs
- team
- residents
- organization
- backhouse
- staffLogs
- permissions

Action authority:

- assignL1
- assignL2
- createJob
- manageTeam
- manageResidents
- manageAnnouncements
- manageOrganization
- importExport
- viewStaffLog
- managePermissions

ต้องกด Save permissions ก่อนจึงมีผล และต้องบันทึก Admin Log

### Bulk Permission

มี dropdown เลือกกลุ่ม:

- ลูกบ้านทั้งหมด
- คณะกรรมการ
- เจ้าหน้าที่นิติบุคคล
- เจ้าหน้าที่ช่างอาคาร
- แม่บ้าน
- รปภ.
- คนสวน
- ผู้รับเหมา
- ทีมงานทั้งหมด

มี dropdown เลือก Preset:

- สิทธิ์ลูกบ้านมาตรฐาน
- สิทธิ์ทีมงานพื้นฐาน
- สิทธิ์เจ้าหน้าที่นิติ
- สิทธิ์ช่างอาคาร
- สิทธิ์คณะกรรมการดูภาพรวม
- ปิดสิทธิ์ทั้งหมด

Preset ลูกบ้านมาตรฐานต้องเปิด Sidebar:

- ภาพรวม
- งานส่วนกลาง
- ห้องของฉัน
- ปฏิทิน
- งบการเงิน

และไม่เปิด Action authority ใด ๆ

ต้องมี Preview จำนวนบัญชีที่จะได้รับผล และปุ่ม Apply to group เมื่อกดต้องอัปเดตสิทธิ์ทุกคนในกลุ่มและบันทึก Admin Log

## ระบบรับแจ้งงาน

งานเข้าระบบจาก:

1. Google Form
2. สร้างงานใหม่ใน WebApp
3. ระบบสร้างงานอัตโนมัติ

งานจาก Google Form ต้องเข้า Pool กลางแบบดิบ ยังไม่แบ่งประเภท ไม่มีผู้รับผิดชอบ และสถานะเริ่มต้นคือ “เปิดงาน”

ผู้มีสิทธิ์มอบหมายเท่านั้นจึงจะคัดแยกและมอบหมายงานได้

## ประเภทงาน

ประเภทหลัก:

- งานส่วนกลาง
- งานลูกบ้าน

ประเภทรอง:

- ประปา
- ไฟฟ้า
- ความสะอาด
- โครงสร้างอาคาร
- ลิฟต์
- สวน
- เฟอร์นิเจอร์
- ระบบความปลอดภัย
- อินเตอร์เน็ต

## สถานะงาน

สถานะ:

- เปิดงาน
- รับเรื่อง
- รอตรวจสอบ
- ตรวจสอบแล้วรอแก้ไข/อะไหล่
- แก้ไขสมบูรณ์แล้วเรียบร้อยแล้ว
- แก้ไขแล้ว รอติดตาม
- แก้ไขเบื้องต้น รออะไหล่/ผู้รับเหมา
- ช่างแจ้งเสร็จแล้ว รอตรวจสอบ
- ปฏิเสธงาน

กฎ:

- ทุกสถานะยกเว้น รับเรื่อง และ ปฏิเสธงาน ต้องแนบรูปขั้นต่ำ 1 รูป สูงสุด 3 รูป
- รูปภาพต้องมีชื่อผู้แนบและ timestamp
- ถ้าเลือก แก้ไขแล้ว รอติดตาม ต้องเลือกวันที่ติดตามครั้งถัดไป
- ถ้าเลือก แก้ไขเบื้องต้น รออะไหล่/ผู้รับเหมา ต้องเลือกวันที่ติดตามครั้งถัดไป

## SLA / Due Date

ทุกงานมี dueDate

ถ้าไม่ระบุ:

- priority normal = due ใน 7 วัน
- priority high = due ใน 3 วัน
- priority urgent = due ใน 1 วัน

แสดง badge:

- เหลือ X วัน
- ครบกำหนดวันนี้
- เกินกำหนด X วัน

Notification bell ต้องแจ้งเตือน:

- งานใหม่รอมอบหมาย
- งานใกล้ครบกำหนด
- งานครบกำหนดวันนี้
- งานเกินกำหนด
- งานถึงวันติดตาม
- งานมีเวลาซ้อน
- งานรอตรวจสอบปิดงาน

## Timeline

ทุกงานมี Timeline แสดงลำดับกิจกรรม:

- สร้างงาน
- มอบหมายงาน
- รับเรื่อง
- อัปเดตสถานะ
- แนบรูป
- ติดตามงาน
- ยืนยันปิดงาน

Timeline แต่ละรายการมี:

- เวลา
- ผู้ดำเนินการ
- Action
- สถานะ
- ข้อความ
- รูปภาพแนบ

## Export งาน

ในหน้ารายละเอียดงานต้องมี:

- Export CSV
- Export PDF

CSV รวม:

- ข้อมูลงานทั้งหมด
- สถานะล่าสุด
- dueDate
- due status
- ผู้แจ้ง
- ผู้รับผิดชอบ
- timeline
- จำนวนรูปแนบ
- reference รูปแนบ

PDF ให้สร้าง HTML report ที่มีข้อมูลครบและรูปภาพตาม timeline แล้วใช้ `window.print()` เพื่อ Save as PDF

## Dashboard

หน้า Dashboard ต้องมี:

- สรุปงานตามสถานะ
- ภาพรวมตามประเภทหลัก งานส่วนกลาง/งานลูกบ้าน
- ภาพรวมตามประเภทของเหตุที่เกิดขึ้น
- ประกาศ
- Organization Chart ทีมบริหารโครงการ

กราฟประเภทหลักแสดงเป็นแท่งแนวนอน แยก:

- งานส่วนกลาง
- งานลูกบ้าน

แบ่งสถานะ:

- เสร็จแล้ว
- กำลังดำเนินการ
- เปิดงานใหม่

Filter:

- วันนี้
- ย้อนหลัง 7 วัน
- ย้อนหลัง 30 วัน

## Trello Board

เพิ่มกระดาน Trello-style ใน Sidebar:

- งานส่วนกลาง
- งานของฉัน
- งานของลูกบ้าน
- งานช่างอาคาร
- งานแม่บ้าน
- งานของทีมนิติ

กระดานแบ่งคอลัมน์ตามสถานะงาน

Filter ช่วงเวลา:

- 1 วัน
- 7 วันย้อนหลัง
- 30 วันย้อนหลัง
- ทั้งหมด

Filter ของ Trello board ต้องไม่กระทบรายการงานด้านล่าง

## ลูกบ้าน

มีหน้า Residents เฉพาะผู้มีสิทธิ์

รองรับสูงสุด 882 ห้อง

ข้อมูลห้อง:

- room_id
- login_id
- password
- room_no_1
- room_no_2
- building
- common_fee_status
- owner
- occupants
- cars

เจ้าของร่วมมีได้ 1 คน ผู้เช่า/ผู้อยู่อาศัยเพิ่มได้หลายคน

เลือก checkbox ได้ว่าใครเป็นผู้อยู่อาศัยปัจจุบัน

ลากเรียงลำดับคนเพื่อกำหนดคนที่แสดงเป็นผู้อยู่อาศัยหลัก

รถแต่ละคันมี:

- prefix
- number
- province
- brand
- model
- color

Export/Import ลูกบ้านใช้ Wide CSV:

- occupant_1_first_name
- occupant_1_last_name
- occupant_1_phone
- car_1_prefix
- car_1_number
- car_1_brand

ไม่ควรรวม occupants/cars ไว้ใน cell เดียว

## ทีมงาน

หน้า Team เฉพาะ Admin/Co-Admin ที่มีสิทธิ์

แก้ไข:

- ชื่อ
- นามสกุล
- ชื่อเล่น
- ตำแหน่ง
- แผนก
- รูปโปรไฟล์
- สิทธิ์ L1/L2

Admin เห็น ID/password ได้

Co-Admin ไม่เห็น ID/password

ต้องกดบันทึกก่อนทุกครั้ง

การแก้ไขต้องเข้า Admin Log

## Organization Chart

เฉพาะผู้มีสิทธิ์

แสดงผู้ใช้จากแผนก:

- คณะกรรมการ
- นิติบุคคล
- ช่างอาคาร

ลาก Profile ไปใส่ Slot

Slot เพิ่มตามจำนวนผู้ได้รับแต่งตั้งจริง

ต้องกดบันทึกก่อนแสดงใน Dashboard

## ประกาศ

หน้า Announcements:

- Upload PDF/Image
- ตั้งหัวข้อ
- คำอธิบายสั้น
- เรียงลำดับ
- ลบ
- แสดงหน้าแรกบน Dashboard
- เปิด Popup ใหญ่
- ปุ่ม Download
- ปุ่ม Next/Back

PDF เดิมที่ไม่เก็บไฟล์จริงต้องแจ้งให้อัปโหลดใหม่

## Logs

Admin Log:

- Admin/Co-Admin login
- เปลี่ยนสิทธิ์
- Bulk permission
- แก้ไขทีมงาน
- แก้ไขลูกบ้าน
- Import/Export
- จัดการประกาศ
- จัด Organization

Staff Log:

- Staff login
- รับงาน
- อัปเดตงาน
- แนบรูป
- ปิดงาน

Log ไม่ควรลบผ่าน UI

## Technical guidance

ถ้าทำเป็น MVP Static:

- HTML
- CSS
- Vanilla JS
- LocalStorage
- Optional Apps Script sync

ถ้าทำ Production:

- Supabase หรือ Firebase
- Auth จริง
- Database จริง
- Object Storage สำหรับรูป/PDF
- Row Level Security / Security Rules
- Audit Log แบบ append-only

ต้องออกแบบ data model แยก:

- users
- resident_rooms
- resident_people
- resident_cars
- jobs
- job_timeline
- job_attachments
- permissions
- announcements
- logs
- finance
- calendar

ให้สร้างระบบโดยคำนึงถึง UX ที่ใช้งานง่ายสำหรับเจ้าหน้าที่ที่ไม่ใช่ IT
