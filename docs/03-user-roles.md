# User Roles & Permissions V1

## Goal

ระบบต้องสามารถบริหาร Role และ Permission ผ่าน Admin Console ได้ โดยไม่ต้องแก้โค้ดทุกครั้งที่มีการเปลี่ยนสิทธิ์

## Principle

- Role คือกลุ่มสิทธิ์
- Permission คือความสามารถรายข้อ
- User สามารถมีได้มากกว่า 1 Role ในอนาคต
- Admin สามารถเปิด/ปิด permission ของแต่ละ role ได้
- การตรวจสิทธิ์ต้องอ้างอิงจาก database ไม่ใช่ hard-code ใน frontend

## Default Roles

- admin
- committee
- juristic_manager
- juristic_staff
- head_technician
- technician
- resident
- maids
- security staff

## Example Permissions

- work_order.create
- work_order.assign
- work_order.view_all
- work_order.view_own
- work_order.update_status
- work_order.verify
- work_order.close
- work_order.reject
- attachment.upload
- resident.manage
- user.manage
- role.manage
- audit_log.view
- report.view

## Admin Console Requirements

Admin Console ต้องสามารถ:

1. สร้าง role ใหม่
2. แก้ไขชื่อ role
3. เปิด/ปิด permission ของแต่ละ role
4. กำหนด role ให้ user
5. ปิดการใช้งาน user
6. ดู audit log การเปลี่ยนสิทธิ์

## Database Tables Needed

### roles

เก็บ role ทั้งหมด

### permissions

เก็บ permission ทั้งหมด

### role_permissions

เชื่อม role กับ permission

### user_roles

เชื่อม user กับ role

## Rule

ห้ามเขียน logic แบบนี้ใน frontend:

```js
if (user.role === "admin") {
  showAdminMenu();
}


git add docs/03-user-roles.md
git commit -m "docs: add user roles and permissions v1"
git push