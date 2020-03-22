%%%%%%%%%%%%%%%%%%%%%%% fludat.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%		Flu epidemic data
%
%	Usage:
%		fludat
%
%	Loads in matrix alldat(ndata,2)
%		and vectors xi (tdays), yi (I)
%		which are its columns
%               tdays is the time in days
%               I is the number of infectives (ill boys) at time t
%		The number of data points (ndata) is also returned
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

echo off;
hold off;

%Data goes in here
% tdays I
alldat=[
3 24
4 79
5 230
6 301
7 256
8 245
9 201
10 138
11 78
12 25
13 12
14 9];

% end of the data
% define a few convenient variables
tdays = alldat(:,1); xi=tdays;
I = alldat(:,2); yi=I;
disp('No. of data points:')
ndata = length(tdays);
disp(ndata)

%plot the data
disp(' Press RETURN for plot')
pause
%define limits of the plot (bottom LH, top RH)
xp=[0 16]; yp=[0 800];
plot(xp,yp,'.w')
hold on

plot(xi,yi,'*g')
title('Flu infections')
xlabel('days')
ylabel('I')
hold off
