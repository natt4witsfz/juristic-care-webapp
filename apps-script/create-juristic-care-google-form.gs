/**
 * Juristic Care Google Form generator
 *
 * วิธีใช้:
 * 1. เปิด https://script.google.com/
 * 2. สร้าง New project
 * 3. วางไฟล์นี้ใน Code.gs
 * 4. กด Run ฟังก์ชัน createJuristicCareIssueForm
 * 5. อนุญาตสิทธิ์ Google ตามหน้าจอ
 * 6. ดู Form URL และ Sheet URL ใน Logs
 */
function createJuristicCareIssueForm() {
  const form = FormApp.create('Juristic Care - แจ้งปัญหา / แจ้งซ่อม / งานนิติบุคคล');
  form.setDescription(
    'ใช้สำหรับแจ้งปัญหาภายในห้องพัก พื้นที่ส่วนกลาง และงานที่ต้องให้นิติบุคคลตรวจสอบ ' +
    'ข้อมูลจะถูกส่งเข้า Pool งานกลางเพื่อคัดแยกประเภทและมอบหมายผู้รับผิดชอบ'
  );
  form.setCollectEmail(false);
  form.setAllowResponseEdits(false);
  form.setShowLinkToRespondAgain(false);

  addSectionHeader_(form, '1. ข้อมูลผู้แจ้ง');

  form.addTextItem()
    .setTitle('ชื่อผู้แจ้ง')
    .setRequired(true);

  form.addTextItem()
    .setTitle('เลขห้อง / พื้นที่ที่เกี่ยวข้อง')
    .setHelpText('เช่น A-1204, Lobby, ชั้น 8, Parking B1')
    .setRequired(true);

  form.addTextItem()
    .setTitle('เบอร์โทรศัพท์')
    .setRequired(true);

  form.addTextItem()
    .setTitle('ช่องทางติดต่อเพิ่มเติม')
    .setHelpText('เช่น LINE ID, อีเมล')
    .setRequired(false);

  addSectionHeader_(form, '2. ประเภทงาน');

  form.addMultipleChoiceItem()
    .setTitle('ประเภทหลัก')
    .setChoiceValues(['งานส่วนกลาง', 'งานลูกบ้าน'])
    .setRequired(true);

  form.addListItem()
    .setTitle('ประเภทรอง')
    .setChoiceValues([
      'ปะปา',
      'ไฟฟ้า',
      'ความสะอาด',
      'โครงสร้างอาคาร',
      'ลิฟต์',
      'สวน',
      'เฟอร์นิเจอร์',
      'ระบบความปลอดภัย',
      'อินเตอร์เน็ต'
    ])
    .setRequired(true);

  form.addMultipleChoiceItem()
    .setTitle('ระดับความเร่งด่วน')
    .setChoiceValues(['ปกติ', 'เร่งด่วน', 'ฉุกเฉิน'])
    .setRequired(true);

  addSectionHeader_(form, '3. รายละเอียดงาน');

  form.addTextItem()
    .setTitle('หัวข้องาน / ปัญหาที่พบ')
    .setRequired(true);

  form.addParagraphTextItem()
    .setTitle('รายละเอียดเพิ่มเติม')
    .setHelpText('ระบุจุดที่เกิดเหตุ อาการที่พบ ช่วงเวลาที่สะดวกให้ติดต่อ หรือข้อมูลที่ช่างควรรู้')
    .setRequired(true);

  form.addTextItem()
    .setTitle('จุดเกิดเหตุ')
    .setHelpText('เช่น ห้องน้ำ, ใต้ซิงค์, หน้าลิฟต์ชั้น 8, สวนด้านหน้า')
    .setRequired(false);

  form.addDateItem()
    .setTitle('วันที่พบปัญหา')
    .setRequired(false);

  form.addTimeItem()
    .setTitle('เวลาที่พบปัญหา')
    .setRequired(false);

  addSectionHeader_(form, '4. รูปภาพและเอกสารแนบ');

  addFileUploadQuestionIfAvailable_(form);

  form.addParagraphTextItem()
    .setTitle('ลิงก์รูปภาพหรือไฟล์เพิ่มเติม')
    .setHelpText('ใช้กรณีไม่สะดวกอัปโหลดไฟล์ในฟอร์ม')
    .setRequired(false);

  addSectionHeader_(form, '5. การยินยอมและการเปิดเผย');

  form.addMultipleChoiceItem()
    .setTitle('อนุญาตให้เจ้าหน้าที่ติดต่อกลับ')
    .setChoiceValues(['อนุญาต', 'ไม่อนุญาต'])
    .setRequired(true);

  form.addMultipleChoiceItem()
    .setTitle('อนุญาตให้เจ้าหน้าที่เข้าตรวจสอบพื้นที่หรือเข้าห้องตามนัดหมาย')
    .setChoiceValues(['อนุญาต', 'ต้องโทรนัดหมายก่อนเท่านั้น', 'ไม่อนุญาต'])
    .setRequired(true);

  form.addMultipleChoiceItem()
    .setTitle('การแสดงผลในภาพรวมของโครงการ')
    .setChoiceValues([
      'แสดงเป็นสถิติเท่านั้น',
      'อนุญาตให้แสดงรายละเอียดโดยไม่เปิดเผยข้อมูลส่วนตัว'
    ])
    .setRequired(true);

  const sheet = SpreadsheetApp.create('Juristic Care - Form Responses');
  form.setDestination(FormApp.DestinationType.SPREADSHEET, sheet.getId());

  Logger.log('Form edit URL: ' + form.getEditUrl());
  Logger.log('Form public URL: ' + form.getPublishedUrl());
  Logger.log('Response sheet URL: ' + sheet.getUrl());
}

function addSectionHeader_(form, title) {
  form.addSectionHeaderItem().setTitle(title);
}

function addFileUploadQuestionIfAvailable_(form) {
  try {
    if (typeof form.addFileUploadItem !== 'function') {
      form.addParagraphTextItem()
        .setTitle('แนบรูปภาพ / เอกสารประกอบ')
        .setHelpText('บัญชีนี้ไม่รองรับ File Upload ผ่าน Apps Script ให้ใส่ลิงก์ไฟล์แทน')
        .setRequired(false);
      return;
    }

    form.addFileUploadItem()
      .setTitle('แนบรูปภาพ / เอกสารประกอบ')
      .setHelpText('แนะนำไม่เกิน 5 ไฟล์ เช่น รูปภาพหรือ PDF')
      .setRequired(false);
  } catch (error) {
    form.addParagraphTextItem()
      .setTitle('แนบรูปภาพ / เอกสารประกอบ')
      .setHelpText('หากเปิด File Upload ไม่ได้ ให้ใส่ลิงก์ Google Drive หรือรูปภาพในช่องนี้')
      .setRequired(false);
  }
}

