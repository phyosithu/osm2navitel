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
    
    # ISO region names
    #   region names
    if ( $line =~ /^(DefaultRegionCountry|RegionName)/i ) {
        $line =~ s/RU-ALT|altayskiy/Алтайский край/;
        $line =~ s/RU-AMU|amur/Амурская область/;
        $line =~ s/RU-ARK|arkhan/Архангельская область/;
        $line =~ s/RU-AST|astrakhan/Астраханская область/;
        $line =~ s/RU-BEL|belgorod/Белгородская область/;
        $line =~ s/RU-BRY|bryansk/Брянская область/;
        $line =~ s/RU-VLA|vladimir/Владимирская область/;
        $line =~ s/RU-VGG|volgograd/Волгоградская область/;
        $line =~ s/RU-VLG|vologda/Вологодская область/;
        $line =~ s/RU-VOR|voronezh/Воронежская область/;
        $line =~ s/RU-YEV|evrey/Еврейская автономная область/;
        $line =~ s/RU-ZAB|zabaikal/Забайкалький край /;
        $line =~ s/RU-IVA|ivanov/Ивановская область/;
        $line =~ s/RU-IRK|irkutsk/Иркутская область/;
        $line =~ s/RU-KB|kabardin/Кабардино-Балкарская Республика/;
        $line =~ s/RU-KGD|kalinin/Калининградская область/;
        $line =~ s/RU-KLU|kaluzh/Калужская область/;
        $line =~ s/RU-KAM|kamch/Камчатский край/;
        $line =~ s/RU-KC|karach/Карачаево-Черкесская Республика/;
        $line =~ s/RU-KEM|kemerovo/Кемеровская область/;
        $line =~ s/RU-KIR|kirov/Кировская область/;
        $line =~ s/RU-KOS|kostrom/Костромская область/;
        $line =~ s/RU-KDA|krasnodar/Краснодарский край/;
        $line =~ s/RU-KYA|krasnoyarsk/Красноярский край/;
        $line =~ s/RU-KGN|kurgan/Курганская область/;
        $line =~ s/RU-KRS|kursk/Курская область/;
        $line =~ s/RU-LEN|leningrad/Ленинградская область/;
        $line =~ s/RU-SPE|stpeter/Санкт-Петербург/;
        $line =~ s/RU-LIP|lipetsk/Липецкая область/;
        $line =~ s/RU-MAG|magadan/Магаданская область/;
        $line =~ s/RU-MOS|mosobl/Московская область/;
        $line =~ s/RU-MOW|moscow/Москва/;
        $line =~ s/RU-MUR|murmansk/Мурманская область/;
        $line =~ s/RU-NEN|nenec/Ненецкий автономный округ/;
        $line =~ s/RU-NIZ|nizhegorod/Нижегородская область/;
        $line =~ s/RU-NGR|novgorod/Новгородская область/;
        $line =~ s/RU-NSK|novosib/Новосибирская область/;
        $line =~ s/RU-OMS|omsk/Омская область/;
        $line =~ s/RU-ORE|orenburg/Оренбургская область/;
        $line =~ s/RU-ORL|orlovsk/Орловская область/;
        $line =~ s/RU-PNZ|penz/Пензенская область/;
        $line =~ s/RU-PER|perm/Пермский край/;
        $line =~ s/RU-PRI|prim/Приморский край/;
        $line =~ s/RU-PSK|pskov/Псковская область/;
        $line =~ s/RU-AD|adygeya/Республика Адыгея/;
        $line =~ s/RU-AL$|altay$/Республика Алтай/;
        $line =~ s/RU-BA|bashkir/Республика Башкортостан/;
        $line =~ s/RU-BU|buryat/Республика Бурятия/;
        $line =~ s/RU-DA|dagestan/Республика Дагестан/;
        $line =~ s/RU-IN|ingush/Республика Ингушетия/;
        $line =~ s/RU-KL$|kalmyk/Республика Калмыкия/;
        $line =~ s/RU-KR|karel/Республика Карелия/;
        $line =~ s/RU-KO$|komi/Республика Коми/;
        $line =~ s/RU-ME|mariyel/Республика Марий Эл/;
        $line =~ s/RU-MO$|mordov/Республика Мордовия/;
        $line =~ s/RU-SA$|yakut/Республика Саха (Якутия)/;
        $line =~ s/RU-SE|osetiya/Республика Северная Осетия - Алания/;
        $line =~ s/RU-TA$|tatar/Республика Татарстан/;
        $line =~ s/RU-TY$|tyva/Республика Тыва/;
        $line =~ s/RU-KK|khakas/Республика Хакасия/;
        $line =~ s/RU-ROS|rostov/Ростовская область/;
        $line =~ s/RU-RYA|ryazan/Рязанская область/;
        $line =~ s/RU-SAM|samar/Самарская область/;
        $line =~ s/RU-SAR|saratov/Саратовская область/;
        $line =~ s/RU-SAK|sakhalin/Сахалинская область/;
        $line =~ s/RU-SVE|sverdl/Свердловская область/;
        $line =~ s/RU-SMO|smol/Смоленская область/;
        $line =~ s/RU-STA|stavrop/Ставропольский край/;
        $line =~ s/RU-TAM|tambov/Тамбовская область/;
        $line =~ s/RU-TVE|tver/Тверская область/;
        $line =~ s/RU-TOM|tomsk/Томская область/;
        $line =~ s/RU-TUL|tul/Тульская область/;
        $line =~ s/RU-TYU|tumen/Тюменская область/;
        $line =~ s/RU-UD|udmurt/Удмуртская Республика/;
        $line =~ s/RU-ULY|ulyan/Ульяновская область/;
        $line =~ s/RU-KHA|khabar/Хабаровский край/;
        $line =~ s/RU-KHM|khanty/Ханты-Мансийский автономный округ/;
        $line =~ s/RU-CHE|chel/Челябинская область/;
        $line =~ s/RU-CE|chechen/Чеченская Республика/;
        $line =~ s/RU-CU|chuvash/Чувашская Республика/;
        $line =~ s/RU-CHU|chukot/Чукотский автономный округ/;
        $line =~ s/RU-YAN|yamal/Ямало-Ненецкий автономный округ/;
        $line =~ s/RU-YAR|yarosl/Ярославская область/;
		
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

    # Phone numbers
    if ( $line =~ /^Phone=7([\(\)\-\s]*\d){10}/ ) {
        $line =~ s/Phone=7/Phone=+7/;
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
