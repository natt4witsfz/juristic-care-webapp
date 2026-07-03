# O83 Care - State Engine

Version: 1.0

---

# Purpose

State Engine คือกลไกที่ใช้สรุปสถานะปัจจุบันของ Case โดยอัตโนมัติ

ผู้ใช้ไม่ควรต้องเลือกสถานะเองซ้ำซ้อน

ผู้ใช้มีหน้าที่บันทึกข้อเท็จจริง

ระบบมีหน้าที่สรุปสถานะ

---

# Core Principle

Users record Facts.

The system derives State.

ภาษาไทย:

ผู้ใช้บันทึกข้อเท็จจริง

ระบบสรุปสถานะ

---

# Why This Matters

O83 Care ไม่ควรบังคับให้ผู้ใช้ทำงานซ้ำสองครั้ง

ตัวอย่างที่ไม่ควรเกิดขึ้น:

1. ช่างบันทึกว่าตรวจแล้วพบรอยร้าว
2. ช่างแนบรูป
3. ช่างใส่หมายเหตุ
4. แล้วต้องมาเลือกสถานะเองอีกว่า "รอสั่งซื้อวัสดุ"

แบบนี้เป็นภาระซ้ำซ้อน

ระบบควรอ่านจาก Fact ที่เกิดขึ้น แล้วสรุป State ให้อัตโนมัติ

---

# Case State

Case State คือสถานะปัจจุบันที่ระบบคำนวณจากข้อมูลล่าสุดของ Case

State ไม่ใช่สิ่งที่ผู้ใช้เลือกเองโดยตรง

---

# Fact

Fact คือข้อเท็จจริงที่เกิดขึ้นใน Case

ตัวอย่าง Fact:

- Case Created
- Inspection Submitted
- Evidence Uploaded
- Decision Made
- Approval Requested
- Approval Granted
- Procurement Required
- Procurement Completed
- Work Completed
- Verification Passed
- Verification Failed
- Resident Informed
- Follow Up Required
- Follow Up Completed
- Case Closed

---

# State Engine Flow

Case

↓

Facts

↓

State Engine

↓

Current Snapshot

↓

Home Command Center

---

# Current Snapshot

State Engine ต้องสร้าง Current Snapshot ให้ Case เสมอ

Current Snapshot ต้องตอบได้ว่า:

- Case อยู่ขั้นตอนไหน
- ตอนนี้ใครเป็นเจ้าของ
- ต้องทำอะไรต่อ
- รออะไรอยู่
- ครบกำหนดเมื่อไร
- มีความเสี่ยงระดับไหน
- ปิด Case ได้หรือยัง

---

# Example 1: Inspection Found Crack

Fact:

ช่างตรวจสอบแล้วพบรอยร้าว

Fact Data:

- Inspection Result
- Evidence
- Suggested Fix
- Required Material

System Derived State:

- Phase: PLAN หรือ DO
- State: Waiting Manager Review
- Next Action: ผู้จัดการนิติตรวจสอบแนวทางแก้ไข
- Owner: ผู้จัดการนิติ

---

# Example 2: Manager Approves But Material Missing

Fact:

ผู้จัดการนิติอนุมัติแนวทางซ่อม

Fact Data:

- Approved Fix
- Material Required
- Material Not Available

System Derived State:

- Phase: PLAN
- State: Waiting Procurement
- Next Action: จัดซื้อวัสดุ
- Owner: นิติบุคคล
- Due Date: วันที่คาดว่าจะได้รับวัสดุ

---

# Example 3: Repair Completed But Needs Monitoring

Fact:

ช่างซ่อมเสร็จแล้ว

Fact Data:

- After Evidence
- Repair Method
- Monitoring Required
- Monitoring Period: 7 Days
- Trigger Condition: Rain

System Derived State:

- Phase: CHECK
- State: Monitoring
- Next Action: ตรวจสอบหลังฝนตก
- Owner: หัวหน้าช่าง / นิติ
- Close Allowed: No

---

# Example 4: Verification Failed

Fact:

นิติตรวจแล้วไม่ผ่าน

Fact Data:

- Verification Result: Failed
- Reason
- Evidence
- Required Correction

System Derived State:

- Phase: DO
- State: Rework Required
- Next Action: ช่างแก้ไขตามข้อสังเกต
- Owner: ช่าง
- Close Allowed: No

---

# Example 5: All Completion Rules Passed

Fact:

เงื่อนไขปิด Case ครบทั้งหมด

Fact Data:

- Evidence Complete
- Verification Passed
- Resident Informed
- Monitoring Completed
- Required Reports Completed

System Derived State:

- Phase: ACT
- State: Ready To Close
- Next Action: ผู้มีสิทธิ์กดปิด Case
- Close Allowed: Yes

---

# PDCA Mapping

State Engine ต้องสามารถผูก Case เข้ากับ PDCA ได้

## PLAN

ใช้เมื่อ Case อยู่ในช่วง:

- รับเรื่อง
- วิเคราะห์
- ขออนุมัติ
- มอบหมาย
- วางแผน
- รอจัดซื้อ
- รอผู้รับเหมา

## DO

ใช้เมื่อ Case อยู่ในช่วง:

- ดำเนินการ
- ซ่อม
- ติดตั้ง
- แก้ไข
- ผู้รับเหมาทำงาน
- Rework

## CHECK

ใช้เมื่อ Case อยู่ในช่วง:

- รอตรวจรับ
- ทดสอบ
- Monitoring
- ติดตามผล
- ตรวจหลังซ่อม

## ACT

ใช้เมื่อ Case อยู่ในช่วง:

- สรุปผล
- แจ้งผู้เกี่ยวข้อง
- รายงานกรรมการ
- บันทึกบทเรียน
- ปิด Case

---

# State Is Derived, Not Manually Selected

ผู้ใช้ไม่ควรเลือก State โดยตรง

ผู้ใช้ควรทำ Action เช่น:

- ส่งผลตรวจ
- อนุมัติ
- แนบ Evidence
- ขอจัดซื้อ
- ยืนยันตรวจรับ
- แจ้งผู้เกี่ยวข้อง
- บันทึกผลติดตาม

แล้วระบบค่อยคำนวณ State

---

# Manual Override

ระบบอาจต้องมี Manual Override เฉพาะผู้มีสิทธิ์สูง เช่น Admin หรือผู้จัดการนิติ

แต่ทุกครั้งที่ Override ต้องบันทึก:

- ใคร Override
- Override จาก State อะไร
- Override เป็น State อะไร
- เหตุผล
- วันเวลา
- Evidence ถ้ามี

Manual Override ต้องถือเป็นเหตุการณ์สำคัญใน Audit Log

---

# State Engine Rules

ทุก State ต้องมี:

1. Phase
2. State Name
3. Owner
4. Next Action
5. Due Date หรือ Follow Up Date ถ้ามี
6. Close Allowed
7. Reason

---

# Close Case Rule

Case จะปิดได้ก็ต่อเมื่อ State Engine ระบุว่า:

Close Allowed = Yes

ไม่ใช่เพราะผู้ใช้กดปิดเองตามความรู้สึก

---

# Final Principle

O83 Care ต้องลดภาระการอัปเดตสถานะของผู้ใช้

ผู้ใช้ทำงานและบันทึกข้อเท็จจริง

ระบบสรุปสถานะ

ระบบแจ้งเตือน

ระบบพา Case เดินต่อ