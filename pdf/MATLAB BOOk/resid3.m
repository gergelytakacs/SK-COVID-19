%%%%%%%%%%%%%%%%%%%%%%% resid3.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%		
%
%	Usage:
%		R = resid3(p)
%
%	An example of a residual function for use with the multi-parameter
%	least squares fit 'mparft.m'
%	Requires 'global xi yi' in the calling routine (e.g. mparft.m)
%	p is a column vector of parameters
%	R is the residual function (sum of squares of residuals)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

function R = resid3(p)
echo off;
global xi yi yf
% this example is for fit  y=p(1) * exp(-0.5*( (x-p(2))/p(3))^2) 

b1 = (xi-p(2)); b2=.5/(p(3)*p(3));
yf = p(1) * exp(-b2* (b1 .* b1));   %only this needs changing usually

%weighted sum of residuals
%R = (yf-yi) ./ dyi;    %this example has no errors and so no weighting

R = (yf-yi) ;
R = sum(R.^2);
