#!/usr/bin/perl

use strict;
use utf8;
use Getopt::Long;

my $killrouting = 0;
GetOptions (
    'killrouting!'  => \$killrouting,
);

my $file = shift @ARGV;
exit unless $file;

rename $file, "$file.old";

open my $in,  '<:encoding(cp1251)', "$file.old";
open my $out, '>:encoding(cp1251)', $file;

my $RestrictSection=0;

while ( my $line = readline $in ) {

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
    }

    if ($killrouting) {
	    #	remove routing nodes
	    next if ($line =~ /^Nod\d+/);
	    #	remove turn restrictions
	    if ($line =~ /^\[Restrict\]$/) { $RestrictSection = 1 };
	    if ($line =~ /^\[END-Restrict\]$/) { $RestrictSection = 0 ; next;};
	    next if $RestrictSection;
    }

    print $out $line;
}

close $in;
close $out;

unlink "$file.old";
