function  y1 = sirfn(k,t,y)
%
%      y1 = sirfn(k,t,y)
%               supplies the derivative vector for use
%      in ODE23K as called by SIREPI. N.B. The output is a
%      COLUMN vector.  y(1) is S, y(2) is I and k is [r a]
%
y1 = [-k(1)*y(1)*y(2), k(1)*y(1)*y(2)-k(2)*y(2) ]';
