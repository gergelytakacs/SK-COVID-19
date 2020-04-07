function [country,C,date0] = getDataWorld()
%GETDATA Coronavirus data
%   data from 16 Jan to 21 Jan https://i.redd.it/f4nukz4ou9d41.png
%   data from from 22 Jan 2020 to 13 Feb 2020 are from 
%   https://www.worldometers.info/coronavirus/
country = 'outside of China';
date0=datenum('2020/01/26'); % start date
C = [
56
66
84
102
131
159
173
186
190
221
248
278
330
354
382
461
481
526
587
608
697
781
896
999
1124
1212
1385
1715
2055
2429
2764
3332
4288
5373
6789
8564
10298
12751
14907
17855
21393
25408
29255
33627
38169
45411
53763
64659
75778
88717
101592
117340
137896
163966
194590
223982
256376
297689 % 20/03/24
%<-------------- add new data here
]';
end

