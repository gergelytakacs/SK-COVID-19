clc; clear;                   % Cleanup 
hold off;                   % Useful for tuning
addpath('SEIR','-end')                   % I have the code as a submodule in my own repo


%% Colors
blue   = [0      0.4470 0.7410];
orange = [0.8500 0.3250 0.0980];
yellow = [0.9290, 0.6940, 0.1250];

% Data reading and preparation
importData;                              % Script to import the data from CSV

fitBegin=17;                              % Day to begin the fit

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


udata = iddata([],zeros(365,0),1);
opt = simOptions('InitialCondition',InitialStates);
sim(SEIQRDPinit ,udata,opt);
[y a x]=sim(SEIQRDPinit,udata,opt);
% RES.OutputData(end,1)-RES.OutputData(1,1);
% return




%% Simulate for long term (e.g. fit control)

figure(101)
N = 365;
timeL = datetime(timeS):1:datetime(timeS+N);

%return
t = 1:dt:length(timeL);
[S,E,I,Q,R,D,P] = SEIQRDP(alpha1,beta1,gamma1,delta1,Lambda1,Kappa1,Npop,E0,I0,Q0,R0,D0,t);

semilogy(t,Q,'r',t,R,'b',t,D,'k');




% Prediction
semilogy(t,E,t,I,t,Q,t,R,t,D);

hold on
t=1:365
semilogy(t,x(:,2),'k--',t,x(:,3),'k--',t,x(:,4),'k--',t,x(:,5),'k--');


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



