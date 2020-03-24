% SIR homogeneus infection dynamics with vital dynamics
% Fit from data, simulation and daily statistics
% Gergely Takacs, March 2020
% No guarantees given whatsoever.
% See covid19.gergelytakacs.com for more

%% 2019 demographic data for Slovakia
% https://www.cia.gov/library/publications/the-world-factbook/geos/lo.html
demBirth= 57054; % [people] Births in 2019 (total)
demDeath= 53234; % [people] Deaths in 2019 (total)
dayYear=365;     % [days]   2019 was not a leap year
demBirthDay=demBirth/365; % [people] Average birth per day in 2019
demDeathDay=demDeath/365; % [people] Average death per day in 2019

lambda= demBirthDay;     % This is taken for the whole country (whole population)
mu =   demDeathDay;      % This is adjusted for the population

% CIA 2020 est is 9.3 births / 1000 pop and 10.1 / 1000 pop.
% Using last year data though.

%% Prepping

Ts = 1;                                         % Sampling [1 day]
data = iddata([(nPop-I) I R],[],Ts);                          % Create identification data object
data.TimeUnit='days';


data.OutputName = [{'Susceptible'};{'Infected'};{'Removed'}];              % Output name
data.OutputUnit = [{'Cases'};{'Cases'};{'Cases'}];                          % Output unit



%% Initial guess of model parameters
R0 = 3.0;             % [cases] Average base infection factor
dR=10.0;              % [days]  Removal rate

%% Model structure
FileName      = 'SIR_VD_ODE';           % File describing the SIR model structure
Order         = [3 0 3];                % Model orders [ny nu nx]
Parameters    = [R0,dR,lambda,mu];      % Initial values of parameters
InitialStates = [nPop-I(1);I(1);R(1)];  % Initial values of  [S I R] states
Ts            = 0;                      % Time-continuous system

% Set identification options
SIR_VDinit = idnlgrey(FileName,Order,Parameters,InitialStates,Ts,'TimeUnit','days','Name','SIR Model');
SIR_VDinit = setpar(SIR_VDinit,'Name',{'R0','dR (Removal rate)','lambda (Birth rate)','mu (Death rate)'});
SIR_VDinit = setinit(SIR_VDinit,'Name',{'Susceptible' 'Infected' 'Removed'});

% Base reproduction number R0
SIR_VDinit.Parameters(1).Minimum = 1.0;
SIR_VDinit.Parameters(1).Maximum = 15;
SIR_VDinit.Parameters(1).Fixed = false;
    
% Removal rate dR (1/gamma)
SIR_VDinit.Parameters(2).Minimum = 5.0;
SIR_VDinit.Parameters(2).Maximum = 14.0; % Mean deaths 17 days, mean recoveries
SIR_VDinit.Parameters(2).Fixed = false; 

% Birth rate lambda (1/lambda)           % Birth rate will not be changed
                                         % by the epidemic. (Yet. :)
SIR_VDinit.Parameters(3).Fixed = true; 

% Death rate mu (1/mu)                   % Consider changing this, maybe
SIR_VDinit.Parameters(4).Minimum = 100;   % after first death begin. Since the pandemic deaths are not counted for
SIR_VDinit.Parameters(4).Maximum = 1000;   % the normal death rate. Or as a slack variable?
SIR_VDinit.Parameters(4).Fixed = true;

% --------------Initial conditions--------------------
% Susceptibles
SIR_VDinit.InitialStates(1).Fixed = true;


SIR_VDinit.InitialStates(2).Fixed = false;   % Let this parameter free, overall results will be better. True number unknown anyways
SIR_VDinit.InitialStates(2).Minimum = 0;     % Cannot be negative
SIR_VDinit.InitialStates(2).Maximum = 100;   % Unlikely to be more

SIR_VDinit.InitialStates(3).Fixed = false;   % Yet again, we can let this parameter free.
SIR_VDinit.InitialStates(2).Minimum = 0;
SIR_VDinit.InitialStates(2).Maximum = 10;

%% Simulate initial guess

% Identify model
opt = nlgreyestOptions('Display','on','EstCovar',true,'SearchMethod','Auto'); %gna
opt.SearchOption.MaxIter = 50;                % Maximal number of iterations
SIR_VD = nlgreyest(data,SIR_VDinit,opt);              % Run identification procedure
    
%% Just internal comparison, not to output
%compare(data,SIR_VD);                           % Compare data to model
%SIR_VD                                          % List model parameters
%grid on                                        % Turn on grid

%% Simulate for generic data
udata = iddata([],zeros(length(DayPred),0),1);
opt = simOptions('InitialCondition',[]);
SIRsim = sim(SIR_VD,udata,opt);
Isim=round(SIRsim.OutputData(:,2));

%% Simulate for next day
udata = iddata([],zeros(2,0),1);
opt = simOptions('InitialCondition',[nPop-I(end);I(end);R(end)]);
SIRsim = sim(SIR_VD,udata,opt);
Inext=round(SIRsim.OutputData(:,2));
Rnext=round(SIRsim.OutputData(:,3));
NdSIRnext=Inext+Rnext; NdSIRnext=NdSIRnext(end);

%% Growth factor
growthFactorSIR= ([Isim; 0]./[0; Isim]);
growthFactorSIR= (growthFactorSIR(2:end-1)-1)*100;
gFSIR=mean(growthFactorSIR);



%% Report
R0est=SIR_VD.Parameters(1).Value;
dRest=SIR_VD.Parameters(2).Value;
N0est=SIR_VD.InitialStates(2).Value;
%model.Report.Fit
MSE=SIR_VD.Report.Fit.MSE;

%% simulate to find zero day data
opt2 = simOptions('InitialCondition',[nPop-1; 1; 0]);
SIRsim2 = sim(SIR_VD,udata,opt2);
Isim2=round(SIRsim2.OutputData(:,2));
d0est= max(find(Isim2<N0est));