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
sir = idnlgrey(FileName,Order,Parameters,InitialStates,Ts,'TimeUnit','days','Name','SIR Model');
%sir = setpar(nlgr,'Name',{'R0','dR (Removal rate)'});
%sir = setinit(nlgr,'Name',{'Susceptible' 'Infected' 'Removed'});

% Base reproduction number R0
sir.Parameters(1).Minimum = 1.0;
sir.Parameters(1).Maximum = 15;
sir.Parameters(1).Fixed = false;
    
% Removal rate dR (1/gamma)
sir.Parameters(2).Minimum = 0.0;
sir.Parameters(2).Maximum = 14.0; % Mean deaths 17 days, mean recoveries
sir.Parameters(2).Fixed = false; 

sir.InitialStates(1).Fixed = false;
sir.InitialStates(2).Fixed = false;
sir.InitialStates(3).Fixed = false;


% Identify model
opt = nlgreyestOptions('Display','on','EstCovar',true,'SearchMethod','Auto'); %gna
opt.SearchOption.MaxIter = 50;                % Maximal number of iterations
model = nlgreyest(data,sir,opt);              % Run identification procedure
    

compare(data,model);                           % Compare data to model
model                                          % List model parameters
grid on                                        % Turn on grid

%% Simulate
opt2 = simOptions('InitialCondition',[]);
ysim2 = sim(model,data,opt2);
ysim2.OutputData(:,2)
%% Report
R0est=model.Parameters(1).Value;
dRest=model.Parameters(2).Value;
%model.Report.Fit
MSE=model.Report.Fit.MSE;