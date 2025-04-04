#!/usr/bin/env perl
use 5.10.0;
use utf8;
use strict;
use warnings;
use open qw( :utf8 :std );
use Data::Dumper;
use Time::Piece qw( );
use Time::Seconds qw( ONE_DAY ONE_HOUR );
use JSON;

my @timeBoxes = map { timeBoxes( $_ ) }
                map { scalar Time::Piece->localtime( time - $_ * ONE_DAY ) }
                reverse
                1 .. 40;
die Dumper \@timeBoxes;


exit;

sub timeBoxes {
    my $time = shift;
    my $count = 5 + int( 7 * rand );

    return map {
        my $now = $time - ( $time->epoch % ONE_DAY ) + $_ * ONE_HOUR;
        { workMinutes => 30, start => $now->datetime . ".000+09:00" };
    } 1 .. $count;
}

__END__
{
    timeBoxes: [
        {
            workMinutes: 3,
            start: "2025-03-07T20:45:35.812+09:00",
        },
    ],
    imageColors: [
        {
            color: [
                0.6,
                1,
                0.8
            ],
            name: "asdf",
        },
    ],
    measurements: [
        {
            "start": "2025-03-02T10:31:47.392+09:00",
            "id": "D9E2F98E-44F3-4CB6-8361-8E708BCF5837",
            "work": "asdf",
            "detail": "fdsa",
            "end": "2025-03-02T10:34:13.884+09:00"
        },
    ],
}
