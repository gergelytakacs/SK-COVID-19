%%%%%%%%%%%%%%%%%%%%%%% colddat.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%		Common cold epidemic data
%
%	Usage:
%		colddat
%
%	Loads in matrix alldat(ndata,2)
%		and vectors xi (tdays), yi (C)
%		which are its columns
%               tdays is the time in days
%               C is the number of new cold cases on day  t
%		The number of data points (ndata) is also returned
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

echo off;
hold off;

%Data goes in here
% tdays C
alldat=[
1 1
2 1
3 1
4 0
5 8
6 8
7 15
8 4
9 23
10 5
11 3
12 4
13 2
14 2
15 1
16 0
17 0
18 1
19 0
20 0];

% end of the data
% define a few convenient variables
tdays = alldat(:,1); xi=tdays;
C = alldat(:,2); yi=C;
disp('No. of data points:')
ndata = length(tdays);
disp(ndata)

%plot the data
disp(' Press RETURN for plot')
pause
%define limits of the plot (bottom LH, top RH)
xp=[0 20]; yp=[0 25];
plot(xp,yp,'.w')
hold on

plot(xi,yi,'*g')
title('New cold cases')
xlabel('days')
ylabel('C')
hold off

