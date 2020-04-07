function [country, C,date0] = getDataSwitzerland()
%GETDATA Coronavirus data
%  https://en.wikipedia.org/wiki/2020_coronavirus_pandemic_in_Switzerland
country = 'Switzerland';
date0=datenum('2020/03/02'); % start date

C = [
    40
    55
    72
    102
    198
    254
    350
    369
    480
    640
    858
    1139
    1359
    2217
    2353
    2677
    3070
    3888
    5369
    6747
    7014
    8060  %20/03/23
%<-------------- add new data here
]';
end

