function [country, C,date0] = getDataSouthKorea()
%GETDATA Coronavirus data
%  https://en.wikipedia.org/wiki/2020_coronavirus_outbreak_in_South_Korea
country = 'South Korea';
date0=datenum('2020/02/18'); % start date

C = [
    31
51
104
204
433
602
833
977
1261
1766
2337
3150
4212
4812
5328
5766
6284
6767
7134
7382
7513
7755
7869
7979
8086
8162
8236
8320
8413
8565
8652
8799
8897
8961
9037 % 20/03/23
%<-------------- add new data here
]';
end

