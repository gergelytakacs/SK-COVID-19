% Notes
% The SIR model is based on https://www.researchgate.net/post/Does_anybody_has_a_working_Matlab_code_for_a_disease-spread_simulation

% Rates described in: https://qubit.hu/2020/03/16/a-jarvanydinamika-segit-abban-hogy-megertsuk-mirol-szolnak-a-mostani-intezkedesek?fbclid=IwAR2JOfDp9DtIhp-VSyT_grv5Uscz8k2d81-0ZwTK3_Rn_90TDWt-vayjiDc
% Claims that 1/gamma is the rate of recovery in the given unit of time. E.g.
% 1/gamma=5 is 5 day recovery period, 1/beta is how many people are
% infected given a unit time. R0 is then R0=beta/gamma

% Incubation period 5.2 https://www.nejm.org/doi/10.1056/NEJMoa2001316
% 2.2 (1.4-3.9) Wuhan https://www.nejm.org/doi/10.1056/NEJMoa2001316
% https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7001239/
% https://www.biorxiv.org/content/10.1101/2020.01.25.919787v2

nPop=5441120;                   % Population of Slovakia
infected=123;                   % Current number of infected
infected=infected*6;            % Conservative estimate of true infected
recovered=3;                    % 2 recovered, 1 assumed dead
days=300;                       % Days to run the simulation
resolution=100;                  % Integration resolution is hours

% Italy
%R0 2·76 to 3·25, 

%--------------------------------------
%Institute of health policies
%https://github.com/institute-of-health-policies-sk/SIRmodel_COVID-19

R0=4;                         % Average initial reproduction factor [cases]
recovery=10;                  % Average recovery time [days] ??? Where did they get this?
scenario='Institute of health policies (izp.sk) - Worst case, No quarantine, pessimistic'
%-------------------------------------



% --------------------------------------
% R0=2.2;                         % Average initial reproduction factor [cases]
% recovery=10;                  % Average recovery time [days] ??? Where did they get this?
% scenario='Wuhan, early days, realistic'
% -------------------------------------

% --------------------------------------
R0=1.4;                         % Average initial reproduction factor [cases]
recovery=10;                  % Average recovery time [days] ??? Where did they get this?
scenario='Wuhan, early days, optimistic'
% -------------------------------------

x0 = [nPop-infected; infected; recovered];  % Initial state: Susceptible, Infected, Recovered
t = linspace(0, days, days*resolution);         % Time vector, duration, data
[t x] = SIR(t, x0, R0, recovery);
x=round(x);

%% Plot
figure(1)
plot(t, [x,x(:,2)+x(:,3)]);
legend ('Susceptible', 'Infectious', 'Recovered','Infected');
grid on
title('SARS-CoV-2 SIR Simulation for Slovakia')
xlabel('Time (Days)')
ylabel('Numer of cases')
text(2,0.9,'github.com/gergelytakacs/SK-COVID-19','FontSize',7,'rotation',90,'Color',[0.7 0.7 0.7])
text(4,0.9,'gergelytakacs.com','FontSize',7,'rotation',90,'Color',[0.7 0.7 0.7])
text(4,5.9E6,[scenario],'FontSize',12,'rotation',0,'Color',[0.5 0.5 0.5])
text(4,5.6E6,['$R_{0}=$',num2str(R0),',$\ 1/\gamma=$',num2str(1/recovery)],'FontSize',12,'rotation',0,'Color',[0.5 0.5 0.5],'interpreter','latex')

axis([0,300,0,6E6])

% figure(2)
% plot(diff(y(:,3)))
% legend('Daily cases')


function [t x] = SIR(t, x0, R0, recovery)

[t x] = ode45(@SIRbase,t,x0);

function xdot = SIRbase(t, x);
xdot = zeros(3, 1);

gamma = 1/recovery; % recovery rate 1/g = e.g. 14 [days]
beta=R0*gamma;% probability of contracting the disease (1.4-2.5)

N = x(1) + x(2) + x(3);                  % Computing total population from original data
xdot(1) = - beta*x(2)*x(1)/N;            % Differential equation for Susceptible cases
xdot(2) =   beta*x(2)*x(1)/N - gamma*x(2); % Differential equation for Infected cases
xdot(3) =   gamma*x(2);                     % Differential equation for Recovered cases
end
end