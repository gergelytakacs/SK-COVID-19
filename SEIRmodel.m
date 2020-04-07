clc; clear;                   % Cleanup 
hold off;                   % Useful for tuning
addpath('SEIR','-end')                   % I have the code as a submodule in my own repo

% Data reading and preparation
importData;                              % Script to import the data from CSV

fitBegin=10;                              % Day to begin the fit

I=cumsum(Confirmed(fitBegin:end))';      % Cumulative sum of daily cases, transpose to make it compatible w/ E. Cheynet's code
R=cumsum(Recovered(fitBegin:end))';      % Cumulative sum of daily cases, transpose to make it compatible w/ E. Cheynet's code
D=cumsum(Deaths(fitBegin:end))';         % Cumulative sum of daily cases, transpose to make it compatible w/ E. Cheynet's code
I=I-R-D;                                 % Active infections


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
[alpha1,beta1,gamma1,delta1,Lambda1,Kappa1] = fit_SEIQRDP(I-R-D,R,D,Npop,E0,I0,time,guess);


%% Simulate

% Figure 1

figure(1)
N = numel(time1);
t = [0:N-1].*dt;
[Ss,Es,Is,Qs,Rs,Ds,Ps] = SEIQRDP(alpha1,beta1,gamma1,delta1,Lambda1,Kappa1,Npop,E0,I0,Q0,R0,D0,t);
semilogy(time1,Is,'r',time1,Rs,'b',time1,Ds,'k');
hold on
semilogy(time,(I-R)','ro',time,(R)','bo',time,(D)','ko');
 ylim([0,1.1*Npop])
ylabel('Number of cases')
xlabel('time (days)')
% leg = {'susceptible','exposed','infectious','quarantined','recovered','Dead','insusceptible'};
leg = {'infectious','recovered','Dead'};
legend(leg{:},'location','southoutside')
set(gcf,'color','w')
grid on
axis tight
% ylim([1,8e4])
set(gca,'yscale','lin')

return

%% Long term
figure(2)

N = 200;
t = [0:N-1].*dt;
[S,E,I,Q,R,D,P] = SEIQRDP(alpha1,beta1,gamma1,delta1,Lambda1,Kappa1,Npop,E0,I0,Q0,R0,D0,t);
figure
%semilogy(time1,I,'r',time1,R,'b',time1,D,'k');
hold on
%semilogy(time,Confirmed-Recovered,'ro',time,Recovered,'bo',time,Deaths,'ko');
% ylim([0,1.1*Npop])
ylabel('Number of cases')
xlabel('time (days)')
% leg = {'susceptible','exposed','infectious','quarantined','recovered','Dead','insusceptible'};
leg = {'infectious','recovered','Dead'};
legend(leg{:},'location','southoutside')
set(gcf,'color','w')
grid on
axis tight
% ylim([1,8e4])
set(gca,'yscale','lin')


