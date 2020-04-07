function [country,C,date0] = getDataGermany()
%GETDATA Coronavirus data
%   https://www.worldometers.info/coronavirus/country/germany/

country = 'Germany';
date0=datenum('2020/02/24'); % start date
C = [
    % https://en.wikipedia.org/wiki/2020_coronavirus_pandemic_in_Germany
 16  % 24
 18  %
 26
 48
 74
79
130
165
203
262
545
66
117
150
188
240
349
534
684
847
1112  % 20/03/09
1460
1884
2369
3062
3795
4838
6012
7156
8198
10999
13957
16662
18610
22672
27436 % 20/03/23


% 545
% 670
% 800
% 1040
% 1224
% 1565
% 1966
% 2745
% 3675
% 4599
% 5813
% 7272
% 9367
% 12327
% 15320
%<-------------- add new data here
]';
end

