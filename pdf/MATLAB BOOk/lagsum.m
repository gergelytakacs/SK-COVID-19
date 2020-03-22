%%%%%%%%%%%%%%%%%%%%%%% lagsum.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%	Running sum of the last 'lag' elements in a vector 'v'
%
%	Usage:
%		vsum = lagsum(v,lag);
%
%  	If 'v' has n elements, 'vsum' has n+lag-1 elements
%
%	Could be used for keeping count of the number of newspapers in
%	the house if each copy is kept precisely 1 week and given 
%	how many arrive each day.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

function vsum = lagsum(v,lag)
echo off;

n=length(v); vsum(1)=v(1);
nmax=n+lag-1;
for i=2:nmax
	more = 0; less = 0;
	if i <= n
		more = v(i);
	end
	if i > lag
		less = v(i-lag);
	end
	vsum(i)=vsum(i-1)+more-less;
end

