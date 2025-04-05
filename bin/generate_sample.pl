#!/usr/bin/env perl
use 5.10.0;
use utf8;
use strict;
use warnings;
use open qw( :utf8 :std );
use Data::Dumper;
use Time::Piece qw( );
use Time::Seconds qw( ONE_DAY ONE_HOUR ONE_MINUTE );
use JSON;
use Data::UUID;
use Readonly;

Readonly my $TIME_BOX_DAYS => 40;
Readonly my $MEASUREMENT_DAYS => 40;
Readonly my $IMAGE_COLOR_SIZE => 40;
Readonly my $RANDOM_COUNT_TIME_BOXES_PER_DAY => 7;
Readonly my $RANDOM_COUNT_MEASUREMENTS_PER_DAY => 10;

my $ug = Data::UUID->new;

my @time_boxes = map { time_boxes( $_, 5 + int( 7 * rand ) ) }
                 map { scalar Time::Piece->localtime( time - $_ * ONE_DAY ) }
                 reverse
                 1 .. $TIME_BOX_DAYS;
my @image_colors = map { { name => $_, color => random_color( ) } }
                   unique_works( map { random_work( ) } 1 .. $IMAGE_COLOR_SIZE );
my @measurements = map { measurements( $_, \@image_colors, int( $RANDOM_COUNT_MEASUREMENTS_PER_DAY * rand ) ) }
                   map { scalar Time::Piece->localtime( time - $_ * ONE_DAY ) }
                   reverse
                   1 .. $MEASUREMENT_DAYS;

say JSON->new->encode( {
    timeBoxes => \@time_boxes,
    imageColors => \@image_colors,
    measurements => \@measurements,
} );


exit;

sub measurements {
    my $date = shift;
    my @image_colors = @{ shift( ) };
    my $count = shift;
    my @characters = "a" .. "z";

    return map {
        my $image_color = $image_colors[ @image_colors * rand ];
        my $start = ( $date - ( $date->epoch % ONE_DAY ) ) + ( 8 + $_ * ONE_HOUR );
        my $end = $start + 45 * ONE_MINUTE;
        {
            id => $ug->to_string( $ug->create ),
            work => $image_color->{name},
            detail => join( q{}, map { $characters[ @characters * rand ] } 1 .. ( 1 + 8 * rand ) ),
            start => $start->datetime . ".000+09:00",
            end => $end->datetime . ".000+09:00",
        };
    } 1 .. $count;
}

sub random_color {
    return [ map { int( rand( ) * 10 + 0.5 ) / 10 } 1 .. 3 ];
}

sub unique_works {
    my @works = @_;
    my %count;
    return grep { !$count{ $_ }++ } @works;
}

sub random_work {
    my @characters = "a" .. "z";
    return join q{}, map { $characters[ $_ ] } map { int( rand( ) * @characters ) } 1 .. ( 1 + rand( ) * 6 );
}

sub time_boxes {
    my $time = shift;
    my $count = shift;

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
