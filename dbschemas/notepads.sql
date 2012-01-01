--------------------------------------------------------------------------------
-- Annotated SQLite3 table structure: notepads.db
--------------------------------------------------------------------------------

CREATE TABLE android_metadata (
  locale TEXT
);

CREATE TABLE notepads (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT,
  source_id INTEGER,     -- ? (0 for device?)
  created_date INTEGER,  -- unix timestamp
  added_date INTEGER,    -- unix timestamp
  modified_date INTEGER, -- unix timestamp
  mime_type TEXT,        -- "application/x-sony-notepad-svg"
  file_path TEXT,        -- "Sony_Reader/media/notepads/foo.note"
  file_name TEXT,        -- "foo.note" (redundant)
  file_size INTEGER,     -- size of file foo.note in bytes (redundant)
  thumbnail TEXT,
  prevent_delete INTEGER
);

