#!/usr/bin/perl -w
# parse-perf.pl --- Parses Linux perf output.
# Author: Jean-Christophe Petkovich <jcpetkovich@gmail.com>
# Created: 28 Apr 2013
# Version: 0.01

use v5.12;
use warnings;
use strict;
use Getopt::Long qw( :config auto_help );
use Carp;
use autodie;

my $filename;
my $outfile = "out.csv";

GetOptions( "outfile|o=s" => \$outfile );

if ( @ARGV != 1 ) {
    croak "Should have one input file argument";
}

$filename = shift @ARGV;
open my $fh, "<", $filename;
my @data;
while ( not eof $fh ) {
    if ( my %data = parse_perf($fh) ) {
        push @data, {%data};
    }
}
close $fh;

open my $oh, ">", $outfile;
print $oh "name,value,extra,percent\n";
for my $datum (@data) {
    say $oh join( ",",
        map { defined( $datum->{$_} ) ? $datum->{$_} : "" }
          qw( name value extra_data percentage ) );
}

close $oh;

sub parse_perf {
    my ($fh) = @_;
    my $line = <$fh>;

    # If line looks like an entry
    if ( $line =~ /^\s+\d+/ ) {
        my %data;

        my ( $value, $measurment_name ) = $line =~ /^\s+([\d\.]+)\s+(\S+)/;
        $data{value} = $value;
        $data{name}  = $measurment_name;

        # Sometimes split across two lines
        $line = <$fh> unless $line =~ /#/;

        if ( my ($extra_data) = $line =~ /#\s+([\d\.]+)/ ) {
            $data{extra_data} = $extra_data;
        }
        if ( my ($percentage) = $line =~ /\[(.*)%\]/ ) {
            $data{percentage} = $percentage;
        }
        return %data;
    }
    return;
}

__END__

=head1 NAME

parse-perf.pl - Parses Linux perf output and dumps it to a CSV.

=head1 SYNOPSIS

parse-perf.pl [options] infile

      -h --help             Print this help documentation.
      -o --outfile outfile  Specify output file.

=head1 DESCRIPTION

Parses Linux perf output and dumps it to a CSV.

=head1 AUTHOR

Jean-Christophe Petkovich, E<lt>jcpetkovich@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Jean-Christophe Petkovich

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut
