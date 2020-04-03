% SIR homogeneus infection dynamics without vital dynamics
% Fit from data, simulation and daily statistics
% Gergely Takacs, March 2020
% No guarantees given whatsoever.
% See covid19.gergelytakacs.com for more
clc; clear;

load('SEIR/HubeiData.mat','time','Deaths','Infected','Recovered')
I=Infected';
R=Recovered'-Deaths';
t=1:1:length(time)
nPop=14e6;

Ts = 1;                                         % Sampling [1 day]
data = iddata([(nPop-I-R) (I-R) R],[],Ts);                          % Create identification data object
data.TimeUnit='days';
data.OutputName = [{'Susceptible'};{'Infected'};{'Removed'}];              % Output name
data.OutputUnit = [{'Cases'};{'Cases'};{'Cases'}];                          % Output unit



%% Initial guess of model parameters
beta  = 1/7;             % [cases] Average base infection factor
gamma = 1/8;              % [days]  Removal rate
gammaTau=8;

%% Model structure
FileName      = 'SIR_ODE_Test';              % File describing the SIR model structure
Order         = [3 0 3];                % Model orders [ny nu nx]
Parameters    = [beta,gamma,gammaTau];                % Initial values of parameters
InitialStates = [nPop-I(1)-R(1);I(1)-R(1);R(1)];           % Initial values of  [S I R] states
Ts            = 0;                      % Time-continuous system

% Set identification options
SIRinit = idnlgrey(FileName,Order,Parameters,InitialStates,Ts,'TimeUnit','days','Name','SIR Model');
SIRinit = setpar(SIRinit,'Name',{'beta','gamma','gammaTau'});
SIRinit = setinit(SIRinit,'Name',{'Susceptible' 'Infected' 'Removed'});

% beta
SIRinit.Parameters(1).Minimum = 1/30;
SIRinit.Parameters(1).Maximum = 1/1;
SIRinit.Parameters(1).Fixed = false;
    
% gamma
SIRinit.Parameters(2).Minimum = 1/1000
SIRinit.Parameters(2).Maximum = 1000; % Mean deaths 17 days, mean recoveries
SIRinit.Parameters(2).Fixed = false; 

SIRinit.Parameters(3).Minimum = 1
SIRinit.Parameters(3).Maximum = 1000; % Mean deaths 17 days, mean recoveries
SIRinit.Parameters(3).Fixed = false; 

% Susceptibles
SIRinit.InitialStates(1).Fixed = true;

SIRinit.InitialStates(2).Fixed = true;   % Let this parameter free, overall results will be better. True number unknown anyways
%SIRinit.InitialStates(2).Minimum = 0;     % Cannot be negative
SIRinit.InitialStates(2).Maximum = I(1)*5;;   % Unlikely to be more

SIRinit.InitialStates(3).Fixed = true;   % Yet again, we can let this parameter free.
SIRinit.InitialStates(3).Minimum = -inf;
SIRinit.InitialStates(3).Maximum = R(1)*5;

% Identify model
opt = nlgreyestOptions('Display','on','EstCovar',true,'SearchMethod','Auto'); %gna
opt.SearchOption.MaxIter = 50;                % Maximal number of iterations
SIR = nlgreyest(data,SIRinit,opt);              % Run identification procedure
    
%% Just internal comparison, not to output
%compare(data,SIR);                           % Compare data to model
SIR                                          % List model parameters
grid on                                        % Turn on grid

%% Simulate for generic data
udata = iddata([],zeros(365,0),1);
opt = simOptions('InitialCondition',[]);
SIRsim = sim(SIR,udata,opt);
Isim=round(SIRsim.OutputData(:,2));
figure(1)
%SIR.Parameters(1).Value=1/3;
%SIR.Parameters(2).Value=1/10;
sim(SIR,udata,opt)



figure(2)
compare(SIR,data)
disp(['1/beta: ',num2str(1/SIR.Parameters(1).Value),' [days]'])
disp(['1/gamma: ',num2str(1/SIR.Parameters(2).Value),' [days]'])
disp(['gammaTau: ',num2str(SIR.Parameters(3).Value),' [days]'])
disp(['gammaTau: ',num2str(SIR.Parameters(1).Value/SIR.Parameters(2).Value),' [cases]'])


return

%% Growth factor
growthFactorSIR= ([Isim; 0]./[0; Isim]);
growthFactorSIR= (growthFactorSIR(2:end-1)-1)*100;
gFSIR=mean(growthFactorSIR);



%% Report
R0est=SIR.Parameters(1).Value;
dRest=SIR.Parameters(2).Value;
N0est=SIR.InitialStates(2).Value;
%model.Report.Fit
MSE=SIR.Report.Fit.MSE;

%% simulate to find zero day data
opt2 = simOptions('InitialCondition',[nPop-1; 1; 0]);
SIRsim2 = sim(SIR,udata,opt2);
Isim2=round(SIRsim2.OutputData(:,2));
d0est= max(find(Isim2<N0est));