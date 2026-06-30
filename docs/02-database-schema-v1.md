# Juristic Care - Database Schema V1

## Goal

Database V1 ต้องรองรับระบบแจ้งซ่อมหลัก:

รับแจ้ง → มอบหมาย → ช่างดำเนินการ → นิติตรวจสอบ → แจ้งลูกบ้าน → ปิดงาน

และรองรับกรณี:

- รออะไหล่
- รอผู้รับเหมา
- รอติดตาม
- แนบรูปภาพ / วิดีโอ
- Audit log
- หลายโครงการในอนาคต

---

## Core Tables

### 1. users

เก็บผู้ใช้งานระบบทั้งหมด

```sql
users (
  id uuid primary key,
  full_name text not null,
  email text unique,
  phone text,
  role text not null,
  property_id uuid,
  is_active boolean default true,
  created_at timestamp default now(),
  updated_at timestamp default now()
)