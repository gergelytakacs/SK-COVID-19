function [country, C,date0] = getDataSlovenia()
%GETDATA Coronavirus data for Slovenia
%  https://www.nijz.si/sl/dnevno-spremljanje-okuzb-s-sars-cov-2-covid-19
country = 'Slovenia';
date0=datenum('2020/03/04'); % start date

C = [
     1    % 4 marec
     6    % 5
     9    % 6
    13   % 7
    19   % 8
    29   % 9
    47   % 10
    77   % 11
    127   % 12
    174
    215
    247
    272
    283
    315
    339
    368
    402
    439
    442
    480
    528
%<-------------- add new data here
]';
end

