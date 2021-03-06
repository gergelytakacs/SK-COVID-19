function [SEIQRDPm,InitialStates] = fitSEIRDQP_AltGamma(fitBegin,iter,mod,method);

% Data reading and preparation
importData;                              % Script to import the data from CSV

I=cumsum(Confirmed);      % Cumulative sum of daily cases, transpose to make it compatible w/ E. Cheynet's code
R=cumsum(Recovered);      % Cumulative sum of daily cases, transpose to make it compatible w/ E. Cheynet's code
D=cumsum(Deaths);         % Cumulative sum of daily cases, transpose to make it compatible w/ E. Cheynet's code
I=I-R-D;                   % Active infections

D=D(fitBegin:end);
I=I(fitBegin:end);
R=R(fitBegin:end);

%% Initial parameter guesses and conditions
Npop= 5.45E6;                           % Population of SLovakia

E0 = I(1); % Initial number of exposed cases. Unknown but unlikely to be zero.
I0 = I(1); % Initial number of infectious cases. Unknown but unlikely to be zero.
Q0 = I(1);
R0 = R(1);
D0 = D(1);
P0 = 0;    % No one is protected
S0 = Npop-E0-I0-Q0-R0-D0-P0;

%% My interpretation

Ts = 1;                              % Sampling [1 day]
data = iddata([I R D],[],Ts);        % Create identification data object
data.TimeUnit='days';                % Time units
data.OutputName = [{'Infected'};{'Recovered'};{'Dead'}];              % Output name
data.OutputUnit = [{'Cases'};{'Cases'};{'Cases'}];                          % Output unit
%dataToFit=data(fitBegin:end);    % Create dataset itslef.

alpha  = 0.05;
beta   = 1.5;        % [Days] 
sigma  = 3;      % [Days] Latent period
delta  = 4;       % [Days] Quaratine period
gamma0 = 1/0.8;
mu     = 0.001;
gamma1=1E-3; % was 
gammaTau=1;

    

% alpha  = 0.05;
% beta   = 1.5;        % [Days] 
% sigma  = 3;      % [Days] Latent period
% delta  = 4;       % [Days] Quaratine period
% gamma0 = 1/1;
% mu     = 4E-4;
% 
% if mod == 1
%     gamma1=0.001; % was 
% else 
%     gamma1=0.0;
% end



FileName             = 'SEIQRDP_ODE_AltGamma';              % File describing the SIR model structure
Order                = [3 0 7];                    % Model orders [ny nu nx]
Parameters           = [alpha,1/beta,1/sigma,1/delta,gamma0,gamma1,gammaTau,mu];     % Initial values of parameters
InitialStates        = [S0;E0;I0;Q0;R0;D0;P0];  % Initial values of  [S I R] states
Ts                   = 0;                      % Time-continuous system

% Set identification options
SEIQRDPinit = idnlgrey(FileName,Order,Parameters,InitialStates,Ts,'TimeUnit','days','Name','SEIQRDP Model');
%SEIQRDPinit = setpar(SEIQRDPinit,'Name',{'beta (exposure rate)','sigma (infection rate)','gamma (removal rate)','lambda (birth rate)','mu (death rate)'});
%SEIQRDPinit = setinit(SEIQRDPinit,'Name',{'Susceptible' 'Exposed' 'Infected' 'Removed'});

% --------------Parameters--------------------

% alpha - protection rate
SEIQRDPinit.Parameters(1).Minimum = 0.001;      
SEIQRDPinit.Parameters(1).Maximum = 0.2;   
SEIQRDPinit.Parameters(1).Fixed = false;

% beta - infection rate
SEIQRDPinit.Parameters(2).Minimum = 0.2;    % [1/days] 
SEIQRDPinit.Parameters(2).Maximum = 5;      % [1/days]       
SEIQRDPinit.Parameters(2).Fixed = false;
    
% sigma - latent period
SEIQRDPinit.Parameters(3).Minimum = 1/7;   % [1/days] 
SEIQRDPinit.Parameters(3).Maximum = 1/0.1;    % [1/days] 
SEIQRDPinit.Parameters(3).Fixed = false; 

% delta - quarantining period 1/days
SEIQRDPinit.Parameters(4).Minimum = 1/31;  
SEIQRDPinit.Parameters(4).Maximum = 1/1;    % [1/days] 
SEIQRDPinit.Parameters(4).Fixed = false; 

% gamma0 - recovery rate
SEIQRDPinit.Parameters(5).Minimum = eps;   % [1/days] 
SEIQRDPinit.Parameters(5).Maximum = 5;    % [1/days] 
SEIQRDPinit.Parameters(5).Fixed = false; 

% gamma1 - recovery rate
if mod ==1
SEIQRDPinit.Parameters(6).Minimum =0;   % [1/days] 
%SEIQRDPinit.Parameters(6).Minimum = eps;   % [1/days] 
%SEIQRDPinit.Parameters(6).Maximum = 1/1;    % [1/days] 
SEIQRDPinit.Parameters(6).Fixed = false; 
else
SEIQRDPinit.Parameters(6).Fixed = true; 
end
    
% gammaTau - recovery Tau
SEIQRDPinit.Parameters(7).Minimum = eps;   % [1/days] 
SEIQRDPinit.Parameters(7).Maximum = 100;    % [1/days] 
SEIQRDPinit.Parameters(7).Fixed = false;


% mu - death
SEIQRDPinit.Parameters(8).Minimum = eps;   % [1/days] 
SEIQRDPinit.Parameters(8).Maximum = 1;    % [1/days] 
SEIQRDPinit.Parameters(8).Fixed = false;



% --------------Initial conditions--------------------
% Susceptibles


SEIQRDPinit.InitialStates(1).Fixed   = false; % S(0)
 
SEIQRDPinit.InitialStates(2).Fixed   = false; % E(0) 

SEIQRDPinit.InitialStates(3).Fixed   = false; % I(0) 
 
SEIQRDPinit.InitialStates(4).Fixed   = true;  % Q(0)
% SEIQRDPinit.InitialStates(4).Minimum = I0; 
% SEIQRDPinit.InitialStates(4).Maximum = 1.2*I0; 
% 
SEIQRDPinit.InitialStates(5).Fixed   = true;  
% SEIQRDPinit.InitialStates(5).Minimum = R0; 
% SEIQRDPinit.InitialStates(5).Maximum = 1.2*Q0; 
% 
SEIQRDPinit.InitialStates(6).Fixed   = true;  
% SEIQRDPinit.InitialStates(6).Minimum = D0; 
% SEIQRDPinit.InitialStates(6).Maximum = 1.2*D0; 
% 
SEIQRDPinit.InitialStates(7).Fixed   = false;  

%--- Simulation options

%SEIQRDPinit.SimulationOptions.FixedStep=1/24;
%SEIQRDPinit.SimulationOptions.Solver='ode45';

%optEst.Regularization.Lambda=0; 
%optEst.Regularization.Nominal='zero'; % Which way it pulls params


optEst = nlgreyestOptions('Display','on','EstCovar',true); %gna

if strcmp(method,'gn')
optEst.SearchMethod= 'gn';
%optEst.GradientOptions.MinDifference=1E-2;
optEst.SearchOption.MaxIter = iter;          
end

if strcmp(method,'gna')
optEst.SearchMethod= 'gna';
%optEst.GradientOptions.MinDifference=1E-2;
optEst.SearchOption.MaxIter = iter;          
end

if strcmp(method,'lm')
 optEst.SearchMethod= 'lm';
 optEst.GradientOptions.MinDifference=1E-4;
 optEst.SearchOption.MaxIter = iter;   
end


if strcmp(method,'fmincon')
 optEst.SearchMethod= 'fmincon'; 
 optEst.SearchOption.FunctionTolerance = 1E-4;
 optEst.SearchOption.StepTolerance     = 1E-4;   
 optEst.SearchOption.MaxIter = iter;  
 %optEst.SearchOption.Algorithm = 'interior-point';  
 optEst.SearchOption.Algorithm = 'trust-region-reflective';
 % sqp useless, active set a bit less useless there is hope
 % trust region reflective seems to be the best
 % interior point gets stuck on some
end

      %Maximal number of iterations
if strcmp(method,'lsqnonlin')
 optEst.SearchMethod= 'lsqnonlin';
 optEst.SearchOption.FunctionTolerance = 1E-4;
 optEst.SearchOption.StepTolerance     = 1E-4;   
 optEst.SearchOption.MaxIter = iter;   
 %optEst.GradientOptions.MinDifference=1E-8;
end


 
 optEst.OutputWeight=diag([120,25,20]);
 %optEst.Regularization.Lambda = 1.00001;
 optEst.Regularization.Nominal = 'model';


SEIQRDPm = nlgreyest(data,SEIQRDPinit,optEst);              % Run identification procedure
InitialStates=[SEIQRDPm.InitialStates(1).Value;SEIQRDPm.InitialStates(2).Value;SEIQRDPm.InitialStates(3).Value;SEIQRDPm.InitialStates(4).Value;SEIQRDPm.InitialStates(5).Value;SEIQRDPm.InitialStates(6).Value;;SEIQRDPm.InitialStates(7).Value];
