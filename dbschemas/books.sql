--------------------------------------------------------------------------------
-- Annotated SQLite3 table structure: books.db
--------------------------------------------------------------------------------

CREATE TABLE android_metadata (locale TEXT)

CREATE TABLE annotation (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  content_id INTEGER,
  markup_type INTEGER DEFAULT 10,
  added_date INTEGER,
  modified_date INTEGER,
  name TEXT,
  marked_text TEXT,
  mark BLOB,
  mark_end BLOB,
  page DOUBLE,
  total_page INTEGER,
  mime_type TEXT,
  file_path TEXT
)

CREATE TABLE bookmark (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  font_size INTEGER,
  mark BLOB,
  mark_end BLOB,
  page DOUBLE,
  total_page INTEGER,
  page_style INTEGER,
  page_style_index INTEGER,
  crop_mode INTEGER,
  crop_left INTEGER,
  crop_top INTEGER,
  crop_right INTEGER,
  crop_bottom INTEGER,
  orientation INTEGER,
  content_id INTEGER,
  markup_type INTEGER DEFAULT 0,
  added_date INTEGER,
  modified_date INTEGER,
  name TEXT,
  marked_text TEXT,
  mime_type TEXT,
  file_path TEXT
)

CREATE TABLE books (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT,
  author TEXT,
  kana_title TEXT,
  kana_author TEXT,
  title_key TEXT,
  author_key TEXT,
  source_id INTEGER,
  added_date INTEGER,
  modified_date INTEGER,
  reading_time INTEGER,
  purchased_date INTEGER,
  file_path TEXT,
  file_name TEXT,
  file_size INTEGER,
  thumbnail TEXT,
  mime_type TEXT,
  corrupted INTEGER,
  expiration_date INTEGER,
  prevent_delete INTEGER,
  sony_id TEXT,
  periodical_name TEXT,
  kana_periodical_name TEXT,
  periodical_name_key TEXT,
  publication_date INTEGER,
  conforms_to TEXT,
  description TEXT,
  logos TEXT
)

CREATE TABLE collection (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT,
  kana_title TEXT,
  source_id INTEGER,
  uuid TEXT
)

CREATE TABLE collections (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  collection_id INTEGER,
  content_id INTEGER,
  added_order INTEGER
)

CREATE TABLE current_position (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  content_id INTEGER,
  dpi INTEGER,
  width INTEGER,
  height INTEGER,
  version INTEGER,
  mark BLOB,
  split_index INTEGER,
  page_style INTEGER,
  crop_mode INTEGER,
  crop_area_left INTEGER,
  crop_area_top INTEGER,
  crop_area_right INTEGER,
  crop_area_bottom INTEGER,
  font_size INTEGER,
  reflow INTEGER,
  font_style TEXT,
  orientation INTEGER,
  text_encoding TEXT
)

CREATE TABLE deleted_markups (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  content_id INTEGER,
  markup_type INTEGER,
  added_date INTEGER,
  name TEXT,
  mark BLOB,
  mark_end BLOB
)

CREATE TABLE dic_histories (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  content_id INTEGER,
  dic_content_id INTEGER,
  dic_content_name TEXT NOT NULL,
  dic_searchword TEXT NOT NULL,
  dic_search_no INTEGER,
  added_date TEXT NOT NULL
)

CREATE TABLE freehand (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  font_style TEXT,
  font_size INTEGER,
  mark BLOB,
  mark_end BLOB,
  page DOUBLE,
  total_page INTEGER,
  page_style INTEGER,
  page_style_index INTEGER,
  crop_mode INTEGER,
  crop_left INTEGER,
  crop_top INTEGER,
  crop_right INTEGER,
  crop_bottom INTEGER,
  orientation INTEGER,
  text_encoding TEXT,
  content_id INTEGER,
  markup_type INTEGER DEFAULT 20,
  added_date INTEGER,
  modified_date INTEGER,
  name TEXT,
  svg_file TEXT,
  thumbnail TEXT
)

CREATE TABLE history (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  content_id INTEGER,
  dpi INTEGER,
  width INTEGER,
  height INTEGER,
  version INTEGER,
  added_counter INTEGER,
  reading_time INTEGER,
  mark BLOB,
  split_index INTEGER,
  page_style INTEGER,
  crop_mode INTEGER,
  crop_area_left INTEGER,
  crop_area_top INTEGER,
  crop_area_right INTEGER,
  crop_area_bottom INTEGER,
  font_size INTEGER,
  reflow INTEGER,
  font_style TEXT,
  orientation INTEGER,
  text_encoding TEXT
)

CREATE TABLE layout_cache (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  content_id INTEGER,
  dpi INTEGER,
  width INTEGER,
  height INTEGER,
  font_size INTEGER,
  reflow INTEGER,
  font_style TEXT,
  encoding TEXT,
  state INTEGER,
  file_path TEXT,
  layout_version INTERGER
)

CREATE TABLE preference (
  _id INTEGER PRIMARY KEY AUTOINCREMENT,
  content_id INTEGER NOT NULL,
  tone_curve_type TEXT,
  contrast INTEGER,
  brightness INTEGER,
  show_notes INTEGER,
  binding_direction TEXT
)

CREATE TABLE sqlite_sequence(name, seq)

CREATE VIEW markups AS SELECT
  a._id _id,
  a.content_id content_id,
  a.markup_type markup_type,
  a.added_date added_date,
  a.modified_date modified_date,
  trim(a.name) name,
  a.page page,
  a.total_page total_page,
  a.file_path file1,
  null file2,
  b.file_name file_name,
  b.title title,
  b.author author,
  b.kana_title kana_title,
  b.kana_author kana_author,
  b.periodical_name periodical_name,
  b.publication_date publication_date,
  b.source_id source_id 
FROM bookmark a JOIN books b ON b._id=a.content_id 
UNION ALL SELECT 
  a._id _id,
  a.content_id content_id,
  a.markup_type markup_type,
  a.added_date added_date,
  a.modified_date modified_date,
  trim(a.name) name,
  a.page page,
  a.total_page total_page,
  a.file_path file1,
  null file2,
  b.file_name file_name,
  b.title title,
  b.author author,
  b.kana_title kana_title,
  b.kana_author kana_author,
  b.periodical_name periodical_name,
  b.publication_date publication_date,
  b.source_id source_id 
FROM annotation a JOIN books b ON b._id=a.content_id 
UNION ALL SELECT 
  a._id _id,
  a.content_id content_id,
  a.markup_type markup_type,
  a.added_date added_date,
  a.modified_date modified_date,
  trim(a.name) name,
  a.page page,
  a.total_page total_page,
  a.svg_file file1,
  a.thumbnail file2,
  b.file_name file_name,
  b.title title,
  b.author author,
  b.kana_title kana_title,
  b.kana_author kana_author,
  b.periodical_name periodical_name,
  b.publication_date publication_date,
  b.source_id source_id
FROM freehand a JOIN books b ON b._id=a.content_id

CREATE VIEW periodicals AS SELECT DISTINCT * FROM (
  SELECT DISTINCT 
    periodical_name,
    kana_periodical_name,
    CASE WHEN COUNT(reading_time)=COUNT(*) THEN MAX(reading_time) ELSE NULL END AS reading_time,
    MAX(reading_time) AS reading_time,
    MAX(publication_date) AS publication_date,
    COUNT(periodical_name) AS _count 
  FROM books GROUP BY 
    periodical_name,
    kana_periodical_name 
  HAVING periodical_name NOT NULL OR kana_periodical_name NOT NULL
) AS g LEFT JOIN (
  SELECT
    periodical_name,
    kana_periodical_name,
    publication_date,
    _id,
    source_id,
    thumbnail,
    periodical_name_key,
    logos 
  FROM books GROUP BY
    periodical_name,
    kana_periodical_name,
    publication_date 
) AS b ON (
  ((g.periodical_name NOT NULL AND (g.periodical_name = b.periodical_name)) OR 
   (g.kana_periodical_name NOT NULL AND(g.kana_periodical_name = b.kana_periodical_name))) 
  AND g.publication_date = b.publication_date 
)

