# AI Development Guidelines

Version: 1.0

---

# Purpose

เอกสารนี้กำหนดมาตรฐานการทำงานของ AI ทุกตัวที่เข้ามาช่วยพัฒนาโปรเจกต์ Juristic Care

ได้แก่

- Codex
- Antigravity
- ChatGPT
- Cursor
- Claude
- Gemini
- AI Coding Assistant อื่น ๆ

AI ทุกตัวต้องปฏิบัติตามเอกสารนี้ก่อนเริ่มทำงาน

---

# Project Philosophy

Juristic Care ไม่ใช่เว็บไซต์ธรรมดา

Juristic Care คือ

Property Management Platform

ที่สามารถขยายได้ในอนาคต

- Condo
- Village
- Office Building
- Apartment
- Facility Management

ดังนั้นทุกการพัฒนาต้องคำนึงถึง

- Scalability
- Maintainability
- Security
- Performance

ก่อนความรวดเร็ว

---

# Required Reading

AI ต้องอ่านเอกสารต่อไปนี้ก่อนเริ่มทำงานทุกครั้ง

1. 01-project-vision.md
2. 02-workflow.md
3. 03-user-roles.md
4. 04-database-schema.md
5. 05-screen-flow.md
6. 06-api-design.md
7. 07-development-rules.md
8. 08-roadmap.md

หากเอกสารยังไม่มี
ให้แจ้งผู้พัฒนาก่อน
ห้ามเดา

---

# Golden Rules

## Rule 1

ห้ามเปลี่ยน Workflow เอง

Workflow ถือเป็น Source of Truth

หากต้องการเปลี่ยน

ให้เสนอเหตุผลก่อน

---

## Rule 2

ห้ามเปลี่ยน Database Schema เอง

Database ต้องรองรับข้อมูลย้อนหลัง

AI ไม่มีสิทธิ์ลบ field

หรือเปลี่ยนชนิดข้อมูล

โดยไม่ได้รับอนุมัติ

---

## Rule 3

ห้าม Hard-code

เช่น

BAD

```javascript
if(user.role=="admin")
```

GOOD

```javascript
hasPermission(user,"user.manage")
```

Permission ต้องอ้างอิงจาก Database

---

## Rule 4

ห้ามลบ Feature

หาก Feature ไม่ได้ใช้งาน

ให้เสนอว่า

Deprecated

แทนการลบทันที

---

## Rule 5

ทุกการแก้ไข

ต้องสรุปก่อนว่า

- จะแก้อะไร
- กระทบไฟล์ไหน
- กระทบ Workflow หรือไม่
- กระทบ Database หรือไม่

ก่อนลงมือ

---

# Coding Principles

AI ต้อง

- เขียนโค้ดให้อ่านง่าย
- ลดความซ้ำซ้อน
- แยก Module
- ใช้ Naming ที่สม่ำเสมอ
- Comment เฉพาะส่วนที่จำเป็น

---

# Database Principles

Database ต้องรองรับ

- Multi Property
- Multi Building
- Multi User
- Multi Role
- Multi Attachment
- Audit Log

ตั้งแต่ Version 1

---

# Permission Principles

Role

ไม่ใช่ Permission

Permission

ไม่ใช่ User

Relationship

User

↓

Role

↓

Permission

---

# Workflow Principles

Work Order

ต้องตอบได้เสมอ

1.
ตอนนี้อยู่กับใคร

2.
ต้องทำอะไรต่อ

3.
ใครเป็นคนรับผิดชอบ

4.
สถานะปัจจุบัน

5.
หลักฐานล่าสุด

6.
กำหนดติดตาม

---

# UI Principles

ทุกหน้าจอ

ต้องมี

- Search
- Filter
- Sort
- Responsive

ทุก Form

ต้อง

- Validate
- Prevent Duplicate
- Save Draft หากจำเป็น

---

# Attachment Principles

รองรับ

- Image

- Video

- PDF

ทุกไฟล์

ต้องมี

- Upload Time

- Uploaded By

- Related Work Order

---

# Logging

ทุก Action สำคัญ

ต้องมี Audit Log

เช่น

- Login

- Logout

- Assign Work

- Verify Work

- Close Work

- Change Permission

- Delete Data

---

# AI Working Process

ทุกครั้งก่อนแก้โค้ด

AI ต้อง

Step 1

อ่าน docs

↓

Step 2

สรุปแผน

↓

Step 3

อธิบายผลกระทบ

↓

Step 4

รอการยืนยัน

↓

Step 5

จึงเริ่มแก้โค้ด

---

# Forbidden Actions

AI ห้าม

- เปลี่ยนชื่อ Table
- เปลี่ยนชื่อ API
- ลบไฟล์
- เปลี่ยน Workflow
- เปลี่ยน Permission
- เปลี่ยน Business Logic

โดยไม่ได้รับอนุมัติ

---

# Development Strategy

Priority

Documentation

↓

Workflow

↓

Database

↓

Permission

↓

API

↓

Frontend

↓

Backend

↓

Testing

↓

Deployment

---

# Version Control

ทุก Commit

ควรมีความหมาย

ตัวอย่าง

docs: update workflow

feat: add work assignment

fix: resolve attachment upload

refactor: split work order module

---

# Future Expansion

ระบบต้องสามารถรองรับ

- Multiple Projects

- Multiple Juristic Companies

- Contractor Portal

- Resident Portal

- Mobile Application

- AI Assistant

- BI Dashboard

โดยไม่ต้องรื้อ Architecture

---

# Final Rule

หาก AI ไม่มั่นใจ

ห้ามเดา

ให้สอบถามผู้พัฒนา

ก่อนทำการเปลี่ยนแปลงเสมอ