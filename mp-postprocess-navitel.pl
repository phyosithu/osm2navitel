#!/usr/bin/perl

use strict;
use utf8;
use Getopt::Long;

my $fixrouting  = 0;
my $killrouting = 0;
my $fixrestrictions = 0;
GetOptions (
    'fixrouting!'  => \$fixrouting,
    'killrouting!'  => \$killrouting,
    'fixrestrictions!'  => \$fixrestrictions,
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
    
    #   region name
    if ( $line =~ /^(DefaultRegionCountry|RegionName)/i ) {
        $line =~ s/altayskiy/Алтайский край/;
        $line =~ s/amur/Амурская область/;
        $line =~ s/arkhan/Архангельская область/;
        $line =~ s/astrakhan/Астраханская область/;
        $line =~ s/belgorod/Белгородская область/;
        $line =~ s/bryansk/Брянская область/;
        $line =~ s/vladimir/Владимирская область/;
        $line =~ s/volgograd/Волгоградская область/;
        $line =~ s/vologda/Вологодская область/;
        $line =~ s/voronezh/Воронежская область/;
        $line =~ s/evrey/Еврейская автономная область/;
        $line =~ s/zabaikal/Забайкалький край /;
        $line =~ s/ivanov/Ивановская область/;
        $line =~ s/irkutsk/Иркутская область/;
        $line =~ s/kabardin/Кабардино-Балкарская Республика/;
        $line =~ s/kalinin/Калининградская область/;
        $line =~ s/kaluzh/Калужская область/;
        $line =~ s/kamch/Камчатский край/;
        $line =~ s/karach/Карачаево-Черкесская Республика/;
        $line =~ s/kemerovo/Кемеровская область/;
        $line =~ s/kirov/Кировская область/;
        $line =~ s/kostrom/Костромская область/;
        $line =~ s/krasnodar/Краснодарский край/;
        $line =~ s/krasnoyarsk/Красноярский край/;
        $line =~ s/kurgan/Курганская область/;
        $line =~ s/kursk/Курская область/;
        $line =~ s/leningrad/Ленинградская область/;
        $line =~ s/stpeter/Санкт-Петербург/;
        $line =~ s/lipetsk/Липецкая область/;
        $line =~ s/magadan/Магаданская область/;
        $line =~ s/mosobl/Московская область/;
        $line =~ s/moscow/Москва/;
        $line =~ s/murmansk/Мурманская область/;
        $line =~ s/nenec/Ненецкий автономный округ/;
        $line =~ s/nizhegorod/Нижегородская область/;
        $line =~ s/novgorod/Новгородская область/;
        $line =~ s/novosib/Новосибирская область/;
        $line =~ s/omsk/Омская область/;
        $line =~ s/orenburg/Оренбургская область/;
        $line =~ s/orlovsk/Орловская область/;
        $line =~ s/penz/Пензенская область/;
        $line =~ s/perm/Пермский край/;
        $line =~ s/prim/Приморский край/;
        $line =~ s/pskov/Псковская область/;
        $line =~ s/adygeya/Республика Адыгея/;
        $line =~ s/altay$/Республика Алтай/;
        $line =~ s/bashkir/Республика Башкортостан/;
        $line =~ s/buryat/Республика Бурятия/;
        $line =~ s/dagestan/Республика Дагестан/;
        $line =~ s/ingush/Республика Ингушетия/;
        $line =~ s/kalmyk/Республика Калмыкия/;
        $line =~ s/karel/Республика Карелия/;
        $line =~ s/komi/Республика Коми/;
        $line =~ s/mariyel/Республика Марий Эл/;
        $line =~ s/mordov/Республика Мордовия/;
        $line =~ s/yakut/Республика Саха (Якутия)/;
        $line =~ s/osetiya/Республика Северная Осетия - Алания/;
        $line =~ s/tatar/Республика Татарстан/;
        $line =~ s/tyva/Республика Тыва/;
        $line =~ s/khakas/Республика Хакасия/;
        $line =~ s/rostov/Ростовская область/;
        $line =~ s/ryazan/Рязанская область/;
        $line =~ s/samar/Самарская область/;
        $line =~ s/saratov/Саратовская область/;
        $line =~ s/sakhalin/Сахалинская область/;
        $line =~ s/sverdl/Свердловская область/;
        $line =~ s/smol/Смоленская область/;
        $line =~ s/stavrop/Ставропольский край/;
        $line =~ s/tambov/Тамбовская область/;
        $line =~ s/tver/Тверская область/;
        $line =~ s/tomsk/Томская область/;
        $line =~ s/tul/Тульская область/;
        $line =~ s/tumen/Тюменская область/;
        $line =~ s/udmurt/Удмуртская Республика/;
        $line =~ s/ulyan/Ульяновская область/;
        $line =~ s/khabar/Хабаровский край/;
        $line =~ s/khanty/Ханты-Мансийский автономный округ/;
        $line =~ s/chel/Челябинская область/;
        $line =~ s/chechen/Чеченская Республика/;
        $line =~ s/chuvash/Чувашская Республика/;
        $line =~ s/chukot/Чукотский автономный округ/;
        $line =~ s/yamal/Ямало-Ненецкий автономный округ/;
        $line =~ s/yarosl/Ярославская область/;
        $line =~ s/Ukraine/Украина/; #районы Украины
        $line =~ s/Ukraine-Cherkasy/Черкаська область/;
        $line =~ s/Ukraine-Chernigov/Чернігівська область/;
        $line =~ s/Ukraine-Chernovitsk/Чернівецька область/;
        $line =~ s/Ukraine-Dnepropetrovsk/Дніпропетровська область/;
        $line =~ s/Ukraine-Donetsk/Донецька область/;
        $line =~ s/Ukraine-Ivano-Frankivsk/Івано-Франківська область/;
        $line =~ s/Ukraine-Kharkiv/Харківська область/;
        $line =~ s/Ukraine-Kherson/Херсонська область/;
        $line =~ s/Ukraine-Khmelnytskyi/Хмельницька область/;
        $line =~ s/Ukraine-Kirovograd/Кіровоградська область/;
        $line =~ s/Ukraine-Krym/АР Крим/;
        $line =~ s/Ukraine-Kyiv/Київська область/;
        $line =~ s/Ukraine-Lugansk/Луганська область/;
        $line =~ s/Ukraine-Lviv/Львівська область/;
        $line =~ s/Ukraine-Mykolaiv/Миколаївська область/;
        $line =~ s/Ukraine-Odesa/Одеська область/;
        $line =~ s/Ukraine-Poltava/Полтавська область/;
        $line =~ s/Ukraine-Rivne/Рівненська область/;
        $line =~ s/Ukraine-Sumskaya/Сумська область/;
        $line =~ s/Ukraine-Ternopil/Тернопільська область/;
        $line =~ s/Ukraine-Vinnitska/Вінницька область/;
        $line =~ s/Ukraine-Volyn/Волинська область/;
        $line =~ s/Ukraine-Zakarpatsk/Закарпатська область/;
        $line =~ s/Ukraine-Zaporozhsk/Запорізька область/;
        $line =~ s/Ukraine-Zhytomyr/Житомирська область/;
        # fix region names
        $line =~ s/область/обл./;
        $line =~ s/район/р-н/;
        $line =~ s/Автономный округ - Югра автономный округ/АО (Югра)/;
        $line =~ s/Кабардино-Балкарская республика/Кабардино-Балкария/;
        $line =~ s/Карачаево-Черкесская республика/Карачаево-Черкесия/;
        $line =~ s/автономный округ/АО/i;
        $line =~ s/автономная обл./АО/i;
        $line =~ s/ город//i;
        $line =~ s/([ие]я|[^я]) республика/$1/i;
        $line =~ s/ - Алания//;
    }

    if ( $line =~ /^(Label|StreetDesc|CityName|RegionName)=/i ) {
        $line =~ s/городской округ/ГО/ig;
        $line =~ s/муниципальное образование/МО/ig;
        $line =~ s/[«»"]//g;
        $line =~ s/&#xD;//g;
        #SYMBOLS (рудименты параметра --textfilter)
        $line =~ s/\\N{COMBINING ACUTE ACCENT}//;
        $line =~ s/\\N{MASCULINE ORDINAL INDICATOR}//;
        $line =~ s/\\N{LATIN SMALL LETTER L WITH STROKE}/l/;
        #Change Cyrillic IO to IE
        $line =~ y/Ёё/Ее/;
    }


    #   street names
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
    }


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

    # fix routing
    if ($fixrouting && $line =~ /^Data\d+/) {
        (@points) = ($line =~ /(-?\d+\.\d+,-?\d+\.\d+)/g);
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
