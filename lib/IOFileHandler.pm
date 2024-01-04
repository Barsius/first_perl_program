package IOFileHandler;
use strict;
use warnings FATAL => 'all';
use File::Path qw(make_path);
use Text::CSV qw( csv );
use List::Util qw(any);
use Date::Parse;
use DBHandler;

my ($raw_data, $district_1, $district_2) = qw(raw_data district_1 district_2);
my ($resultDir, $beforeDir, $afterDir) = qw(filtered_data before_2000 after2000);

sub createInitialDirectoryStructure {
    make_path("$raw_data/$district_1", { mode => 0775 });
    make_path("$raw_data/$district_2", { mode => 0775 });
}

sub createResultsDirectories() {
    make_path("$resultDir/$beforeDir", { mode => 0775 });
    make_path("$resultDir/$afterDir", { mode => 0775 });
}

sub createAndPopulateFiles {
    my $raw_data_csv = "$raw_data/data.csv";
    my $district_1_csv = "$raw_data/$district_1/data2.csv";
    my $empty_data_txt = "$raw_data/$district_2/empty.txt";

    my @initial_data = (
        ["First Name", "Last Name", "City", "Date of Birth"],
        ["Ivan", "Menshykov", "Kharkiv", "1998-01-20"],
        ["Petro", "Petrenko", "Kharkiv", "1998-01-26"],
        ["John", "Doe", "Boston", "1945-06-12"],
        ["Linda", "Pinkerton", "New York", "1994-01-13"],
        ["Dutch", "Vanderlinde", "Texas", "1932-05-23"],
        ["Arthur", "Morgan", "Texas", "1993-11-22"],
        ["Johny", "Silverhand", "Kharkiv", "2001-01-24"],
        ["Barbara", "Stillman", "Washington", "2003-08-22"],
        ["Ezio", "Auditore", "Venice", "2008-12-13"],
        ["Fred", "Fasbear", "Lviv", "2011-01-24"],
    );

    my $csv = Text::CSV->new ({ binary => 1, auto_diag => 1 });
    open my $fh, ">:encoding(utf8)", $raw_data_csv or die "$raw_data_csv: $!";
    $csv->say ($fh, $_) for @initial_data;
    close $fh or die "$raw_data_csv: $!";

    my @initial_data2 = (
        ["First Name", "Last Name", "City", "Date of Birth"],
        ["Khan", "Batyj", "UlanBator", "1456-01-11"],
        ["Ivan", "Ivanov", "Kharkiv", "1998-01-28"],
        ["John", "Travolta", "Hollywood", "2001-06-23"],
        ["Quentin", "Tarantino", "Hollywood", "2010-11-13"],
        ["Kilian", "Merfy", "Texas", "2000-03-19"],
        ["Robert", "Openheimer", "Hiroshima", "1993-10-19"],
        ["Saburo", "Arasaka", "Tokyo", "1990-01-01"],
        ["Who", "Me", "Pekin", "2009-05-23"],
        ["Eelon", "Mask", "New York", "1991-05-23"],
        ["Fred", "Kryguer", "Lviv", "2011-01-24"],
    );

    open $fh, ">:encoding(utf8)", $district_1_csv or die "$district_1_csv: $!";
    $csv->say ($fh, $_) for @initial_data2;
    close $fh or die "$district_1_csv: $!";

    open $fh, ">:encoding(utf8)", $empty_data_txt or die "$empty_data_txt: $!";
    close $fh or die "$empty_data_txt: $!";
}

sub createAndPopulateFilesFromDB {
    my $raw_data_csv = "$raw_data/data.csv";
    my $district_1_csv = "$raw_data/$district_1/data2.csv";
    my $empty_data_txt = "$raw_data/$district_2/empty.txt";

    my @raw_data = DBHandler::getAllRawData;

    my @data_first_half = splice(@raw_data, 0, @raw_data/2);
    my @data_second_half = @raw_data;

    my $csv = Text::CSV->new ({ binary => 1, auto_diag => 1, eol => "\n" });

    open my $fh, ">:encoding(utf8)", $raw_data_csv or die "$raw_data_csv: $!";
    $csv->print($fh, ['First Name', 'Last Name', 'City', 'Date of Birth']);
    if(@data_first_half) {
        foreach my $record (@data_first_half) {
            $csv->print($fh, [@$record{('FIRST_NAME', 'LAST_NAME', 'CITY', 'DATE_OF_BIRTH')}]);
        }
    }
    close $fh or die "$raw_data_csv: $!";

    open $fh, ">:encoding(utf8)", $district_1_csv or die "$district_1_csv: $!";
    $csv->print($fh, ['First Name', 'Last Name', 'City', 'Date of Birth']);
    if(@data_second_half) {
        foreach my $record (@data_second_half) {
            $csv->print($fh, [@$record{('FIRST_NAME', 'LAST_NAME', 'CITY', 'DATE_OF_BIRTH')}]);
        }
    }
    close $fh or die "$district_1_csv: $!";

    open $fh, ">:encoding(utf8)", $empty_data_txt or die "$empty_data_txt: $!";
    close $fh or die "$empty_data_txt: $!";
}

sub createResultsFiles {
    my $result_before_csv = "$resultDir/$beforeDir/before_2000.csv";
    my $result_after_csv = "$resultDir/$afterDir/after_2000.csv";
    my $csv = Text::CSV->new({ binary => 1, auto_diag => 1, eol => "\n" });

    open my $fh, ">:encoding(utf8)", $result_before_csv or die "$result_before_csv: $!";
    $csv->print($fh, ['City', 'First Name', 'Date of Birth', 'Last Name']);
    close $fh or die "$result_before_csv: $!";
    open $fh, ">:encoding(utf8)", $result_after_csv or die "$result_after_csv: $!";
    $csv->print($fh, ['City', 'First Name', 'Date of Birth', 'Last Name']);
    close $fh or die "$result_after_csv: $!";
}

sub process_csv {
    createResultsDirectories;
    createResultsFiles;

    my $result_before_absolute_path = File::Spec->rel2abs("$resultDir/$beforeDir/before_2000.csv");
    my $result_after_absolute_path = File::Spec->rel2abs("$resultDir/$afterDir/after_2000.csv");

    return sub {

        my $file = $_;
        my $file_extension = 'csv';
        my $csv = Text::CSV->new({ binary => 1, auto_diag => 1, eol => $/ });

        return unless $file =~ /\.($file_extension)$/i;

        my $full_path = File::Spec->rel2abs($file);

        print "Processing:$full_path\n";
        filterAndSaveHashFromCsv($full_path, $result_before_absolute_path, $result_after_absolute_path);
    }
}

sub process_csv_to_db {
        my $file = $_;
        my $file_extension = 'csv';

        return unless $file =~ /\.($file_extension)$/i;

        my $full_path = File::Spec->rel2abs($file);

        print "Processing:$full_path\n";
        filterAndSaveHashFromCsvToDB($full_path);
}

sub filterAndSaveHashFromCsv {
    my ($fullPathToData, $fullPathToResultBefore, $fullPathToResultAfter) = @_;

    my $aoh = csv (in => $fullPathToData, headers => "auto");
    my %first_hash = %{$aoh->[0]};
    return unless keysAreValid(keys(%first_hash));

    my $centralDate = str2time("2000-01-01");

    my @before2000;
    my @after2000;

    foreach my $hash_ref (@$aoh) {
        if (str2time($hash_ref->{"Date of Birth"}) < $centralDate) {
            push(@before2000, $hash_ref);
        } else {
            push(@after2000, $hash_ref);
        }
    }

    if(@before2000) {
        open my $fh, '>>', $fullPathToResultBefore or die "Could not open '$fullPathToResultBefore' for writing: $!";
        my $csv = Text::CSV->new({ binary => 1, auto_diag => 1, eol => "\n" });
        foreach my $record (@before2000) {
            $csv->print($fh, [@$record{('City', 'First Name', 'Date of Birth', 'Last Name')}]);
        }
        close $fh or die "Could not close '$fullPathToResultBefore': $!";
    }
    if (@after2000) {
        open my $fh, '>>', $fullPathToResultAfter or die "Could not open '$fullPathToResultAfter' for writing: $!";
        my $csv = Text::CSV->new({ binary => 1, auto_diag => 1, eol => "\n" });
        foreach my $record (@after2000) {
            $csv->print($fh, [@$record{('City', 'First Name', 'Date of Birth', 'Last Name')}]);
        }
        close $fh or die "Could not close '$fullPathToResultAfter': $!";
    }
}

sub filterAndSaveHashFromCsvToDB {
    my ($fullPathToData) = @_;

    my $aoh = csv (in => $fullPathToData, headers => "auto");
    my %first_hash = %{$aoh->[0]};
    return unless keysAreValid(keys(%first_hash));

    my $centralDate = str2time("2000-01-01");

    my @before2000;
    my @after2000;

    foreach my $hash_ref (@$aoh) {
        if (str2time($hash_ref->{"Date of Birth"}) < $centralDate) {
            push(@before2000, $hash_ref);
        } else {
            push(@after2000, $hash_ref);
        }
    }

    if(@before2000) {
        my $arrayRef = \@before2000;
        DBHandler::saveDataBefore2000($arrayRef);
    }
    if (@after2000) {
        my $arrayRef = \@after2000;
        DBHandler::saveDataAfter2000($arrayRef);
    }
}

sub keysAreValid {
    if ((any { $_ eq "City" } @_) &&
        (any { $_ eq "First Name" } @_) &&
        (any { $_ eq "Date of Birth" } @_) &&
        (any { $_ eq "Last Name" } @_)) {
        return 1;
    } else {
        return 0;
    }
}

1;