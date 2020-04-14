clc; clear;                   % Cleanup 
hold off;                   % Useful for tuning
addpath('SEIR','-end')                   % I have the code as a submodule in my own repo


%% Colors
blue   = [0      0.4470 0.7410];
orange = [0.8500 0.3250 0.0980];
yellow = [0.9290, 0.6940, 0.1250];

% Data reading and preparation
importData;                              % Script to import the data from CSV

fitBegin=12;                              % Day to begin the fit

I=cumsum(Confirmed)';      % Cumulative sum of daily cases, transpose to make it compatible w/ E. Cheynet's code
R=cumsum(Recovered)';      % Cumulative sum of daily cases, transpose to make it compatible w/ E. Cheynet's code
D=cumsum(Deaths)';         % Cumulative sum of daily cases, transpose to make it compatible w/ E. Cheynet's code
I=I-R-D;                   % Active infections

D=D(fitBegin:end)
I=I(fitBegin:end)
R=R(fitBegin:end)

%% Time vectors
% For data
dt = 0.1;                               % Time step
timeS=datetime(2020,03,06+fitBegin);    % First infection in Slovakia
time = datetime(timeS):1:datetime(timeS+max(Day)-fitBegin); 
time=time';
time.Format = 'dd-MMM-yyyy';

% For simulation (and fit?)
time1 = datetime(timeS):dt:datetime(timeS+max(Day)-fitBegin);
N = numel(time1);
t = [0:N-1].*dt;


% Preprocess data
% minNum= 50;
% R(I<=minNum)=[];
% D(I<=minNum)=[];
% time(I<=minNum)= [];
% I(I<=minNum)=[];

%% Initial parameter guesses and conditions
Npop= 5.45E6;                           % Population of SLovakia

% Definition of the first estimates for the parameters
alpha_guess = 0.06;                     % protection rate
beta_guess = 1.0;                       % Infection rate
LT_guess = 5;                           % latent time in days
QT_guess = 21;                          % quarantine time in days
lambda_guess = [0.1,0.05];              % recovery rate
kappa_guess = [0.1,0.05];               % death rate

% Chinese example
% alpha_guess = 0.06; % protection rate
% beta_guess = 1.0; % Infection rate
% LT_guess = 5; % latent time in days
% QT_guess = 21; % quarantine time in days
% lambda_guess = [0.1,0.05]; % recovery rate
% kappa_guess = [0.1,0.05]; % death rate

% French regions example
% Definition of the first estimates for the parameters
% alpha_guess = 0.06; % protection rate
% beta_guess = 1.0; % Infection rate
% LT_guess = 5; % latent time in days
% QT_guess = 21; % quarantine time in days
% lambda_guess = [0.1,0.05]; % recovery rate
% kappa_guess = [0.1,0.05]; % death rate


guess = [alpha_guess,...
    beta_guess,...
    1/LT_guess,...
    1/QT_guess,...
    lambda_guess,...
    kappa_guess];

E0 = I(1); % Initial number of exposed cases. Unknown but unlikely to be zero.
I0 = I(1); % Initial number of infectious cases. Unknown but unlikely to be zero.
Q0 = I(1);
R0 = R(1);
D0 = D(1);

%% Compute fit
[alpha1,beta1,gamma1,delta1,Lambda1,Kappa1] = fit_SEIQRDP(I,R,D,Npop,E0,I0,time,guess);


%% My interpretation


Ts = 1;                              % Sampling [1 day]
data = iddata([I' R' D'],[],Ts);        % Create identification data object
data.TimeUnit='days';                % Time units
data.OutputName = [{'Infected'};{'Recovered'};{'Dead'}];              % Output name
data.OutputUnit = [{'Cases'};{'Cases'};{'Cases'}];                          % Output unit
%dataToFit=data(fitBegin:end);    % Create dataset itslef.

lambda0=Lambda1(1);
lambda1=Lambda1(2);
kappa0=Kappa1(1);
kappa1=Kappa1(2);


FileName             = 'SEIQRDP_ODE';              % File describing the SIR model structure
Order                = [3 0 7];                    % Model orders [ny nu nx]
Parameters           = [alpha1,beta1,gamma1,delta1,lambda0,lambda1,kappa0,kappa1];     % Initial values of parameters
InitialStates        = [Npop;E0;I0;Q0;R0;D0;0];  % Initial values of  [S I R] states
Ts                   = 0;                      % Time-continuous system

% Set identification options
SEIQRDPinit = idnlgrey(FileName,Order,Parameters,InitialStates,Ts,'TimeUnit','days','Name','SEIQRDP Model');
%SEIQRDPinit = setpar(SEIQRDPinit,'Name',{'beta (exposure rate)','sigma (infection rate)','gamma (removal rate)','lambda (birth rate)','mu (death rate)'});
%SEIQRDPinit = setinit(SEIQRDPinit,'Name',{'Susceptible' 'Exposed' 'Infected' 'Removed'});

% --------------Parameters--------------------

% S->E Exposure (contact) rate beta (1/beta in days)
%SEIQRDPinit.Parameters(1).Minimum = 1/30;      % [1/days] Cannot be reasonably more than 20 days      
%SEIQRDPinit.Parameters(1).Maximum = 1/1;  % [1/days] Cannot be reasonably less than an hour days      
SEIQRDPinit.Parameters(1).Fixed = false;

% E->I Infection rate sigma (1/sigma in days)
%SEIQRDPinit.Parameters(2).Minimum = 1/5;      % [1/days] Cannot be reasonably more than 20 days      
%SEIQRDPinit.Parameters(2).Maximum = 1/(1/24);  % [1/days] Cannot be reasonably less than an hour days      
SEIQRDPinit.Parameters(2).Fixed = false;
    
% I->R Removal rate gamma (1/gamma in days)
%SEIQRDPinit.Parameters(3).Minimum = 1/31;
%SEIQRDPinit.Parameters(3).Maximum = 1/10; % Mean deaths 17 days, mean recoveries
SEIQRDPinit.Parameters(3).Fixed = false; 

% Birth rate lambda (1/lambda)           % Birth rate will not be changed
                                         % by the epidemic. (Yet. :)

%SEIQRDPinit.Parameters(4).Value = 0;                                          
%SEIQRDPinit.Parameters(4).Minimum = lambda-0.25*lambda; % -25%
%SEIQRDPinit.Parameters(4).Maximum = lambda+0.25*lambda; % +25%
SEIQRDPinit.Parameters(4).Fixed = false; 


% Death rate mu (1/mu)                   % Consider changing this, maybe
%SEIQRDPinit.Parameters(5).Value = 0;  
%SEIQRDPinit.Parameters(5).Minimum = mu-0.25*mu;   % after first death begin. Since the pandemic deaths are not counted for
%SEIQRDPinit.Parameters(5).Maximum = mu+0.25*mu;   % the normal death rate. Or as a slack variable?
SEIQRDPinit.Parameters(5).Fixed = false;

%SEIQRDPinit.Parameters(6).Value = 0;  
%SEIQRDPinit.Parameters(6).Minimum = mu-0.25*mu;   % after first death begin. Since the pandemic deaths are not counted for
%SEIQRDPinit.Parameters(6).Maximum = mu+0.25*mu;   % the normal death rate. Or as a slack variable?
SEIQRDPinit.Parameters(6).Fixed = false;

%SEIQRDPinit.Parameters(7).Value = 0;  
%SEIQRDPinit.Parameters(7).Minimum = mu-0.25*mu;   % after first death begin. Since the pandemic deaths are not counted for
%SEIQRDPinit.Parameters(7).Maximum = mu+0.25*mu;   % the normal death rate. Or as a slack variable?
SEIQRDPinit.Parameters(7).Fixed = false;

%SEIQRDPinit.Parameters(8).Value = 0;  
%SEIQRDPinit.Parameters(8).Minimum = mu-0.25*mu;   % after first death begin. Since the pandemic deaths are not counted for
%SEIQRDPinit.Parameters(8).Maximum = mu+0.25*mu;   % the normal death rate. Or as a slack variable?
SEIQRDPinit.Parameters(8).Fixed = false;


% --------------Initial conditions--------------------
% Susceptibles
SEIQRDPinit.InitialStates(1).Fixed = false;
SEIQRDPinit.InitialStates(2).Fixed = false;   
SEIQRDPinit.InitialStates(3).Fixed = false;   
SEIQRDPinit.InitialStates(4).Fixed = true;   
SEIQRDPinit.InitialStates(5).Fixed = true;   
SEIQRDPinit.InitialStates(6).Fixed = true;  
SEIQRDPinit.InitialStates(7).Fixed = false;  

opt = nlgreyestOptions('Display','on','EstCovar',true,'SearchMethod','lsqnonlin'); %gna
%opt.SearchOption.MaxIter = 50;                % Maximal number of iterations
SEIQRDPm = nlgreyest(data,SEIQRDPinit,opt);              % Run identification procedure

%compare(data,SEIQRDPm)





udata = iddata([],zeros(365,0),1);
opt = simOptions('InitialCondition',InitialStates);
%sim(SEIQRDPinit ,udata,opt);
[y a x]=sim(SEIQRDPinit,udata,opt);
% RES.OutputData(end,1)-RES.OutputData(1,1);
% return
[y2 a2 x2]=sim(SEIQRDPm,udata,opt);




%% Simulate 
figure(101)
N = 365;
timeL = datetime(timeS):1:datetime(timeS+N);

%return
t = 1:dt:length(timeL);
[Ss,Es,Is,Qs,Rs,Ds,Ps] = SEIQRDP(alpha1,beta1,gamma1,delta1,Lambda1,Kappa1,Npop,E0,I0,Q0,R0,D0,t);

treal=1:length(I)
semilogy(treal,I,'ro',treal,R,'ro',treal,D,'ro');

hold on


% Prediction
semilogy(t,Es,'b-.',t,Is,'b-.',t,Qs,'b-.',t,Rs,'b-.',t,Ds,'b-.');



hold on
t=1:365
semilogy(t,x(:,2),'k--',t,x(:,3),'k--',t,x(:,4),'k--',t,x(:,5),'k--');


semilogy(t,x2(:,2),'g:',t,x2(:,3),'g:',t,x2(:,4),'g:',t,x2(:,5),'g:',t,x2(:,6),'g:');



% Data
% semilogy(time,(I-R)','Color',blue,'Marker','o','LineStyle','none');
% semilogy(time,(R)','Color',orange,'Marker','o','LineStyle','none');
% semilogy(time,(D)','ko');



hold on
%semilogy(time,Confirmed-Recovered,'ro',time,Recovered,'bo',time,Deaths,'ko');
% ylim([0,1.1*Npop])
ylabel('Pocet pripadov')
xlabel('Cas (dni od prveho pripadu)')
% leg = {'susceptible','exposed','infectious','quarantined','recovered','Dead','insusceptible'};
leg = {'Infekcni','Vylieceni','Mrtvi'};
legend(leg{:},'location','northeastoutside')
set(gcf,'color','w')
grid on
axis tight
% ylim([1,8e4])
set(gca,'yscale','lin')
title('COVID-19 na Slovensku, SEIQRDP model (Dlhodoba projekcia)')


d1=datetime(2020,3,6,'Format','d.M'); % First confirmed case
DayLT=1:30:365;
DateLT = datestr(d1:30:d1+365); % Date array for predictions

xticks(DayLT)
xticklabels(DateLT)
xtickangle(90)



