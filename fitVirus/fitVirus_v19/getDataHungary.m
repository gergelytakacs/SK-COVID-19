function [country, C,date0] = getDataHungary()
%GETDATA Coronavirus data
% https://en.wikipedia.org/wiki/2020_coronavirus_pandemic_in_Hungary
country = 'Hungary';
date0=datenum('2020/03/07'); % start date

C = [
    7    % 20/03/07
    9
    12
    12
    13
    16
    19
    30
    32
    39
    50
    58
    73
    85
    103
    131
    167    
    187 % 20/03/23
%<-------------- add new data here
]';
end

