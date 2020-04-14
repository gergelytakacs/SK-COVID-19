clc; clear;                   % Cleanup 
hold off;                   % Useful for tuning


%% Colors
blue   = [0      0.4470 0.7410];
orange = [0.8500 0.3250 0.0980];
yellow = [0.9290, 0.6940, 0.1250];

first=1;

for fitBegin=10:1:11;     % Day to begin the fit

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

%% My interpretation

Ts = 1;                              % Sampling [1 day]
data = iddata([I R D],[],Ts);        % Create identification data object
data.TimeUnit='days';                % Time units
data.OutputName = [{'Infected'};{'Recovered'};{'Dead'}];              % Output name
data.OutputUnit = [{'Cases'};{'Cases'};{'Cases'}];                          % Output unit
%dataToFit=data(fitBegin:end);    % Create dataset itslef.

gamma0=0.1;
gamma1=0.002;
mu=3.5E-4;


alpha = 0.15;
beta = 1;        % [Days] 
sigma = 7;       % [Days] Latent period
delta = 10;      % [Days] Quaratine period

FileName             = 'SEIQRDP_ODE';              % File describing the SIR model structure
Order                = [3 0 7];                    % Model orders [ny nu nx]
Parameters           = [alpha,1/beta,1/sigma,1/delta,gamma0,gamma1,mu];     % Initial values of parameters
InitialStates        = [Npop-E0-I0-Q0-R0-D0;E0;I0;Q0;R0;D0;0];  % Initial values of  [S I R] states
Ts                   = 0;                      % Time-continuous system

% Set identification options
SEIQRDPinit = idnlgrey(FileName,Order,Parameters,InitialStates,Ts,'TimeUnit','days','Name','SEIQRDP Model');
%SEIQRDPinit = setpar(SEIQRDPinit,'Name',{'beta (exposure rate)','sigma (infection rate)','gamma (removal rate)','lambda (birth rate)','mu (death rate)'});
%SEIQRDPinit = setinit(SEIQRDPinit,'Name',{'Susceptible' 'Exposed' 'Infected' 'Removed'});

% --------------Parameters--------------------

% alpha - protection rate
SEIQRDPinit.Parameters(1).Minimum = 0.1;      
SEIQRDPinit.Parameters(1).Maximum = 0.2;   
SEIQRDPinit.Parameters(1).Fixed = false;

% beta - infection rate
SEIQRDPinit.Parameters(2).Minimum = 0.5;    % [1/days] 
SEIQRDPinit.Parameters(2).Maximum = 2;      % [1/days]       
SEIQRDPinit.Parameters(2).Fixed = false;
    
% sigma - latent period
SEIQRDPinit.Parameters(3).Minimum = 1/14;   % [1/days] 
SEIQRDPinit.Parameters(3).Maximum = 1/1;    % [1/days] 
SEIQRDPinit.Parameters(3).Fixed = false; 

% delta - quarantining period 1/days
%SEIQRDPinit.Parameters(4).Minimum = 1/21;  
%SEIQRDPinit.Parameters(4).Maximum = 1/7;    % [1/days] 
SEIQRDPinit.Parameters(4).Fixed = false; 

% gamma0 - recovery rate
%SEIQRDPinit.Parameters(5).Minimum = 0.01;   % [1/days] 
%SEIQRDPinit.Parameters(5).Maximum = 0.1;    % [1/days] 
SEIQRDPinit.Parameters(5).Fixed = false; 

% gamma1 - recovery rate
%SEIQRDPinit.Parameters(6).Minimum = 1/21;   % [1/days] 
%SEIQRDPinit.Parameters(6).Maximum = 1/1;    % [1/days] 
SEIQRDPinit.Parameters(6).Fixed = false; 

% mu - recovery rate
%SEIQRDPinit.Parameters(7).Minimum = 1/21;   % [1/days] 
%SEIQRDPinit.Parameters(7).Maximum = 1/1;    % [1/days] 
SEIQRDPinit.Parameters(7).Fixed = false;



% --------------Initial conditions--------------------
% Susceptibles
SEIQRDPinit.InitialStates(1).Fixed = false;
SEIQRDPinit.InitialStates(2).Fixed = false;   
SEIQRDPinit.InitialStates(3).Fixed = false;   
SEIQRDPinit.InitialStates(4).Fixed = true;   
SEIQRDPinit.InitialStates(5).Fixed = true;   
SEIQRDPinit.InitialStates(6).Fixed = true;  
SEIQRDPinit.InitialStates(7).Fixed = false;  

optEst = nlgreyestOptions('Display','on','EstCovar',true); %gna
optEst.SearchMethod= 'gna';
optEst.SearchOption.MaxIter = 20;                % Maximal number of iterations
SEIQRDPm = nlgreyest(data,SEIQRDPinit,optEst);              % Run identification procedure


udata = iddata([],zeros(230,0),1);
opt = simOptions('InitialCondition',InitialStates);
%sim(SEIQRDPinit ,udata,opt);
% RES.OutputData(end,1)-RES.OutputData(1,1);
% return
[Y A X]=sim(SEIQRDPm,udata,opt);




%% Simulate 
figure(101)
t=fitBegin:length(X)+fitBegin-1;
semilogy(t,X(:,4),'-','Color',blue,'LineWidth',0.5);
hold on;
semilogy(t,X(:,5),'-','Color',orange,'LineWidth',0.5);
semilogy(t,X(:,6),'k-','LineWidth',0.5);

if(first)
    
%% Report
d1=datetime(2020,3,6,'Format','d.M'); % First confirmed case
DayLT=1:30:365;
DateLT = datestr(d1:30:d1+365); % Date array for predictions

[valMax indMax]=max(X(:,4));
disp(['Maximum aktívne infekcnych pripadov: ',num2str(round(valMax))])
disp(['Vrchol infekcií: ',datestr(d1+fitBegin+indMax)])
disp(['Infikovaní: ',num2str(round(max(X(:,5)))+round(max(X(:,6))))])
disp(['Vyliecení: ',num2str(round(max(X(:,5))))])
disp(['Úmrtia: ',num2str(round(max(X(:,6))))])
disp(['Koniec infekcií: ',datestr(d1+fitBegin+min(find(X(:,4)<=10))),' (<10 aktívnych prípadov)'])

first=0;
end

end





% Data reading and preparation
importData;                              % Script to import the data from CSV

I=cumsum(Confirmed);      % Cumulative sum of daily cases, transpose to make it compatible w/ E. Cheynet's code
R=cumsum(Recovered);      % Cumulative sum of daily cases, transpose to make it compatible w/ E. Cheynet's code
D=cumsum(Deaths);         % Cumulative sum of daily cases, transpose to make it compatible w/ E. Cheynet's code
I=I-R-D;                   % Active infections

semilogy(Day,I,'-o','Color',blue,'MarkerSize',4,'LineWidth',1.5)
hold on
semilogy(Day,R,'-o','Color',orange,'MarkerSize',4,'LineWidth',1.5)
semilogy(Day,D,'k-o','MarkerSize',4,'LineWidth',1.5)

ylabel('Pocet pripadov')
xlabel('Cas (dni od prveho pripadu)')
leg = {'Infekcni','Vylieceni','Mrtvi'};
legend(leg{:},'location','northeastoutside')
set(gcf,'color','w')
grid on
axis tight
set(gca,'yscale','lin')
title('COVID-19 na Slovensku, SEIQRDP model (Dlhodoba projekcia)')

xticks(DayLT)
xticklabels(DateLT)
xtickangle(90)


cd out
print(['skCOVID19_SEIQRD_LongTerm'],'-dpng','-r0')
cd ..

axis([0,max(Day)*1.1,0,max(I)*1.1])
cd out
print(['skCOVID19_SEIQRD_LongTermFit'],'-dpng','-r0')
cd ..

