--------------------------------------------------------------------------------
-- Annotated SQLite3 table structure: notepads.db
--------------------------------------------------------------------------------

CREATE TABLE android_metadata (
  locale TEXT
);

CREATE TABLE notepads (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT,
  source_id INTEGER,
  created_date INTEGER,
  added_date INTEGER,
  modified_date INTEGER,
  mime_type TEXT,
  file_path TEXT,
  file_name TEXT,
  file_size INTEGER,
  thumbnail TEXT,
  prevent_delete INTEGER
);
