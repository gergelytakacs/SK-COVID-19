function [country, C,date0] = getDataFrance()
%GETDATA Coronavirus data
%  https://en.wikipedia.org/wiki/2020_coronavirus_pandemic_in_France
country = 'France';
date0=datenum('2020/02/28'); % start date

C = [
    57
    100
    130
    191
    212
    285
    423
    613
    949
    1126
    1412
    1784
    2281
    3661
    4499
    5423
    6633
    7730
    9134
    10995
    12612
    14459
    16689
    19856
%<-------------- add new data here
]';
end

