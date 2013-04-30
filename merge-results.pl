#!/usr/bin/perl -w
# merge-results.pl --- Merge datamill results.
# Author: Jean-Christophe Petkovich <jcpetkovich@gmail.com>
# Created: 29 Apr 2013
# Version: 0.01

use v5.12;
use warnings;
use strict;
use Text::CSV;
use Getopt::Long qw( :config auto_help );
use Carp;
use Archive::Any;
use File::Spec::Functions qw( catfile rootdir );
use File::Find::Rule;
use Try::Tiny;
use autodie;
use Data::Dumper;

GetOptions();

my $directory = '.';

$directory = shift @ARGV if @ARGV > 0;

my $rule = File::Find::Rule->new;

sub get_job_row {
    my ($job_id) = @_;

    my $file =
      shift $rule->new->find()->name("*_results_index.csv")->in($directory);

    my $fh = IO::File->new( $file, "r" );
    my $csv = Text::CSV->new( { binary => 1, auto_diag => 1 } );
    while ( my $row = $csv->getline($fh) ) {
        if ( $row->[1] =~ /$job_id/ ) {
            return $row;
        }
    }
}

sub parse_job_file {

    my ($job_tar_ball) = @_;

    my $job_dir = $job_tar_ball =~ s/\.tar\.gz$//r;
    say $job_tar_ball;
    try {
        mkdir $job_dir;
    };

    my $archive = Archive::Any->new($job_tar_ball);
    $archive->extract($job_dir);

    my @logs = $rule->new->file()->name("*.txt")->in($job_dir);

    for my $file (@logs) {
        my $output = $file =~ s/\.txt/\.csv/r;
        `parse-perf $file -o $output`;
    }
}

sub consolidate_data {
    my ($job_dir) = @_;

    my @files = $rule->new->file()->name("*.csv")->in($directory);

    for my $file (@files) {
        my $csv = Text::CSV->new( { binary => 1, auto_diag => 1 } );
        my $fh = IO::File->new( $file, "r" );
        my $header = $csv->getline($fh);
        my %data;
        while ( my $row = $csv->getline($fh) ) {
            push @data, $row->[0], $row->[0]
        }
    }
}

for my $tarfile ( $rule->new->file()->name("*.tar.gz")->in($directory) ) {
    $tarfile = catfile( $directory, $tarfile );
    parse_job_file($tarfile);
}

for my $job_dir ( $rule->new->directory()->in($directory) ) {
    $job_dir = catfile( $directory, $job_dir );
    consolidate_data($job_dir);
}

__END__

=head1 NAME

merge-results.pl - Describe the usage of script briefly

=head1 SYNOPSIS

merge-results.pl [options] args

      -opt --long      Option description

=head1 DESCRIPTION

Stub documentation for merge-results.pl, 

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
