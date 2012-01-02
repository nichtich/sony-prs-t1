# Introduction

This code repository contains some documentation and scripts to make use of the
Sony PRS T1 eBook reader on Linux. The device runs Android in it can be rooted
but you can also just modify its local storage as it is visible via USB.

# Motivation

First I wanted to understand how my eReader manages eBooks and annotations.
Second I want to read and annotate (!) books in the device and later export
the annotations in an open format. Unfortunately the situation for annotations
is even worse than the situation for eBooks. De-facto standards for eBooks are
EPUB and PDF (plus Amazon's own prison format that I prefer to ignore). For
annotations *there is no standard format*.

# Annotation formats

Some software such as Okular and Mendeley store annotations in special files.
Other software stores annotations in the book files. PRS T1 stores annotations
as SVG with metadata in SQLite3, so it can be extracted and transformed to other
formats.

# Current state of this software

Don't expect this project to become a real application. Right now there is only
one command line script `prst1.pl` to copy and transform books, notes and
annotations from the device to a local directory (you may first need to create
some directories, `database`, `notepads`, `download`, `markup`...)

    $ ./prst1.pl -?

A future idea woul include hacking calibre, but I prefer to to stick to one
particular software but better work with general data formats.

# Visbile directory structure of SONY PRS-T1

    READER
     |-- Sony_Reader 
     |    |-- database
     |    |    |-- cache
     |    |    |    |-- books
     |    |    |         |-- x (numeric book identifier)
     |    |    |              |-- thumbnail
     |    |    |              |-- markup
     |    |    |-- sync
     |    |-- media
     |    |    |-- audio
     |    |    |-- images
     |    |    |-- notepads
     |    |    |-- books
     |    |-- data
     |         |-- albumthumbs
	 |-- download

The `database` directory contains several SQLite3 files (`.db`) and
a cache.

The `cache` directory contains one folder for each book, numbered
(1,2,3...). For each book there is a `thumbnail` directory with
images, at least with the cover image `main_thumbnail.jpg`. The
`markup` directory contains a `.png` file and a `.svg` file for
each markup in a book (not including highlightings).

The `media` directory contains actual ebooks, notes, audio-files,
and images. Media files are referenced by filename in the sqlite3
databases, so don't just rename them!

# Database structure

Have a look at the `dbschemas` directory or browse around the database with
SQLite3:

    $ ./prst1.pl database
	$ sqlite3 database/books.db

# License

Right now this repository is all public domain. Feel free to fork and publish
under other licenses as well.

