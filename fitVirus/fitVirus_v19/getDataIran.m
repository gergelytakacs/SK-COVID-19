function [country, C,date0] = getDataIran()
%GETDATA Coronavirus data
%  https://en.wikipedia.org/wiki/2020_coronavirus_outbreak_in_Iran
country = 'Iran';
date0=datenum('2020/02/21'); % start date

C = [
18
29
43
64
95
139
245
388
593
978
1501
2336
2922
3513
4747
5823
6566
7161
8042
9000
10075
11364
12729
13938
14991
16169
17361
18407
19644
20610
21638
23049 % 20/03/23
%<-------------- add new data here
]';
end

