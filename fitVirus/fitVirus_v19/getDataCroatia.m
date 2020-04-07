function [country, C,date0] = getDatCroatia()
%GETDATA Coronavirus data
%  https://en.wikipedia.org/wiki/2020_coronavirus_pandemic_in_Croatia
country = 'Croatia';
date0=datenum('2020/03/09'); % start date

C = [
    13
    15
    19
    27
    32
    39
    49
    56
    69
    89
    105
    128
    206
    254
    315
    361 % 20/03/23
%<-------------- add new data here
]';
end

