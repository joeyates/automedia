# automedia - Automate organization of your media files

Automedia organizes your photos and videos in a file hierarchy
according to date and time of creation.

The naming convention is:

```
2010s/2013/201304/20130426/102336.jpg
```

The time and date are extracted from the file name, or from
EXIF metadata within the file.

# Usage

```sh
$ automedia [android|fit|nextcloud|signal|whats_app] [ARGS]
```

# Android

```sh
$ automedia android --source [PATH] --destination [PATH]
  [--dry-run] [--verbose] [--quiet]
```

# Signal

## Unpack a backup

N.B.: This command depends on the Rust program `signal-backup-decode`
being available.

You can install it as follows:

```sh
$ cargo install signal-backup-decode
```

Unpack:

```sh
$ automedia signal unpack --source [FILE] --destination [PATH] \
  --password-file [FILE] [--dry-run] [--verbose] [--quiet]
```

* source - a Signal backup,
* destination - the path of the directory to create and unpack
  the Signal backup,
* password-file - a text file containing the password for the Signal backup

## Classify attachments

```sh
$ automedia signal --source [PATH] --destination [PATH]
  [--dry-run] [--verbose] [--quiet]
  [--start-timestamp-file PATH]
```

* source - this should point to the attachments directory of an
  unpacked Signal backup
* start-timestamp-file - this should be a file containig a UNIX
  timestamp. All files created before the indicated time will be
  ignored. This is useful if you manually post-process the imported
  files, renaming or deleting stuff, and don't want to have to
  redo the work.

## WhatsApp

```sh
automedia whats_app move
```

# Build

```sh
bin/build
```

# Roadmap

* Find files with date in EXIF information,
* Find and eliminate duplicates.
