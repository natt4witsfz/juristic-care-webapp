# O83 Care - Platform Architecture

Version: 1.0

---

# Purpose

O83 Care ถูกออกแบบเป็น Operations Platform สำหรับโครงการ

ไม่ใช่ระบบแจ้งซ่อมเพียงอย่างเดียว

ระบบต้องรองรับหลายประเภทงานของนิติบุคคล เช่น

- Repair
- Preventive Maintenance
- Legal
- Contract
- Meeting
- Budget
- Procurement
- Compliance
- Announcement
- Resident Complaint

โดยทุกประเภทงานต้องใช้ Core Engine เดียวกัน

---

# Core Idea

ทุก Domain คือ Operation

ทุก Operation สามารถถูกจัดการผ่าน Case

Case คือหน่วยกลางของระบบ

---

# Architecture Layers

## Layer 1: Core Engine

ส่วนนี้คือฐานของระบบ และไม่ควรถูกแก้บ่อย

ประกอบด้วย:

- Case
- Timeline
- Evidence
- Decision
- Workflow Engine
- State Engine
- Permission
- Notification
- Audit Log
- Relationship
- Current Snapshot

---

## Layer 2: Business Domain

ส่วนนี้คือประเภทงานที่เพิ่มได้ในอนาคต

ตัวอย่าง:

- Repair
- PM
- Legal
- Contract
- Meeting
- Budget
- Procurement
- Compliance

แต่ละ Domain ใช้ Core Engine เดียวกัน

ต่างกันที่:

- Form
- Workflow
- Evidence Policy
- Completion Rules
- Permission
- SLA
- KPI

---

## Layer 3: Configuration

ระบบควรถูกปรับได้ผ่าน Admin Console เท่าที่เป็นไปได้

เช่น:

- Role
- Permission
- Workflow Template
- Evidence Requirement
- SLA
- Notification Rule
- Completion Rule
- Case Type

---

# Design Rule

หากต้องเพิ่มงานประเภทใหม่

ให้ถามก่อนว่า:

1. ใช้ Case ได้ไหม
2. ใช้ Timeline ได้ไหม
3. ใช้ Evidence ได้ไหม
4. ใช้ Decision ได้ไหม
5. ใช้ Workflow Engine ได้ไหม
6. ใช้ State Engine ได้ไหม

ถ้าคำตอบคือใช่

ให้เพิ่มเป็น Business Domain ใหม่

ไม่ควรแก้ Core Engine

---

# Extension Levels

## Level 1: Configuration Change

ใช้เมื่อเปลี่ยนเฉพาะ:

- Permission
- SLA
- Workflow Step
- Evidence Required
- Role
- Notification

ไม่ต้องแก้โค้ดหลัก

---

## Level 2: New Business Domain

ใช้เมื่อเพิ่มประเภทงานใหม่ เช่น Legal หรือ Budget

อาจต้องเพิ่ม:

- Form
- View
- Workflow Template
- Report

แต่ยังใช้ Core Engine เดิม

---

## Level 3: Architecture Change

ใช้เฉพาะเมื่อสิ่งใหม่ไม่สามารถอธิบายด้วย Case, Evidence, Decision, Timeline หรือ Workflow ได้

ต้องผ่านการออกแบบและอนุมัติก่อน

---

# Boundary

O83 Care V1 ไม่ใช่ระบบบัญชีเต็มรูปแบบ

ไม่ใช่ระบบ ERP

ไม่ใช่ระบบ HR

ไม่ใช่ระบบ Payroll

แต่สามารถเชื่อมโยงข้อมูลกับระบบเหล่านั้นในอนาคตได้

---

# Final Principle

O83 Care ต้องขยายได้โดยไม่สูญเสียหลักการ

ระบบต้องไม่ยืดหยุ่นจนไร้มาตรฐาน

และต้องไม่แข็งจนต้องแก้โค้ดทุกครั้งที่ธุรกิจเปลี่ยน

