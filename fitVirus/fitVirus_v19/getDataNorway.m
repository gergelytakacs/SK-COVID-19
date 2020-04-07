function [country, C,date0] = getDataNorway()
%GETDATA Coronavirus data
%  https://en.wikipedia.org/wiki/2020_coronavirus_pandemic_in_Norway
country = 'Norway';
date0=datenum('2020/03/02'); % start date

C = [
    25
    33
    54
    84
    111
    145
    167
    190
    275
    489
    621
    750
    907
    1077   % 20/03/15
    1169
    1308
    1423
    1552
    1742
    1926
    2132  
    2371 %20/03/23
%<-------------- add new data here
]';
end

