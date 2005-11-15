package Test::JSON;

use warnings;
use strict;
use Carp;
use Test::Builder;
use Test::Differences;
use JSON;

=head1 NAME

Test::JSON - Test JSON data

=head1 VERSION

Version 0.02

=cut

our $VERSION = '0.02';

my $TEST = Test::Builder->new;
my $JSON = JSON->new(
    pretty => 1,
    indent => 2,
);

sub import {
    my $self   = shift;
    my $caller = caller;

    my @subs = qw/is_json is_valid_json/;
    foreach my $sub (@subs) {
        no strict 'refs';
        *{"${caller}::$sub"} = \&{$sub};
    }

    $TEST->exported_to($caller);
    $TEST->plan(@_);
}

=head1 SYNOPSIS

 use Test::JSON;

 is_valid_json $json,                 '... json is well formed';
 is_json       $json, $expected_json, '... and it matches what we expected';

=head1 EXPORT

=over 4

=item * is_valid_json

=item * is_json

=back

=head1 DESCRIPTION

JavaScript Object Notation (JSON) is a lightweight data interchange format.
L<Test::JSON> makes it easy to verify that you have built valid JSON and that
it matches your expected output.

See L<http://www.crockford.com/JSON/> for more information.

=head1 TESTS

=head2 is_valid_json

 is_valid_json $json, '... json is well formed';

Test passes if the string passed is valid JSON.

=head2 is_json

 is_json $json, $expected_json, '... and it matches what we expected';

Test passes if the two JSON strings are valid JSON and evaluate to the same
data structure.

L<Test::Differences> is used to provide easy diagnostics of why the JSON
structures did not match.  For example:

   Failed test '... and identical JSON should match'
   in t/10testjson.t at line 14.
 +----+---------------------------+---------------------------+
 | Elt|Got                        |Expected                   |
 +----+---------------------------+---------------------------+
 |   0|{                          |{                          |
 |   1|  bool => '1',             |  bool => '1',             |
 |   2|  description => bless( {  |  description => bless( {  |
 |   3|    value => undef         |    value => undef         |
 |   4|  }, 'JSON::NotString' ),  |  }, 'JSON::NotString' ),  |
 |   5|  id => '1',               |  id => '1',               |
 *   6|  name => 'foo'            |  name => 'fo'             *
 |   7|}                          |}                          |
 +----+---------------------------+---------------------------+

=cut

sub is_valid_json ($;$) {
    my ( $input, $test_name ) = @_;
    croak "usage: is_valid_json(input,test_name)"
      unless defined $input;
    eval { $JSON->jsonToObj($input) };
    if ( my $error = $@ ) {
        $TEST->ok( 0, $test_name );
        $TEST->diag("Input was not valid JSON:\n\n\t$error");
        return;
    }
    else {
        $TEST->ok( 1, $test_name );
        return 1;
    }
}

sub is_json ($$;$) {
    my ( $input, $expected, $test_name ) = @_;
    croak "usage: is_json(input,expected,test_name)"
      unless defined $input && defined $expected;

    my %json_for;
    foreach my $item ( [ input => $input ], [ expected => $expected ] ) {
        my $json = eval { $JSON->jsonToObj( $item->[1] ) };
        if ( my $error = $@ ) {
            $TEST->ok( 0, $test_name );
            $TEST->diag("$item->[0] was not valid JSON: $error");
            return;
        }
        else {
            $json_for{ $item->[0] } = $json;
        }
    }
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    eq_or_diff( $json_for{input}, $json_for{expected}, $test_name );
}

=head1 AUTHOR

Curtis "Ovid" Poe, C<< <ovid@cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-test-json@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Test-JSON>.
I will be notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 SEE ALSO

This test module uses L<JSON> and L<Test::Differences>.

=head1 ACKNOWLEDGEMENTS

The development of this module was sponsored by Kineticode,
L<http://www.kineticode.com/>, the leading provider of services for the
Bricolage content management system, L<http://www.bricolage.cc/>.

=head1 COPYRIGHT & LICENSE

Copyright 2005 Curtis "Ovid" Poe, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;    # End of Test::JSON