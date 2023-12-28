# HTML pages that interracts with perl scripts to perform CRUD operations in DB

## Input Output task testing

### Install dependencies

```
cpanm --installdeps .
```
### Run code

```
perl bin/IOTask.pl
```
or
```
/usr/bin/perl bin/IOTask.pl
```
After this raw_data directory will be crated with initial files and filtered_data directory will be created with results of filtering.

### Run tests
NOTE: this will delete existing raw_data and filtered_data directories and will create default ones
```
prove -l test/IOTest.t
```

## CRUD web UI

### Start local server

```
plackup -s Starman app.psgi
```
### Open local URL

```
http://localhost:5000/authorization.pl
```
