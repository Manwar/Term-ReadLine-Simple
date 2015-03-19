use 5.008003;
use warnings;
use strict;
use Test::More;
use FindBin               qw( $RealBin );
use File::Spec::Functions qw( catfile );

BEGIN {
    if ( $^O eq 'MSWin32' ) {
        plan skip_all => "MSWin32: Expect not available.";
    }
    #if ( ! $ENV{TESTS_USING_EXPECT_OK} ) {
    #    plan skip_all => "Environment variable 'TESTS_USING_EXPECT_OK' not enabled.";
    #}
}

eval "use Expect";
if ( $@ ) {
    plan skip_all => $@;
}

use lib $RealBin;
use Data_Test_Arguments;

( my $nr = __FILE__ )=~ s/.+_invalid_arguments_readline_(\d+)\.t\z/$1/;

my $command = $^X;
my $script = catfile $RealBin, 'readline_invalid_args.pl';
my @parameters  = ( $script, $nr );

my $exp;
eval {
    $exp = Expect->new();
    $exp->raw_pty( 1 );
    $exp->log_stdout( 0 );
    $exp->slave->clone_winsize_from( \*STDIN );
    $exp->spawn( $command, @parameters ) or die "Spawn '$command @parameters' NOT ok $!";
    1;
}
or plan skip_all => $@;

my $a_ref = Data_Test_Arguments::invalid_args();
my $expected = $a_ref->[$nr]{expected};

$exp->send( "\n" );
my $ret = $exp->expect( 2, [ qr/<.+>/ ] );

ok( $ret, 'matched something' );

my $result = $exp->match();
$result = '' if ! defined $result;
$expected =~ s/>\z//;
ok( $result =~ /^\Q$expected\E.+>/, "expected: '$expected', got: '$result'" );


$exp->hard_close();

done_testing();