I=Nd-Recovered;
R=Recovered;

Ts = 1;                                         % Sampling [1 day]
data = iddata([(nPop-I) I R],[],Ts);                          % Create identification data object
data.TimeUnit='days';


data.OutputName = [{'Susceptible'};{'Infected'};{'Removed'}];              % Output name
data.OutputUnit = [{'Cases'};{'Cases'};{'Cases'}];                          % Output unit



%% Initial guess of model parameters
R0 = 3;             % [cases] Average base infection factor
dR=10;              % [days]  Removal rate

%% Model structure
FileName      = 'SIR_ODE';              % File describing the SIR model structure
Order         = [3 0 3];                % Model orders [ny nu nx]
Parameters    = [R0,dR];                % Initial values of parameters
InitialStates = [nPop-I(1);I(1);R(1)];           % Initial values of  [S I R] states
Ts            = 0;                      % Time-continuous system

% Set identification options
SIRinit = idnlgrey(FileName,Order,Parameters,InitialStates,Ts,'TimeUnit','days','Name','SIR Model');
SIRinit = setpar(SIRinit,'Name',{'R0','dR (Removal rate)'});
SIRinit = setinit(SIRinit,'Name',{'Susceptible' 'Infected' 'Removed'});

% Base reproduction number R0
SIRinit.Parameters(1).Minimum = 1.0;
SIRinit.Parameters(1).Maximum = 15;
SIRinit.Parameters(1).Fixed = false;
    
% Removal rate dR (1/gamma)
SIRinit.Parameters(2).Minimum = 0.0;
SIRinit.Parameters(2).Maximum = 14.0; % Mean deaths 17 days, mean recoveries
SIRinit.Parameters(2).Fixed = false; 

SIRinit.InitialStates(1).Fixed = false;
SIRinit.InitialStates(2).Fixed = false;
SIRinit.InitialStates(3).Fixed = false;


% Identify model
opt = nlgreyestOptions('Display','on','EstCovar',true,'SearchMethod','Auto'); %gna
opt.SearchOption.MaxIter = 50;                % Maximal number of iterations
SIR = nlgreyest(data,SIRinit,opt);              % Run identification procedure
    
%% Just internal comparison, not to output
%compare(data,SIR);                           % Compare data to model
SIR                                          % List model parameters
grid on                                        % Turn on grid

%% Simulate
udata = iddata([],zeros(length(DayPred),0),1);
opt2 = simOptions('InitialCondition',[]);
SIRsim = sim(SIR,udata,opt2);
Isim=round(SIRsim.OutputData(:,2));

%% Growth factor
growthFactorSIR= ([Isim; 0]./[0; Isim]);
growthFactorSIR= (growthFactorSIR(2:end-1)-1)*100;
gFSIR=mean(growthFactorSIR);





%% Report
R0est=SIR.Parameters(1).Value;
dRest=SIR.Parameters(2).Value;
%model.Report.Fit
MSE=SIR.Report.Fit.MSE;