function [country, C,date0] = getDataIndonesia()
%GETDATA Coronavirus data
%  https://en.wikipedia.org/wiki/2020_coronavirus_pandemic_in_Indonesia
country = 'Indonesia';
date0=datenum('2020/03/08'); % start date
C = [
6 % 2020/03/08
19 % 2020/03/09
27 % 2020/03/10
34 % 2020/03/11
34 % 2020/03/12
69 % 2020/03/13
96 % 2020/03/14
117 % 2020/03/15
134 % 2020/03/16
172 % 2020/03/17
227 % 2020/03/18
308 % 2020/03/19
369 % 2020/03/20
450 % 2020/03/21
514 % 2020/03/22
579 % 2020/03/23
686 % 2020/03/24
%<-------------- add new data here
]';
end


