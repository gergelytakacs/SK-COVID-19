function [country, C,date0] = getDataDenmark()
%GETDATA Coronavirus data
%  https://en.wikipedia.org/wiki/2020_coronavirus_pandemic_in_Denmark
country = 'Denmark';
date0=datenum('2020/03/03'); % start date

C = [
10
15
20
23
29
37
92
264
516
676
804
836
804
936
875
932
1024
1115
1223
1335
1418
1512
1582
%<-------------- add new data here
]';
end

