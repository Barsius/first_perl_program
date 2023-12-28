#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
use IOFileHandler;
use File::Path qw(remove_tree);
use Text::CSV qw( csv );
use File::Find;
use Date::Parse;

plan tests => 17;

my ($mainDir, $childDir1, $childDir2) = qw(raw_data district_1 district_2);
my ($resultDir, $beforeDir, $afterDir) = qw(filtered_data before_2000 after2000);
my $raw_data_csv = "$mainDir/data.csv";
my $district_1_csv = "$mainDir/$childDir1/data2.csv";
my $empty_data_txt = "$mainDir/$childDir2/empty.txt";
my $result_before_csv = "$resultDir/$beforeDir/before_2000.csv";
my $result_after_csv = "$resultDir/$afterDir/after_2000.csv";

if (-d $mainDir) {
    remove_tree($mainDir);
}
if (-d $resultDir) {
    remove_tree($resultDir)
}

{
    IOFileHandler::createInitialDirectoryStructure;
    ok(-d $mainDir, "createInitialDirectoryStructure creates $mainDir");
    ok(-d "$mainDir/$childDir1", "createInitialDirectoryStructure creates $childDir1");
    ok(-d "$mainDir/$childDir2", "createInitialDirectoryStructure creates $childDir2");
}

{
    IOFileHandler::createResultsDirectories;
    ok(-d $resultDir, "createResultsDirectories creates $resultDir");
    ok(-d "$resultDir/$beforeDir", "createInitialDirectoryStructure creates $childDir1");
    ok(-d "$resultDir/$afterDir", "createInitialDirectoryStructure creates $childDir2");
}
{
    ok(IOFileHandler::keysAreValid("City", "First Name", "Date of Birth", "Last Name"), "keysAreValid returns true when keys are valid");
    ok(!IOFileHandler::keysAreValid("First Name", "Date of Birth", "Last Name"), "keysAreValid returns false when keys are not valid");
}
{
    IOFileHandler::createAndPopulateFiles();
    ok(-e $raw_data_csv, "createAndPopulateFiles creates $raw_data_csv");
    ok(-e $district_1_csv, "createAndPopulateFiles creates $district_1_csv");
    ok(-e $empty_data_txt, "createAndPopulateFiles creates $empty_data_txt");

    my $aoh = csv (in => $raw_data_csv, headers => "auto");
    my %first_hash = %{$aoh->[0]};
    ok(IOFileHandler::keysAreValid(keys(%first_hash)), "csv in raw_data created with correct headers");

    my $aoh2 = csv (in => $district_1_csv, headers => "auto");
    my %first_hash2 = %{$aoh2->[0]};
    ok(IOFileHandler::keysAreValid(keys(%first_hash2)), "csv in district2 created with correct headers");
}
{
    IOFileHandler::createResultsFiles();
    ok(-e $result_before_csv, "createResultsDirectories creates $result_before_csv");
    ok(-e $result_after_csv, "createResultsDirectories creates $result_after_csv");
}
{
    my $functionRef = IOFileHandler::process_csv;
    find($functionRef, 'raw_data');
    my $aoh = csv (in => $result_before_csv, headers => "auto");

    my $centralDate = str2time("2000-01-01");

    my $before2000ContainsDatesOnlyBefore2000 = 1;

    foreach my $hash_ref (@$aoh) {
        if (str2time($hash_ref->{"Date of Birth"}) >= $centralDate) {
            $before2000ContainsDatesOnlyBefore2000 = 0;
        }
    }

    ok($before2000ContainsDatesOnlyBefore2000, "before_2000 contains dates only before 2000 year");

    my $aoh2 = csv (in => $result_after_csv, headers => "auto");

    my $after2000ContainsDatesOnlyAfter2000 = 1;

    foreach my $hash_ref (@$aoh2) {
        if (str2time($hash_ref->{"Date of Birth"}) < $centralDate) {
            $after2000ContainsDatesOnlyAfter2000 = 0;
        }
    }
    ok($before2000ContainsDatesOnlyBefore2000, "after_2000 contains dates only after 2000 year");
}

done_testing();
