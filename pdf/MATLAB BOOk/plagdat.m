%%%%%%%%%%%%%%%%%%%%%%% plagdat.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%		Epidemic data for Bombay plague
%
%	Usage:
%		plagdat
%
%	Loads in matrix alldat(ndata,2)
%		and vectors xi (tdays), yi (I)
%		which are its columns
%               tweekss is the time in weeks
%               D is the death rate/week at time t
%		The number of data points (ndata) is also returned
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

echo off;
hold off;

%Data goes in here
% tweeks D
alldat=[
1 5
2 10
3 17
4 22
5 30
6 50
7 51
8 90
9 120
10 180
11 292
12 395
13 445
14 775
15 780
16 700
17 698
18 880
19 925
20 800
21 578
22 400
23 350
24 202
25 105
26 65
27 55
28 40
29 30
30 20];

% end of the data
% define a few convenient variables
tweeks = alldat(:,1); xi=tweeks;
D = alldat(:,2); yi=D;
disp('No. of data points:')
ndata = length(tweeks);
disp(ndata)

%plot the data
disp(' Press RETURN for plot')
pause
%define limits of the plot (bottom LH, top RH)
xp=[0 32]; yp=[0 1000];
plot(xp,yp,'.w')
hold on

plot(xi,yi,'*g')
title('Plague death rate')
xlabel('weeks')
ylabel('D')
hold off
