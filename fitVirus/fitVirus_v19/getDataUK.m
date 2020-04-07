
function [country, C,date0] = getDataUK()
%GETDATA Coronavirus data for Slovenia
%  
country = 'UK';
date0=datenum('2020/03/04'); % start date

C = [
85
114
160
206
271
321
373
456
590
797
1061
1391
1543
1950
2626
3269
3983
5018
5683
6650  % 20/03/23
%<-------------- add new data here
]';
end

