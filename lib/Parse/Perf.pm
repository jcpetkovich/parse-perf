package Parse::Perf;

use v5.12;
use strict;
use warnings FATAL => 'all';
use Carp;
use autodie;
use Exporter 'import';

=head1 NAME

Parse::Perf - The great new Parse::Perf!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Quick summary of what the module does.

=head1 EXPORT

write_outfile parse_perf parse_and_dump

=cut

our @EXPORT = qw( write_outfile parse_perf parse_and_dump );

our @HEADER =
  qw(perf_counter_name perf_counter_value perf_counter_throughput perf_scaling_percent);

=head1 SUBROUTINES/METHODS

=head2 write_line

Write one line of the output csv from a given set of data

=cut

sub write_line {
    my ( $oh, $datum ) = @_;
    say $oh join( ",",
        map { defined( $datum->{$_} ) ? $datum->{$_} : "" }
          qw( name value extra_data percentage ) );
}

=head2 write_outfile

Write the output in a CSV like way.

=cut

sub write_outfile {
    my ( $oh, @data ) = @_;

    print $oh join( ',', @HEADER ), "\n";
    for my $datum (@data) {
        write_line $oh, $datum;
    }
}

=head2 tokenize_perf

Tokenize the file

=cut

sub tokenize_perf {
    my ( $remainder, $fh ) = @_;

    my $line;
    if ($remainder) {
        $line = $remainder;
    }
    else {
        $line = <$fh>;
    }

    my ( @entry, $remaining );

    # If line looks like an entry
    if ( $line =~ /^\s+\d+/ ) {
        push @entry, $line;

        # if it isn't complete, read another line
        unless ( $line =~ /\[/ ) {
            $line = <$fh>;

            # is it the start of another entry?
            if ( $line =~ /^\s+\d+/ ) {

                # It's a new entry
                $remaining = $line;
            }
            elsif ( $line =~ /\[/ ) {

                # It's completing a previous entry
                push @entry, $line;
            }
        }
    }

    return ( [@entry], $remaining );
}

=head2 parse_perf

Parse one entry of perf output. The perf entry could span multiple
lines.

Returns a hash table of the data or undef if no data was found.

=cut

sub parse_perf {
    my ($entry) = @_;

    return if @$entry == 0;
    my $line = $entry->[0];

    # If line looks like an entry
    if ( $line =~ /^\s+\d+/ ) {
        my %data;

        my ( $value, $measurement_name ) = $line =~ /^\s+([\d\.,]+)\s+(\S+)/;

        $value =~ s/,//g;    # No american style numbers please

        $data{value} = $value;

        # Lowercase the name, because perf is inconsistent
        $data{name} = lc $measurement_name;

        # Sometimes split across two lines
        $line = $entry->[1] unless @$entry == 1;

        if ( my ($extra_data) = $line =~ /#\s+([\d\.,]+)/ ) {
            $data{extra_data} = $extra_data;
        }
        if ( my ($percentage) = $line =~ /\[(.*)%\]/ ) {
            $data{percentage} = $percentage;
        }
        return %data;
    }
    return;
}

=head2 parse_and_dump

Parse the file of the given name and dump it to a file of the same
name with the csv extension added.

=cut

sub parse_and_dump {
    my ( $filename, $outfile ) = @_;

    $outfile = $filename . ".csv" unless $outfile;

    open my $fh, "<", $filename;
    open my $oh, ">", $outfile;
    print $oh join( ',', @HEADER ), "\n";
    my $remainder;
    use Data::Dumper;
    while ( not eof $fh ) {

        my $entry;
        ( $entry, $remainder ) = tokenize_perf $remainder, $fh;

        if ( my %data = parse_perf($entry) ) {
            write_line $oh, {%data};
        }
    }
    close $fh;
    close $oh;

}

=head1 AUTHOR

Jean-Christophe Petkovich, C<< <jcpetkovich at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-parse-perf at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Parse-Perf>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Parse::Perf


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Parse-Perf>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Parse-Perf>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Parse-Perf>

=item * Search CPAN

L<http://search.cpan.org/dist/Parse-Perf/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Jean-Christophe Petkovich.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

1;    # End of Parse::Perf
