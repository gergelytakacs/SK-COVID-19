function  sirepi
%
%       sirepi
%            	implements the  Kermack-McKendrick 'SIR' model for the spread
%            	of an epeidemic a time interval 'dt'. The members of a 
%               a population of N are classified as :-
%               S - susceptible :not yet infected but potentially so
%               I - infected    :infected and ready to infect others
%               R - removed     :recovered, dead ..not causing further infection
%		It prompts for the model parameters a,r in:-
%                           S'=-rSI, I'=rSI-aI   
%               and starting populations 'N' and 'S' and 'I'
%
%       sirepi.m  uses: 	ode23k.m,  sirfn.m
%

% Initialization
disp('SIR epidemic model for a population N=S+I+R')
disp('S=susceptible, I=infective, R=removed')
disp(' ')
N=input('What is the total population N? ');
disp('When you press RETURN you will see an empty plot of S vs I')
disp('You will be asked for the model parameters and an initial state')
disp('Press RETURN to end any pauses.')
pause
more = 'y';
dt = 0.1; trace = 1; tol = 0.1;
xp = [0 N]; yp = [0 N];
clg; hold off
plot(xp,yp,'w.')
title('SIR epidemic model')
xlabel('S')
ylabel('I')
hold on
pause

% Input parameters
disp('model parameters are r = infection rate (>0)')
disp('                     a = removal rate (>0)')
k = input(' Enter model parameters as [r a] : ');
disp('relative removal rate rho=a/r is'); rho=k(2)/k(1);
disp(rho);

while more ~= 'n'
    pop0 = input('Initial populations (from 0 to N), enter as [S0 I0]: ');
    dt=input('Suggest a time step (try 1 if you have no better suggestion): ');
    disp('please wait...')
    y0 = pop0'; t0 = 0; tf = dt; step = 'y'; mti =1;
    while step == 'y'
        [tout,yout] = ode23k('sirfn', k, t0, tf, y0, tol, trace);
        xp = yout(:,1); yp=yout(:,2);
	nti = length(tout); mtf=mti+nti-1;
 	xpp(mti:mtf)=tout(1:nti); 
	yp1(mti:mtf)=xp(1:nti); yp2(mti:mtf)=yp(1:nti);   
        mti=mtf+1;
       
        plot(xp,yp,'r'); pause
        disp('       t        S(t)      I(t)')
        disp([tf xp(nti) yp(nti) ])
        step = input('Another time step? (y/n): ','s');
        t0 = tf; tf = t0 + dt;
        num = size(tout); y0 = yout(num(1),:)';
    end
    more = input('Do you want another simulation? (y/n): ','s');
end
hold off
clg
disp('Model parameters [a r] were:')
disp(k);
disp(' i.e. rho was');
disp(rho);
disp('Press ENTER for a plot of the last solution: S(t), I(t) vs t '); 
pause
xp = [0 xpp(mtf)]; yp = [0 N];
clg; hold off
plot(xp,yp,'w.')
title('S(t) is green, I(t) is red')
xlabel('t')
ylabel('S,I')
hold on
plot(xpp,yp1,'g');
plot(xpp,yp2,'r');
hold off
