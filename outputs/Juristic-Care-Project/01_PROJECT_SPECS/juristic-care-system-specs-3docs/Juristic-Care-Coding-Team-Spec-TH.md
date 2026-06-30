# Juristic Care WebApp — เอกสารสเปกระบบสำหรับทีม Coding

เอกสารฉบับนี้อธิบายระบบ WebApp บริหารจัดการนิติบุคคลอาคารชุดสำหรับรับแจ้งปัญหา ติดตามงาน มอบหมายงาน จัดการลูกบ้าน ทีมงาน สิทธิ์การเข้าถึง ประกาศ งบการเงิน ปฏิทิน และรายงาน โดยมีเป้าหมายให้ทีม Coding สามารถนำไปพัฒนาต่อเป็นระบบ Production ได้

## 1. ภาพรวมระบบ

Juristic Care เป็น WebApp สำหรับนิติบุคคลอาคารชุด ใช้เป็นศูนย์กลางรับแจ้งปัญหาจากลูกบ้านผ่าน Google Form หรือสร้างงานโดยเจ้าหน้าที่ในระบบ แล้วส่งงานเข้าสู่ Pool กลางเพื่อคัดแยกประเภท มอบหมายผู้รับผิดชอบ ติดตามสถานะ แนบรูปภาพ และออกรายงาน

ระบบรองรับผู้ใช้งานหลัก 4 กลุ่ม:

1. Admin
2. Co-Admin
3. Staff / ทีมงาน / ช่าง / แม่บ้าน / รปภ. / ผู้รับเหมา / คณะกรรมการ
4. Resident / ลูกบ้าน

ระบบต้องรองรับสองภาษา โดยค่าเริ่มต้นเป็นภาษาไทย และสามารถสลับเป็นภาษาอังกฤษได้

## 2. บทบาทผู้ใช้งาน

### 2.1 Admin

Admin เป็นผู้มีสิทธิ์สูงสุด เข้าถึงได้ทุกหน้าและทุกฟังก์ชันเสมอ เพื่อป้องกันการล็อกตัวเองออกจากระบบ

สิทธิ์หลัก:

- เห็น Sidebar ทุกหน้า
- จัดการทีมงาน
- จัดการลูกบ้าน
- จัดการ Organization Chart
- จัดการประกาศ
- จัดการ Permission Center
- ดู Admin Log
- ดู Staff Log
- Export / Import CSV
- สร้างงาน / มอบหมายงาน / แก้ไขงาน / ติดตามงาน
- เห็น ID และ Password ของทีมงาน
- Export รายชื่อทีมงานและลูกบ้าน

ทุกครั้งที่ Admin เข้าระบบหรือแก้ไขข้อมูลสำคัญ ต้องบันทึกเข้า Admin Log และไม่ควรมีปุ่มลบ Log ผ่านหน้า WebApp

### 2.2 Co-Admin

Co-Admin เป็นสิทธิ์ที่ Admin มอบหมายเท่านั้น Co-Admin มีสิทธิ์จัดการบางส่วนตามที่ Admin เปิดให้ใน Permission Center

ข้อจำกัด:

- ไม่เห็น ID และ Password ของทีมงาน
- ถ้าลบผู้ใช้งาน ระบบต้องสร้างงานส่งให้ Admin ตรวจสอบและยืนยันก่อน
- การเปลี่ยนแปลงข้อมูลของ Co-Admin ต้องบันทึกเข้า Admin Log

### 2.3 Staff

Staff คือทีมงานภายใน เช่น เจ้าหน้าที่นิติบุคคล ช่าง แม่บ้าน รปภ. คนสวน ผู้รับเหมา

ข้อมูล Staff ต้องประกอบด้วย:

- ID / Login ID
- Password
- ชื่อ
- นามสกุล
- ชื่อเล่น
- ตำแหน่ง
- แผนก
- รูปโปรไฟล์
- สิทธิ์มอบหมายงาน L1 / L2
- สิทธิ์เข้าถึง Sidebar
- สิทธิ์ Action Authority

### 2.4 Resident

ลูกบ้านเข้าระบบด้วยเลขห้องและรหัสผ่าน เพื่อดู:

- ภาพรวม
- งานส่วนกลาง
- ห้องของฉัน
- ปฏิทิน
- งบการเงิน ถ้า Admin เปิดสิทธิ์ให้

ลูกบ้านไม่เห็น Pool งานกลาง ไม่เห็นหน้าทีมงาน ไม่เห็น Admin Log/Staff Log และไม่ควรเห็นคำว่า “งานของฉัน” ในมุมมองลูกบ้าน แต่ใช้คำว่า “ภาพรวม” และ “ห้องของฉัน”

## 3. ระบบ Login

หน้า Login ต้องรองรับ:

- กรอกเลขห้อง / Staff ID / Admin ID
- กรอกรหัสผ่าน
- First-time access / ตั้งรหัสผ่าน
- สลับภาษาไทย/อังกฤษ

ตัวอย่าง Demo:

- Admin: `ADMIN / 1234`
- Staff: `STAFF-01 / 1234`
- Resident: `A-0201 / 1234`

Production ควรใช้ระบบ Auth จริง เช่น Supabase Auth, Firebase Auth หรือระบบ Backend Auth แยกต่างหาก

## 4. โครงสร้าง Sidebar

Sidebar หลักประกอบด้วย:

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

การแสดง Sidebar ต้องขึ้นอยู่กับสิทธิ์ของผู้ใช้ โดย Admin เข้าถึงทุกอย่างเสมอ ส่วนผู้ใช้อื่นใช้ Permission Center ควบคุม

## 5. Permission Center

Permission Center เป็นหน้าสำหรับ Admin/Co-Admin ที่ได้รับสิทธิ์ ใช้เปิด/ปิดสิทธิ์รายบุคคลและสิทธิ์แบบกลุ่ม

### 5.1 Sidebar Access

กำหนดว่าผู้ใช้เห็นเมนูใดบ้าง เช่น:

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

### 5.2 Action Authority

กำหนดอำนาจการทำงาน:

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

### 5.3 Bulk Permission

ระบบต้องมีการกำหนดสิทธิ์แบบกลุ่มเพื่อลดการแก้ไขทีละคน

กลุ่มตัวอย่าง:

- ลูกบ้านทั้งหมด
- คณะกรรมการ
- เจ้าหน้าที่นิติบุคคล
- เจ้าหน้าที่ช่างอาคาร
- แม่บ้าน
- รปภ.
- คนสวน
- ผู้รับเหมา
- ทีมงานทั้งหมด

Preset ตัวอย่าง:

#### Resident Standard

Sidebar:

- ภาพรวม
- งานส่วนกลาง
- ห้องของฉัน
- ปฏิทิน
- งบการเงิน

Actions:

- ไม่มี

#### Staff Basic

Sidebar:

- ภาพรวม
- งานส่วนกลาง
- งานของฉัน
- ปฏิทิน

Actions:

- สร้างงานใหม่

#### Juristic Operator

Sidebar:

- ภาพรวม
- งานส่วนกลาง
- งานของลูกบ้าน
- งบการเงิน
- ปฏิทิน
- Pool งานกลาง
- งานของทีมนิติ
- งานของฉัน
- ลูกบ้าน
- ประกาศ

Actions:

- assignL1
- createJob
- manageResidents
- manageAnnouncements
- importExport

เมื่อ Apply สิทธิ์แบบกลุ่ม ต้อง:

- แสดง Preview จำนวนบัญชีที่ได้รับผล
- แสดงรายการสิทธิ์ที่จะเปิด
- บันทึก Admin Log
- อัปเดตสิทธิ์ของผู้ใช้ทุกคนในกลุ่ม

## 6. ระบบงานและ Pool กลาง

### 6.1 แหล่งที่มาของงาน

งานเข้าสู่ระบบได้จาก:

1. Google Form
2. เจ้าหน้าที่สร้างใน WebApp
3. ระบบสร้างอัตโนมัติ เช่น คำขอลบผู้ใช้จาก Co-Admin

### 6.2 Pool งานกลาง

งานจาก Google Form ต้องเข้า Pool กลางแบบดิบ โดยยังไม่มี Category หรือผู้รับผิดชอบ

งานใน Pool ต้องมีสถานะเริ่มต้น:

- เปิดงาน

ผู้มีสิทธิ์มอบหมายงานเท่านั้นที่สามารถคัดแยกและมอบหมายงานได้

### 6.3 ประเภทงาน

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

### 6.4 การแสดงงานตามประเภทหลัก

ถ้าเป็นงานส่วนกลาง:

- แสดงใน Sidebar งานส่วนกลาง
- แสดงในแผนกของผู้ได้รับมอบหมาย
- แสดงในงานของฉันของผู้ได้รับมอบหมาย

ถ้าเป็นงานลูกบ้าน:

- แสดงในแผนกของผู้ได้รับมอบหมาย
- แสดงในงานของฉันของผู้ได้รับมอบหมาย
- ในภาพรวมให้แสดงเป็นตัวเลขสถิติ ไม่เปิดเผยละเอียดทุกเคส เว้นแต่งานที่ลูกบ้านเลือกเปิดเผย

## 7. สถานะงาน

สถานะหลัก:

1. เปิดงาน
2. รับเรื่อง
3. รอตรวจสอบ
4. ตรวจสอบแล้วรอแก้ไข/อะไหล่
5. แก้ไขสมบูรณ์แล้วเรียบร้อยแล้ว
6. แก้ไขแล้ว รอติดตาม
7. แก้ไขเบื้องต้น รออะไหล่/ผู้รับเหมา
8. ช่างแจ้งเสร็จแล้ว รอตรวจสอบ
9. ปฏิเสธงาน

กฎแนบรูป:

- ทุกสถานะยกเว้น “รับงาน/รับเรื่อง” และ “ปฏิเสธงาน” ต้องแนบรูปขั้นต่ำ 1 รูป สูงสุด 3 รูป
- รูปที่แนบต้องมีชื่อผู้ใช้งานและ Timestamp
- ผู้ใช้สามารถเลือกถ่ายรูปหรือแนบรูปจากเครื่องได้

กฎวันที่ติดตาม:

- ถ้าเลือก “แก้ไขแล้ว รอติดตาม” ต้องใส่วันที่ติดตามครั้งถัดไป
- ถ้าเลือก “แก้ไขเบื้องต้น รออะไหล่/ผู้รับเหมา” ต้องใส่วันที่ติดตามครั้งถัดไป

## 8. SLA / Due Date / Notification

งานต้องมีวันครบกำหนด `dueDate`

ถ้าไม่ระบุ ระบบกำหนดค่าเริ่มต้นจาก Priority:

- ปกติ = 7 วัน
- เร่งด่วน = 3 วัน
- ฉุกเฉิน = 1 วัน

ระบบต้องแสดง Badge:

- เหลือ X วัน
- ครบกำหนดวันนี้
- เกินกำหนด X วัน

ระบบ Notification ต้องแจ้ง:

- งานใหม่รอมอบหมาย
- งานใกล้ครบกำหนด
- งานครบกำหนดวันนี้
- งานเกินกำหนด
- งานถึงวันติดตาม
- งานมีเวลาซ้อน
- งานรอตรวจสอบปิดงาน

## 9. Timeline งาน

ทุกงานต้องมี Timeline

Timeline แต่ละรายการควรมี:

- id
- at
- by
- byName
- action
- fromStatus
- toStatus
- message
- data
- attachments

Timeline ต้องเก็บ:

- การสร้างงาน
- การมอบหมายงาน
- การเปลี่ยนสถานะ
- การแนบรูป
- การยืนยันปิดงาน
- การแก้ไขข้อมูลสำคัญ

## 10. Export งาน

### 10.1 Export CSV รายงานงาน

CSV ต้องรวม:

- job_id
- title
- source
- status
- main_category
- sub_category
- priority
- room
- building
- floor
- contact_name
- contact_phone
- reporter
- assignee
- assigned_by
- job_date
- due_date
- due_status
- next_update_date
- description
- timeline_at
- timeline_by
- timeline_action
- timeline_status
- timeline_message
- attachment_count
- attachment_refs

### 10.2 Export PDF รายงานงาน

PDF ควรมี:

- หัวรายงาน
- สถานะงาน
- Due date
- รายละเอียดสถานที่
- ผู้แจ้ง
- ผู้รับผิดชอบ
- รายละเอียดปัญหา
- Timeline
- รูปภาพแนบตาม Timeline

สำหรับ Static WebApp สามารถทำเป็น HTML Report แล้วเรียก `window.print()` เพื่อ Save as PDF ได้

## 11. ระบบลูกบ้าน

จำนวนห้องสูงสุด 882 ห้อง

ข้อมูลห้อง:

- room_id
- login_id
- password
- room_no_1
- room_no_2
- building
- common_fee_status
- primary_person_key
- owner_first_name
- owner_last_name
- owner_nickname
- owner_phone
- owner_is_current
- occupants
- cars

ระบบลูกบ้านต้องรองรับ:

- เจ้าของร่วม 1 คน
- ผู้เช่า/ผู้อยู่อาศัยเพิ่มได้เรื่อย ๆ
- เลือกได้ว่าใครเป็นผู้อยู่อาศัยปัจจุบัน
- ลาก/จัดลำดับผู้พักอาศัยเพื่อกำหนดคนที่แสดงเป็นผู้อยู่อาศัยหลัก
- รถหลายคันต่อห้อง

ทะเบียนรถต้องมี:

- prefix
- number
- province
- brand
- model
- color

Export ลูกบ้านควรเป็น Wide CSV ไม่ควรรวม occupants/cars ไว้ใน cell เดียว

ตัวอย่าง column:

- occupant_1_first_name
- occupant_1_last_name
- occupant_1_phone
- car_1_prefix
- car_1_number
- car_1_brand

Import ต้องรองรับทั้งรูปแบบใหม่แบบ wide และรูปแบบเก่าที่รวม occupants/cars ในช่องเดียว

## 12. ระบบทีมงาน

ข้อมูลทีมงาน:

- id
- password
- first_name
- last_name
- nickname
- position
- department
- role
- co_admin
- assign_l1
- assign_l2
- room_or_staff_code
- profile_image

Admin เห็น ID/Password ได้

Co-Admin ไม่เห็น ID/Password ของทีมงาน

การแก้ไขข้อมูลต้องกดปุ่มบันทึกก่อนทุกครั้ง

ทุกการเปลี่ยนแปลงต้องเข้า Admin Log

## 13. Organization Chart

เฉพาะ Admin/Co-Admin ที่มีสิทธิ์

แสดงเฉพาะผู้ใช้ในแผนก:

- คณะกรรมการ
- เจ้าหน้าที่นิติบุคคล
- เจ้าหน้าที่ช่างอาคาร

ต้องลาก Profile ไปใส่ Organization Slots

Slot ต้องเพิ่มตามจำนวนทีมงานที่ได้รับการแต่งตั้ง

ต้องมี:

- ปุ่มบันทึก
- ปุ่มล้างโปรไฟล์

หน้า Dashboard ต้องแสดง Organization Chart ที่บันทึกแล้วเท่านั้น

## 14. ประกาศ

Sidebar ชื่อ “ประกาศ”

Admin/Co-Admin ที่มีสิทธิ์สามารถ:

- อัปโหลดรูปภาพ
- อัปโหลด PDF
- ตั้งหัวข้อ
- ตั้งคำอธิบายย่อ
- เรียงประกาศ
- ลบประกาศ

ใน Dashboard ต้องแสดงหน้าแรกของเอกสารหรือรูปภาพเสมอ

เมื่อกดดู:

- เปิด Popup ขนาดใหญ่
- มีปุ่มปิด
- มีปุ่มดาวน์โหลด
- มีปุ่มถัดไป/ย้อนกลับถ้ามีหลายหน้า

PDF เดิมที่ไม่ได้เก็บไฟล์ต้นฉบับต้องแจ้งให้อัปโหลดใหม่ ไม่ควรแสดงปุ่มดาวน์โหลดหลอก

## 15. งบการเงิน

หน้า Finance เป็น Dashboard สำหรับรายรับ รายจ่าย ค้างชำระ เงินสำรอง และรายงาน

ควรรองรับ:

- Import CSV
- Export Report
- แสดงสรุปตัวเลข
- เปิดสิทธิ์ให้ลูกบ้านดูได้ผ่าน Permission Center

## 16. ปฏิทิน

หน้า Calendar แสดงกิจกรรมของนิติบุคคล และเตรียมเชื่อมต่อ Google Calendar

ต้องรองรับ:

- รายการกิจกรรมตามวัน
- รายละเอียดกิจกรรม
- ดาวน์โหลด `.ics`
- สถานะเชื่อมต่อ Google Calendar

## 17. Log

### 17.1 Admin Log

บันทึกกิจกรรม Admin และ Co-Admin:

- Login
- เปลี่ยนสิทธิ์
- แก้ไขทีมงาน
- แก้ไขลูกบ้าน
- Import/Export
- จัดการประกาศ
- จัด Organization Chart

Admin Log ต้องไม่มีปุ่มลบผ่าน UI

### 17.2 Staff Log

บันทึกกิจกรรมของทีมงาน:

- Login
- รับงาน
- อัปเดตสถานะ
- แนบรูป
- ปิดงาน

## 18. Responsive Design

ระบบต้อง Detect อุปกรณ์:

- Desktop
- Mobile

Desktop ใช้ Sidebar เต็ม

Mobile ใช้ Bottom Navigation และ FAB สร้างงาน

ระบบต้องไม่ใช่แค่ responsive CSS แต่ต้องปรับ UX ให้เหมาะกับหน้าจอ เช่น ลดจำนวนข้อมูลในแถว ปรับ card layout และใช้ popup bottom sheet ในมือถือ

## 19. Data Model แนะนำสำหรับ Production

ตารางหลัก:

- users
- resident_rooms
- resident_people
- resident_cars
- jobs
- job_timeline
- job_attachments
- announcements
- permissions
- permission_presets
- admin_logs
- staff_logs
- calendar_events
- finance_reports

ไฟล์รูปภาพ/PDF ควรเก็บใน Object Storage เช่น Supabase Storage หรือ Firebase Storage แล้วเก็บ URL ใน database

## 20. คำแนะนำ Deploy

### Google Sheet + Apps Script

เหมาะกับ Pilot / MVP

ข้อจำกัด:

- สิทธิ์และ Security จำกัด
- จัดการไฟล์รูป/PDF ยาก
- Query และ concurrent users ไม่แข็งแรง
- Audit log ป้องกันแก้ไขยาก

### Supabase

เหมาะกับระบบจริงมากกว่า

ข้อดี:

- PostgreSQL
- Auth
- Row Level Security
- Storage
- Realtime
- SQL report

### Firebase

เหมาะกับ realtime และ mobile-like app

ข้อดี:

- Auth ดี
- Firestore realtime
- Storage ดี
- Hosting ง่าย

ข้อควรระวัง:

- Query report ซับซ้อนกว่า SQL
- Data model ต้องออกแบบ denormalization ดี

## 21. Acceptance Criteria

ระบบถือว่าผ่านเมื่อ:

- Admin เข้าได้ทุกหน้า
- Co-Admin ถูกมอบสิทธิ์ได้
- ลูกบ้านเห็นเฉพาะเมนูที่กำหนด
- Bulk Permission ใช้กับกลุ่มลูกบ้านได้จริง
- Google Form job เข้า Pool สถานะเปิดงาน
- มอบหมายงานแล้วไปแสดงในงานของผู้รับผิดชอบ
- งานมี Due date และแจ้งเตือนเมื่อใกล้/เกินกำหนด
- อัปเดตสถานะพร้อมแนบรูปตามกฎ
- Export CSV/PDF งานได้
- Export/Import ลูกบ้านแบบ wide CSV ได้
- Admin Log บันทึกการเปลี่ยนแปลงสำคัญ
- ระบบสลับภาษาไทย/อังกฤษได้ครบ
