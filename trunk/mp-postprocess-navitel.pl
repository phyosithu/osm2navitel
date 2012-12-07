#!/usr/bin/perl

use strict;
use utf8;
use Getopt::Long;

my $fixrouting  = 0;
my $killrouting = 0;
my $fixrestrictions = 1;
my $shorten = 1;
GetOptions (
    'fixrouting!'  => \$fixrouting,
    'killrouting!'  => \$killrouting,
    'fixrestrictions!'  => \$fixrestrictions,
    'shorten!'  => \$shorten
);

if ( $killrouting ) { $fixrouting = 0; $fixrestrictions = 0;}

my $traffpoints;
my $traffroads;
my $restrparam;

my $file = shift @ARGV;
exit unless $file;

rename $file, "$file.old";

open my $in,  '<:encoding(cp1251)', "$file.old";
open my $out, '>:encoding(cp1251)', $file;

my $err;
if ( $fixrouting ) {
    open $err, '>', "$file.err.htm";
    }

my $bitlevel = 24;
my $mpfmt = "%.5f" ;
my @points;
my %nodes;

my @short = (
    [ 'ул(|ица)'                =>  'ул.'    ],
    [ 'пер(|еул|еулок)'         =>  'пер.'   ],
    [ 'пр(\-к?т|осп|оспект)'    =>  'пр-т'   ],
    [ 'пр(\-з?д|оезд)'          =>  'пр-д'   ],
    [ 'п()'                     =>  'п.'     ],
    [ 'пр()'                    =>  'пр.'    ],
    [ 'пл(|ощадь)'              =>  'пл.'    ],
    [ 'ш(|оссе)'                =>  'ш.'     ],
    [ 'туп(|ик)'                =>  'туп.'   ],
    [ 'б(ул|ульв|-р|ульвар)'    =>  'б-р'    ],
    [ 'наб(|ережная)'           =>  'наб.'   ],
    [ 'ал(|лея)'                =>  'ал.'    ],
    [ 'мост()'                  =>  'мост'   ],
    [ 'тракт()'                 =>  'тракт'  ],
    [ 'просек()'                =>  'просек' ],
    [ 'линия()'                 =>  'линия'  ],
    [ 'кв(|арт|артал)'          =>  'кв.'  ],
    [ 'м(к?рн?|икрорайон)'      =>  'мкр'  ],
);


my $object;

LINE:
while ( my $line = readline $in ) {

    if ($line =~ /^Level0/i) {
        my ($levelname, $bits) = split /=/,$line;
        $bitlevel = $bits;
        my $mpfmt = $bitlevel > 24 ? "%.6f" : "%.5f" ;
    }

    if ( $line =~ /^\[(.*)\]/ ) {
        $object = $1;
    }

    if ( $line =~ /^(CodePage)/i ) {
        $line =~ s/utf8/65001/;
    }
    
    # ISO region names
    if ( $line =~ /^(DefaultRegionCountry|RegionName)/i ) {
        $line =~ s/область/обл./;
        $line =~ s/район/р-н/;
        $line =~ s/Автономный округ - Югра автономный округ/АО (Югра)/;
        $line =~ s/Кабардино-Балкарская республика/Кабардино-Балкария/;
        $line =~ s/Карачаево-Черкесская республика/Карачаево-Черкесия/;
        $line =~ s/автономный округ/АО/i;
        $line =~ s/автономная обл./АО/i;
        $line =~ s/город //i;
        $line =~ s/([ие]я|[^я]) республика/$1/i;
        $line =~ s/ - Алания//;
    }

    if ( $line =~ /^(Label|StreetDesc|CityName|RegionName)=/i ) {
        $line =~ s/городской округ/ГО/ig;
        $line =~ s/муниципальное образование/МО/ig;
        $line =~ s/[«»"]//g;
        $line =~ s/&#xD;//g;
        #Change Cyrillic IO to IE
        if ( $shorten ) { $line =~ y/Ёё/Ее/ }
    }


    #   street names
    if ( $shorten ) {
    my $tag;
    if ( $object eq 'POLYLINE' && ( ($tag) = $line =~ /^(Label\d?)=/i ) 
            or ( ($tag) = $line =~ /^(StreetDesc)=/i ) ) {
        
        $line = join q{ }, map { ucfirst } grep { $_ } split / /, $line;
        
        SUFF:
        for my $short ( @short ) {
            my ( $s, $r ) = @$short;
            next SUFF unless
                my ( undef, $prefix, undef, undef, undef, $postfix )
                    = $line =~ /=((.*\S)?\s+)?$s((\s+|\s*\.\s*)(.*))?$/i;
            
            next SUFF unless $prefix || $postfix;
            
            $line = "$prefix $postfix";

            $line =~ s/(\d+-?.?[йяе])(\s+(.*))/$2 $1/;
            $line =~ s/(\d+)-?.?([йяе])(\s.*)?$/$1-$2/;

            $line =~ s/\s\s+/ /;
            $line =~ s/^ //;
            $line =~ s/ $//;

            $line = "$tag=" . $line . " " . $r . "\n";
            last SUFF;
        }
    }}


    if ( $line =~ /^(Text)=/i ) { #часы работы
        $line =~ s/Mo/Пн/;
        $line =~ s/Tu/Вт/;
        $line =~ s/We/Ср/;
        $line =~ s/Th/Чт/;
        $line =~ s/Fr/Пт/;
        $line =~ s/Sa/Сб/;
        $line =~ s/Su/Вс/;
    }

    if ( $line =~ /^(HouseNumber)=/i ) { #Fix HouseNumber=00 bug
        $line =~ s/=00$/=\-/;
    }

    # remove empty labels and notes
    next if ($line =~ /^(Label|Text)=$/i);

    # fix routing
    if ($fixrouting && $line =~ /^Data\d+/) {
        (@points) = ($line =~ /(-?\d+\.?\d*,-?\d+\.?\d*)/g);
    }
    if ($fixrouting && $line =~ /^Nod\d+/) {
        my ($nodname, $pos, $nodid, $nodtype) = split /[=,]/,$line;
        my ($lat, $lon) = split /,/, $points[$pos];
        my ($mplat, $mplon) = (sprintf ($mpfmt, $lat), sprintf ($mpfmt, $lon));
        if ($nodes{($mplat, $mplon)} && $nodes{($mplat, $mplon)} != $nodid) {
            $line = "$nodname=$pos,$nodes{($mplat, $mplon)},$nodtype" ;
            print "Fixed duplicate nodes $nodid and $nodes{($mplat, $mplon)} near $lat,$lon / $mplat,$mplon\n";
            my $left=$lon-0.0003; my $right=$lon+0.0003; my $top=$lat+0.0002; my $bottom=$lat-0.0002;
            print $err "Duplicate nodes near <a href=http://www.openstreetmap.org/?lat=$lat&lon=$lon&zoom=18>$lat,$lon</a> <a href=http://127.0.0.1:8111/load_and_zoom?left=$left&right=$right&top=$top&bottom=$bottom>**</a><br>\n";
        }
        else { $nodes{($mplat, $mplon)} = $nodid }
    }

    # kill routing
    next if ($killrouting && $line =~ /^(Nod\d*=|\[Restrict\]|TraffPoints|TraffRoads|RestrParam|\[END-Restrict\])/i);

    # remove restrictions except those for cars
    if ($fixrestrictions) {
        if ($line =~ /^\[Restrict\]/i) {$restrparam = "0,0,0,0,0,0,0,0"; next;}
        if ($line =~ /^TraffPoints/i) {$traffpoints = $line; next;}
        if ($line =~ /^TraffRoads/i) {$traffroads = $line; next;}
        if ($line =~ /^RestrParam/i) {$restrparam = $line; next}
        if ($line =~ /^\[END-Restrict\]/i) {
            if ($restrparam =~ /.,.,0,.,.,.,./) {
                print $out "[Restrict]\n";
                print $out $traffpoints;
                print $out $traffroads;
                print $out "[END-Restrict]\n";
                }
            next;
        }
    }

    print $out $line;
}

close $in;
close $out;
if ( $fixrouting ) {
    close $err;
    }

unlink "$file.old";
