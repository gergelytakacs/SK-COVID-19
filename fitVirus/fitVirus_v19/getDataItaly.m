function [country, C,date0] = getDataItaly()
%GETDATA Coronavirus data
%  https://en.wikipedia.org/wiki/2020_coronavirus_outbreak_in_Italy
country = 'Italy';
date0=datenum('2020/02/21'); % start date

C = [
    20
    79
    150
    227
    320
    445
    650
    888
    1128
    1694
    2036
    2502
    3089
    3858
    4636
    5883
    7382
    9172
    10149
    12462
    15113
    17660
    21157
    24747
    27980
    31506
    35713
    41045
    47021
    53578
    59138
    63927
%<-------------- add new data here
]';
end

