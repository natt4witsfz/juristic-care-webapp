import type { TaskStatus } from './housekeeping_types';

interface TaskStatusMeta {
  readonly label: string;
  readonly label_en: string;
  readonly icon: string;
  readonly description: string;
}

export const TASK_STATUS_META: Readonly<Record<TaskStatus, TaskStatusMeta>> = {
  not_due: {
    label: 'ยังไม่ถึงเวลา',
    label_en: 'Not due',
    icon: '○',
    description: 'ยังไม่ถึงเวลาหรือไม่มีงานในรอบนี้',
  },
  not_started: {
    label: 'ยังไม่เริ่ม',
    label_en: 'Not started',
    icon: '!',
    description: 'ถึงเวลาแล้วแต่ยังไม่มีหลักฐาน Before',
  },
  in_progress: {
    label: 'กำลังดำเนินการ',
    label_en: 'In progress',
    icon: '◐',
    description: 'มีหลักฐาน Before แล้ว แต่ยังไม่ได้ส่งงาน',
  },
  awaiting_inspection: {
    label: 'รอตรวจ',
    label_en: 'Awaiting inspection',
    icon: '⌛',
    description: 'ผู้ปฏิบัติงานส่งหลักฐานแล้ว รอนิติตรวจ',
  },
  approved: {
    label: 'ผ่านแล้ว',
    label_en: 'Approved',
    icon: '✓',
    description: 'ผู้มีสิทธิ์ตรวจอนุมัติงานแล้ว',
  },
  rejected: {
    label: 'ไม่ผ่าน',
    label_en: 'Rejected',
    icon: '↩',
    description: 'ส่งกลับให้แก้ไขโดยเก็บหลักฐานเดิมไว้',
  },
  overdue: {
    label: 'เลยกำหนด',
    label_en: 'Overdue',
    icon: '⚠',
    description: 'เกินเวลาที่กำหนดและยังไม่ส่งงาน',
  },
};
