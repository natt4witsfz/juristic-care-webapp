# Housekeeping Routine Control Mockup — Specification v0.1

## วัตถุประสงค์

Functional Mockup นี้ใช้สาธิตวิธีที่นิติบุคคลติดตาม ตรวจ และอนุมัติงาน Routine ของบริษัทแม่บ้าน โดยเน้น Contract Position เป็นแกนหลักของ Board, แยกผู้ปฏิบัติงานจริงออกจากพนักงานตามสัญญา, รักษาประวัติตาม effective date และเก็บ revision/audit ของการตรวจรับ

Mockup ถูกแยกจาก Production ที่ route และ feature folder โดยเฉพาะ ใช้ข้อมูลสังเคราะห์ทั้งหมด และไม่เปลี่ยน authentication, permission, database schema หรือ workflow เดิม

## Scope ของ Mockup

- Daily Routine Board สำหรับ Contract Position HK-01 ถึง HK-10
- Check-in, Check-out, ผู้ปฏิบัติงานจริง และกรณีพนักงานทดแทน
- งาน Routine แยก instance ตามตำแหน่ง วันที่ และรอบเวลา
- สถานะ `not_due`, `not_started`, `in_progress`, `awaiting_inspection`, `approved`, `rejected`, `overdue`
- Inspection Drawer พร้อม Before/After, timestamp, revision history และ audit history
- อนุมัติ, ไม่อนุมัติ, validation เหตุผล, จำลองส่งแก้ไข และ Building Manager Reopen
- Inspection Queue พร้อม filter ตำแหน่ง พื้นที่ สถานะ และช่วงเวลา
- Employee & Position History ตาม effective date รวม scheduled assignment และ retroactive badge
- Daily Report Preview เวลา 20:00 และ mock storage result
- localStorage persistence และ Reset Demo Data
- Loading, empty และ error state ที่จำเป็นต่อ flow นี้

## สิ่งที่ยังไม่เชื่อม Production

- ไม่มีการเรียก Supabase client หรือ Production database
- ไม่มี table, view, RLS policy, Storage bucket หรือ migration ใหม่
- ไม่มีการอ่าน Production environment variable
- ไม่มีการเรียก Google Drive API, OAuth หรืออัปโหลดไฟล์จริง
- ไม่มีข้อมูลจริงของลูกบ้าน พนักงาน หรือผู้ตรวจ
- ไม่แก้ Production authentication หรือ permission matrix เดิม
- ไม่แก้ legacy Routine Daily Task ใน `app.js`

## Architecture

Feature อยู่ที่ `frontend/src/features/housekeeping_routine/` และ route composition อยู่ที่ `frontend/src/routes/router.tsx`

```text
HousekeepingRoutinePage / UI components
        │
        ▼
HousekeepingRoutineRepository (port)
        │
        ├── MockHousekeepingRoutineRepository (ใช้งานใน v0.1)
        └── SupabaseHousekeepingRoutineRepository (type seam, ยังไม่ implement)

DailyReportPreview
        │
        ▼
ReportStorageAdapter (port)
        │
        ├── MockReportStorageAdapter (ใช้งานใน v0.1)
        └── GoogleDriveReportStorageAdapter (อนาคต)
```

UI ไม่ import seed และไม่อ่าน localStorage โดยตรง ข้อมูลทั้งหมดผ่าน repository interface ส่วน mock seed รวมอยู่ใน `housekeeping_seed.ts` เพื่อแก้ DEMO DATA ได้จากจุดเดียว

## Domain model

### Contract Position

แถวหลักถาวรของ Board เช่น HK-03 อาคาร A ชั้น 2–10 ไม่เปลี่ยน identity เมื่อพนักงานเปลี่ยน

### Employee Profile

บุคคลจำลองที่มี employee id/code, ชื่อ, profile photo reference, contractor และ active status ชื่อทั้งหมดลงท้ายหรือระบุว่าเป็น DEMO

### Position Assignment

เชื่อมพนักงานกับ Contract Position ด้วย `effective_from`/`effective_to` และเก็บ document metadata, recorded time/actor, retroactive flag/reason แยกจาก current projection

### Daily Attendance

เก็บ contract employee และ actual employee ของวันนั้นแยกกัน พร้อม `regular`/`substitute`, เหตุผล และหลักฐาน Check-in/Check-out

### Routine Task Template

แม่แบบชื่อ จุดปฏิบัติงาน เวลาเริ่ม/สิ้นสุด และข้อกำหนด Before/After งานที่ชื่อเหมือนกันแต่คนละรอบใช้ template/instance แยกกัน

### Daily Task Instance

หนึ่ง instance ต่อ work date + position + template/round เก็บ schedule, status, submit/inspect decision, rejection reason และ revision number

### Evidence Revision และ Audit Entry

หลักฐานแต่ละ revision ถูก append และมี outcome ของตนเอง การ reject/resubmit ไม่ลบหลักฐานชุดเดิม การ approve/reject/reopen เพิ่ม audit entry พร้อม actor, role, timestamp, previous/current status และเหตุผล

## Status model

| Status                | ความหมาย                         | UI cue               |
| --------------------- | -------------------------------- | -------------------- |
| `not_due`             | ยังไม่ถึงเวลาหรือไม่มีงานรอบนั้น | เทา + ○ + label      |
| `not_started`         | ถึงเวลาแล้วแต่ไม่มี Before       | แดง + ! + label      |
| `in_progress`         | มี Before แต่ยังไม่ส่ง           | เหลือง + ◐ + label   |
| `awaiting_inspection` | ส่งแล้ว รอนิติตรวจ               | น้ำเงิน + ⌛ + label |
| `approved`            | ผู้มีสิทธิ์หนึ่งคนอนุมัติแล้ว    | เขียว + ✓ + label    |
| `rejected`            | ส่งกลับแก้ไข                     | ส้ม + ↩ + label      |
| `overdue`             | เกินเวลาและยังไม่ส่ง             | แดงเข้ม + ⚠ + label  |

สีไม่ใช่ตัวบอกสถานะเพียงอย่างเดียว ทุกสถานะมี icon, ภาษาไทย, English label/tooltip ตามบริบท

## Route

`/prototype/housekeeping-routine`

Route เป็น public prototype surface แยกจาก protected Production workspace และไม่มี navigation item ใน shell หลัก เพื่อลดโอกาสสับสนกับ Production feature การถอดออกทำได้ด้วยการลบ route declaration/import หนึ่งจุดและลบ feature folder

## วิธีรัน

ข้อกำหนดตาม repository: Node.js 22.12+ และ pnpm 11+

```bash
pnpm install --frozen-lockfile
pnpm dev
```

เปิด Local URL ที่ Vite แสดง แล้วต่อท้าย `/prototype/housekeeping-routine`

## วิธี Reset Demo Data

1. เปิด Mockup
2. กด `Reset Demo Data`
3. ยืนยัน `ยืนยัน Reset`
4. repository จะเขียน central seed กลับไปที่ localStorage key `o83.housekeeping_routine.mock.v0_1`

Reset กระทบเฉพาะข้อมูลจำลองของ feature นี้ ไม่แตะ localStorage key ของ production/legacy feature

## Permission และผู้ตรวจจำลอง

- Juristic Staff 4 คน
- Building Manager 1 คน
- ทุกคนมี mock permission `inspect_contractor_work`
- ผู้มีสิทธิ์คนแรกที่ approve/reject ถือว่าตัดสินจบ และ UI ปิดปุ่มตัดสินซ้ำ
- Reopen แสดงเฉพาะ Building Manager และบังคับเหตุผล
- Permission ใน v0.1 เป็นข้อมูลจำลองภายใน feature ไม่แก้ permission Production

## จุดที่ต้องเปลี่ยนเมื่อต่อ Supabase

1. Implement class ที่เป็น `HousekeepingRoutineRepository` แทน `MockHousekeepingRoutineRepository`
2. สร้าง purpose-specific queries/commands สำหรับ board, inspection, approve, reject, reopen, position history และ report
3. ใช้ private schema/exposed projection ตาม architecture; ทดสอบ RLS ทั้ง allow/deny และ tenant isolation
4. ใช้ server-side authoritative time, idempotency key และ concurrency guard เพื่อป้องกัน approve ซ้ำ
5. ย้าย Evidence metadata/file reference ไป Storage adapter โดยไม่ส่ง secret/service-role key ไป browser
6. เปลี่ยน composition root ของ page ให้ inject Supabase adapter โดย UI components เดิมไม่ต้องเปลี่ยน

ยังไม่มี Supabase implementation, SQL หรือ migration ใน v0.1

## จุดที่ต้องเปลี่ยนเมื่อต่อ Google Drive

1. Implement `GoogleDriveReportStorageAdapter` ตาม `ReportStorageAdapter`
2. ให้ backend/approved integration เป็นผู้ถือ OAuth credential ไม่เก็บ secret ใน browser
3. สร้าง file format, idempotent naming, retry, audit และ error/recovery policy
4. Inject adapter ใหม่เข้า `DailyReportPreview` หรือ report command เดิม

Path ตัวอย่างของ mock:

```text
O83_Care/Contractor_Reports/Housekeeping/YYYY/MM/
```

## DEMO DATA assumptions

- วันหลักคือ 18 กรกฎาคม 2026 และ snapshot operational board คือ 14:30 น.
- Historical example คือ 15 มิถุนายน 2026
- Report Preview ใช้ snapshot 20:00 น.
- HK-03: employee A มีผลถึง 30 มิ.ย., employee B มีผล 1–31 ก.ค., employee C กำหนดล่วงหน้าตั้งแต่ 1 ส.ค.
- HK-03 วันที่หลักมีพนักงานทดแทน และรูป Check-in อ้างอิงผู้ปฏิบัติงานจริง
- HK-05 มีตัวอย่าง retroactive assignment ที่ recorded date ช้ากว่า effective date
- HK-08 มีงานเก็บขยะเช้า/กลางวัน/เย็นเป็นคนละ task instance
- HK-09 มี revision history มากกว่าหนึ่งครั้ง
- ชื่อบริษัท บุคคล เอกสาร รูป และเวลาทั้งหมดเป็น DEMO DATA
- ภาพใน v0.1 เป็น visual placeholder ที่ติด watermark `DEMO PHOTO` ไม่ใช่ภาพบุคคลหรือสถานที่จริง

## Known limitations

- localStorage เป็น device-local state ไม่มี multi-user concurrency หรือ server authority
- เวลา approve/reject/reopen ใช้เวลาของ browser; Production ต้องใช้ server timestamp
- ภาพ evidence/check-in เป็น visual placeholder ไม่ใช่ binary upload
- ไม่มี offline sync/conflict resolution
- ไม่มี production role/mandate lookup; selector ใช้ทดสอบ behavior เท่านั้น
- ไม่มี export PDF/CSV หรือ scheduled job 20:00 จริง
- ไม่มี Google Drive preview URL จริง
- Modern React frontend ยังไม่มี shared Thai/English i18n service; feature ใช้ข้อความไทยพร้อม English operational labels โดยไม่เพิ่ม dependency
- Route ตั้งใจไม่เพิ่มใน Production navigation; ต้องเปิดด้วย URL โดยตรง

## Verification targets

- Unit: status transitions, rejection validation, duplicate approval guard, manager reopen, effective date และ retroactive audit
- Component: Board อัปเดตหลัง approve/reject และ Reset Demo Data
- Browser: Board, Drawer, Reject flow, Position History, Report Preview, refresh persistence และ historical date
