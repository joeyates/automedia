# automedia - Automate organization of your media files

Store your photos and videos in a file hierarchy according to date and time
of creation.

The naming convention is:

```
2010s/2013/201304/20130426/102336.jpg
```

# Usage

```sh
$ mix automedia.run [android|signal] [ARGS]
```

## Android

```sh
$ mix automedia.run android --source [PATH] --destination [PATH]
  [--dry-run] [--verbose] [--quiet]
```

# Signal

```sh
$ mix automedia.run signal --source [PATH] --destination [PATH]
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

# Roadmap

* Find files with date in name and move to fixed tree structure
* Finds files with date in EXIF information,
* Store config in SQLite database,
* Add CLI for preference selection.
