[IMG ID]
ID=[% mapid %]
Name=[% mapname %]
TypeSet=Navitel
Copyright=OpenStreetMap project contributors under CC-BY-SA|Converted by

[% IF codepage %]
LblCoding=9
CodePage=[% codepage %]
[% ELSE %]
; UTF-8 encoding
[% END %]

POINumberFirst=N
DefaultCityCountry=[% defaultcountry %]
DefaultRegionCountry=[% defaultregion %]

MG=Y
POIIndex=N
Routing=Y
Invisible=Y

Elevation=M
Preprocess=F
TreSize=3000

Levels=2
Level0=24
Level1=8

[END-IMG ID]
