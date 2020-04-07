function [country, C,date0] = getDataAustria()
%GETDATA Coronavirus data
%  https://en.wikipedia.org/wiki/2020_coronavirus_pandemic_in_Austria
country = 'Austria';
date0=datenum('2020/03/02'); % start date

C = [
    10
    18
    29
    41
    55
    79
    99
    131
    182
    246
    361
    504
    655
    860
    1016
    1332
    1646
    2013
    2388
    2814
    3244
    3924
    4486 % 20/03/24
%<-------------- add new data here
]';
end

