function [country, C,date0] = getDataSlovenia()
%GETDATA Coronavirus data for Slovenia
%  
country = 'Slovenia';
date0=datenum('2020/03/05'); % start date

C = [
     %1    % 4 marec
     6    % 5
     8    % 6
    12   % 7
    16   % 8
    25   % 9
    34   % 10
    57   % 11
    96   % 12
    141
    181
    219
    253
    275
    286
    319
    341
    379
    414
    442
%<-------------- add new data here
]';
end

