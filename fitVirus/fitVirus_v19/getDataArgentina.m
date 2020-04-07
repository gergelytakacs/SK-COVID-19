function [country, C,date0] = getDataArgentina()
%GETDATA Coronavirus data
%  https://en.wikipedia.org/wiki/2020_coronavirus_pandemic_in_Argentina
%  The plot in Timeline section seems to be up-to-date
country = 'Argentina';
date0=datenum('2020/03/03'); % start date

C = [
    1
    1
    2
    8
    9
    12
    17
    19
    21
    31
    34
    45
    56
    65
    79
    97
    128
    158
    225
    266
    301
%<-------------- add new data here
]';
end

