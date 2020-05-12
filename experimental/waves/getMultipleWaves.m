function [Q,R,D,T] = getMultipleWaves(guess,Npop,time,Confirmed,Recovered,Deaths,tStart1,tStart2,tEnd)
% [Q,R,D,T] =
% getMultipleWaves(guess,Npop,time,Confirmed,Recovered,Deaths,tStart1,tStart2,tEnd)
% simulate the number of recovered, deaths and active cases for the
% situation were two epidemic waves occur
% 
% Inputs:
%   guess:  double [1x10]: Initial guess for the fitting algorithm
%   Npop:  double [1x1]: Population
%   time: datetime: [1xN]: time array
%   Confirmed: double [1xN]: Time histories of the confirmed cases (Active+recovered+deaths) 
%   Deaths: double [1xN]: Time histories of the deceased cases 
%   Recovered: double [1xN]: Time histories of the recovered cases 
%   tStart1: datetime [1x1]: Initial time for the first wave
%   tStart2: datetime [1x1]: Initial time for the second wave
%   tEnd: datetime [1x1]: Final time for the simulation
% 
% Outputs
%   Q: double [1xN1]: Time histories of the quarantined/active cases 
%   D: double [1xN1]: Time histories of the deceased cases 
%   R: double [1xN1]: Time histories of the recovered cases 
%   T: datetime: [1xN1]: time array
% 
% Author: E. Cheynet - UiB - last modified: 07-05-2020
% 
% see also SEIQRDP.m fit_SEIQRDP.m

%% Remove unecessary data
Confirmed(time<tStart1) = [];
Recovered(time<tStart1) = [];
Deaths(time<tStart1) = [];
time(time<tStart1) = [];
Active = Confirmed-Recovered-Deaths;
Active(Active<0) = 0; % No negative number possible


%  Time for first wave
indT1 = find(time>=tStart1 & time<tStart2);
% Time for  second wave
indT2 = find(time>=tStart2);

%% Simulate first wave
% Initial conditions
E0 = Confirmed(indT1(1)); % Initial number of exposed cases. Unknown but unlikely to be zero.
I0 = Confirmed(indT1(1)); % Initial number of infectious cases. Unknown but unlikely to be zero.
Q0 = Active(indT1(1)); 
R0 = Recovered(indT1(1)); 
D0 = Deaths(indT1(1)); 

[E1,I1,Q1,R1,D1,T1] = computeWave(Active(indT1),Recovered(indT1),...
    Deaths(indT1),E0,I0,Q0,R0,D0,time(indT1),tStart1,tStart2,guess);

%% Simulate second wave
E0 = E1(end); 
I0 = I1(end); 
Q0 = Q1(end); 
R0 = R1(end); 
D0 = D1(end); 
[~,~,Q2,R2,D2,T2] = computeWave(Active(indT2),Recovered(indT2),...
    Deaths(indT2),E0,I0,Q0,R0,D0,time(indT2),tStart2,tEnd,guess);

%% Concatenate outputs
Q = [Q1,Q2];
R = [R1,R2];
D = [D1,D2];
T= [T1,T2];


%% Nested functions

    function [E,I,Q,R,D,newT] = computeWave(Active,Recovered,Deaths,E0,I0,Q0,R0,D0,time,tStart,tEnd,guess)
        
        % Parameter estimation with the lsqcurvefit function
        [alpha1,beta1,gamma1,delta1,Lambda1,Kappa1,lambdaFun,kappaFun] = ...
            fit_SEIQRDP(Active,Recovered,Deaths,Npop,E0,I0,time,guess,'Display','off');
        
        dt = 1/24; % time step
        newT = tStart:dt:tEnd;
        N = numel(newT);
        t = [0:N-1].*dt;
        [~,E,I,Q,R,D,~] = SEIQRDP(alpha1,beta1,gamma1,delta1,Lambda1,Kappa1,...
            Npop,E0,I0,Q0,R0,D0,t,lambdaFun,kappaFun);
    end


end

