
clc; clear; close all;
importData;

addpath('SEIR','-end')
%
dt = 0.1; % time step

timeS=datetime(2020,03,06); % Data start
time = datetime(timeS):1:datetime(timeS+max(Day-1)); 
time=time';
time.Format = 'dd-MMM-yyyy';
time1 = datetime(timeS):dt:datetime(2020,04,01,0,0,0);


N = numel(time1);
t = [0:N-1].*dt;

Npop= 5.45E6; % population
guess = [0.08,1,1/5,1/40,0.05,0.02]; % my guess for the fit
[alpha,beta,gamma,delta,lambda,kappa] = fit_SEIQRDP((Confirmed-Recovered)',Recovered',Deaths',Npop,time,guess);



E0 = 0; % Initial number of exposed cases (we do not know it, so it is set at zero)
I0 = 100;
R0 = 0;
D0 = 0;
N = numel(time1);
t = [0:N-1].*dt;
[S,E,I,Q,R,D,P] = SEIQRDP(alpha,beta,gamma,delta,lambda,kappa,Npop,E0,I0,R0,D0,t);

figure
semilogy(time1,I,'r',time1,R,'b',time1,D,'k');
hold on
semilogy(time,Confirmed-Recovered,'ro',time,Recovered,'bo',time,Deaths,'ko');
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