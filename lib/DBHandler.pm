package DBHandler;
use strict;
use warnings FATAL => 'all';
use DBConfig;
use DBI;

my $dbh;
my $config = DBConfig->config();

# Database connection parameters
my $database = $config->{database};
my $host     = $config->{host};
my $port     = $config->{port};
my $dbUser     = $config->{user};
my $dbPassword = $config->{password};

sub connectToDB {
    $dbh = DBI->connect("DBI:mysql:database=$database;host=$host;port=$port", $dbUser, $dbPassword, {RaiseError => 1});
    if(!$dbh) {
        print "ERROR connecting to DB\n";
    } else {
    }
}

sub disconnectFromDB {
    if ($dbh) {
        $dbh->disconnect;
    }
}

sub getAllUsers {
    &connectToDB;
    my $sql = "SELECT * FROM user";
    my $sth = $dbh->prepare($sql);
    $sth->execute();

    my @users;
    while (my $row = $sth->fetchrow_hashref) {
        push @users, $row;
    }
    &disconnectFromDB;
    @users;
}

sub getAllRawData {
    &connectToDB;
    my $sql = "SELECT * FROM RAW_DATA";
    my $sth = $dbh->prepare($sql);
    $sth->execute();

    my @raw_data;
    while (my $row = $sth->fetchrow_hashref) {
        push(@raw_data, $row);
    }
    &disconnectFromDB;
    @raw_data;
}

sub saveDataBefore2000 {
    &connectToDB;
    my ($dataRef) = shift;
    my @data = @$dataRef;

    my $insert_query = "INSERT INTO FILTERED_DATA_BEFORE_2000 (FIRST_NAME, LAST_NAME, CITY, DATE_OF_BIRTH) VALUES (?, ?, ?, ?)";
    my $insert_stmt = $dbh->prepare($insert_query);
    foreach my $record (@data) {
        $insert_stmt->execute($record->{"First Name"}, $record->{"Last Name"}, $record->{"City"}, $record->{"Date of Birth"});
    }
    $insert_stmt->finish();
    &disconnectFromDB;
}

sub saveDataAfter2000 {
    &connectToDB;
    my ($dataRef) = shift;
    my @data = @$dataRef;

    my $insert_query = "INSERT INTO FILTERED_DATA_AFTER_2000 (FIRST_NAME, LAST_NAME, CITY, DATE_OF_BIRTH) VALUES (?, ?, ?, ?)";
    my $insert_stmt = $dbh->prepare($insert_query);
    foreach my $record (@data) {
        $insert_stmt->execute($record->{"First Name"}, $record->{"Last Name"}, $record->{"City"}, $record->{"Date of Birth"});
    }
    $insert_stmt->finish();
    &disconnectFromDB;
}

sub createUser {
    &connectToDB;
    my ($class, $username, $email, $password) = @_;
    my $insert_sql = "INSERT INTO user (username, email, password) VALUES (?, ?, ?)";
    my $insert_sth = $dbh->prepare($insert_sql);
    $insert_sth->execute($username, $email, $password);
    &disconnectFromDB;
}

sub deleteUser {
    &connectToDB;
    my ($class, $id) = @_;
    my $delete_sql = "DELETE FROM user WHERE user_id = ?";
    my $delete_sth = $dbh->prepare($delete_sql);
    $delete_sth->execute($id);
    &disconnectFromDB;
}

sub updateUser {
    &connectToDB;
    my ($class, $username, $email, $password, $id) = @_;
    my $update_sql = "UPDATE user t SET t.username = ?, t.email    = ?, t.password = ? WHERE t.user_id = ?;";
    my $update_sth = $dbh->prepare($update_sql);
    $update_sth->execute($username, $email, $password, $id);
    &disconnectFromDB;
}

sub getOrdersByUserId {
    &connectToDB;
    my ($class, $userId) = @_;
    my $sql = "SELECT * FROM `order` WHERE user_id = ?";
    my $sth = $dbh->prepare($sql);
    $sth->execute($userId);

    my @orders;
    while (my $row = $sth->fetchrow_hashref) {
        push(@orders, $row);
    }
    &disconnectFromDB;
    @orders
}

sub getAllUsersWithOrders {
    &connectToDB;
    my $sql = "SELECT
        u.user_id AS 'UserID',
        u.username AS 'Username',
        o.product_name AS 'Product',
        o.quantity AS 'Quantity'
        FROM `user` u
        JOIN `order` o ON u.user_id = o.user_id;";
    my $sth = $dbh->prepare($sql);
    $sth->execute();

    my @usersWithOrders;
    while (my $row = $sth->fetchrow_hashref) {
        push @usersWithOrders, $row;
    }
    &disconnectFromDB;
    @usersWithOrders;
}