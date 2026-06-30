const SETTINGS = {
  spreadsheetName: 'Juristic Care Pilot DB',
  driveFolderName: 'Juristic Care Pilot Uploads',
  snapshotSheetName: 'Snapshot',
  logSheetName: 'ApiLogs'
};

function setup() {
  const props = PropertiesService.getScriptProperties();
  let spreadsheetId = props.getProperty('SPREADSHEET_ID');
  let folderId = props.getProperty('DRIVE_FOLDER_ID');

  if (!spreadsheetId) {
    const spreadsheet = SpreadsheetApp.create(SETTINGS.spreadsheetName);
    spreadsheetId = spreadsheet.getId();
    props.setProperty('SPREADSHEET_ID', spreadsheetId);
    ensureSheets_(spreadsheet);
    Logger.log('Spreadsheet URL: ' + spreadsheet.getUrl());
  } else {
    ensureSheets_(SpreadsheetApp.openById(spreadsheetId));
  }

  if (!folderId) {
    const folder = DriveApp.createFolder(SETTINGS.driveFolderName);
    folderId = folder.getId();
    props.setProperty('DRIVE_FOLDER_ID', folderId);
    Logger.log('Drive folder URL: ' + folder.getUrl());
  }

  Logger.log('SPREADSHEET_ID: ' + spreadsheetId);
  Logger.log('DRIVE_FOLDER_ID: ' + folderId);
}

function doGet() {
  return json_({
    ok: true,
    service: 'Juristic Care Pilot API',
    actions: ['getSnapshot', 'saveSnapshot']
  });
}

function doPost(e) {
  const lock = LockService.getScriptLock();
  lock.waitLock(20000);

  try {
    setup();
    const request = parseRequest_(e);
    const action = request.action;
    const payload = request.payload || {};

    if (action === 'getSnapshot') {
      return json_({ ok: true, snapshot: getSnapshot_() });
    }

    if (action === 'saveSnapshot') {
      saveSnapshot_(payload);
      writeApiLog_('saveSnapshot', 'ok');
      return json_({ ok: true, savedAt: new Date().toISOString() });
    }

    return json_({ ok: false, error: 'Unknown action: ' + action });
  } catch (error) {
    writeApiLog_('error', String(error && error.stack ? error.stack : error));
    return json_({ ok: false, error: String(error) });
  } finally {
    lock.releaseLock();
  }
}

function parseRequest_(e) {
  if (!e || !e.postData || !e.postData.contents) return {};
  return JSON.parse(e.postData.contents);
}

function getSpreadsheet_() {
  const id = PropertiesService.getScriptProperties().getProperty('SPREADSHEET_ID');
  if (!id) throw new Error('Missing SPREADSHEET_ID. Run setup() first.');
  return SpreadsheetApp.openById(id);
}

function ensureSheets_(spreadsheet) {
  let snapshot = spreadsheet.getSheetByName(SETTINGS.snapshotSheetName);
  if (!snapshot) snapshot = spreadsheet.insertSheet(SETTINGS.snapshotSheetName);
  if (snapshot.getLastRow() === 0) {
    snapshot.getRange(1, 1, 1, 3).setValues([['key', 'json', 'updatedAt']]);
  }
  snapshot.setFrozenRows(1);

  let logs = spreadsheet.getSheetByName(SETTINGS.logSheetName);
  if (!logs) logs = spreadsheet.insertSheet(SETTINGS.logSheetName);
  if (logs.getLastRow() === 0) {
    logs.getRange(1, 1, 1, 3).setValues([['at', 'action', 'detail']]);
    logs.setFrozenRows(1);
  }
}

function getSnapshot_() {
  const spreadsheet = getSpreadsheet_();
  const sheet = spreadsheet.getSheetByName(SETTINGS.snapshotSheetName);
  if (!sheet || sheet.getLastRow() < 2) return {};

  const rows = sheet.getRange(2, 1, sheet.getLastRow() - 1, 3).getValues();
  return rows.reduce((acc, row) => {
    const key = row[0];
    const json = row[1];
    if (!key || !json) return acc;
    try {
      acc[key] = JSON.parse(json);
    } catch (error) {
      acc[key] = null;
    }
    return acc;
  }, {});
}

function saveSnapshot_(snapshot) {
  const spreadsheet = getSpreadsheet_();
  const sheet = spreadsheet.getSheetByName(SETTINGS.snapshotSheetName);
  const keys = [
    'jobs',
    'adminLogs',
    'staffLogs',
    'residentRooms',
    'teamOverrides',
    'customUsers',
    'deletedUserIds',
    'updatedAt'
  ];
  const now = new Date().toISOString();
  const rows = keys.map((key) => [key, JSON.stringify(snapshot[key] || (key === 'updatedAt' ? now : [])), now]);
  sheet.clear();
  sheet.getRange(1, 1, 1, 3).setValues([['key', 'json', 'updatedAt']]);
  sheet.getRange(2, 1, rows.length, 3).setValues(rows);
  sheet.setFrozenRows(1);
}

function writeApiLog_(action, detail) {
  try {
    const spreadsheet = getSpreadsheet_();
    const sheet = spreadsheet.getSheetByName(SETTINGS.logSheetName);
    sheet.appendRow([new Date(), action, detail]);
  } catch (error) {
    Logger.log('writeApiLog_ failed: ' + error);
  }
}

function json_(payload) {
  return ContentService
    .createTextOutput(JSON.stringify(payload))
    .setMimeType(ContentService.MimeType.JSON);
}
