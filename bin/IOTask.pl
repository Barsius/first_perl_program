#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use lib 'lib';
use File::Path qw(remove_tree);
use Text::CSV qw( csv );
use IOFileHandler;
use File::Find;
use Text::CSV qw( csv );
use Date::Parse;
use DBHandler;


IOFileHandler::createInitialDirectoryStructure;
IOFileHandler::createAndPopulateFiles;
my $functionRef = IOFileHandler::process_csv;
find($functionRef, 'raw_data');


# USE THIS FOR INTERACTION WITH DB
#
#IOFileHandler::createInitialDirectoryStructure;
#IOFileHandler::createAndPopulateFilesFromDB;
#find(\&IOFileHandler::process_csv_to_db, 'raw_data');
