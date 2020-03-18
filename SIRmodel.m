% Notes
% The SIR model is based on https://www.researchgate.net/post/Does_anybody_has_a_working_Matlab_code_for_a_disease-spread_simulation

% Rates described in: https://qubit.hu/2020/03/16/a-jarvanydinamika-segit-abban-hogy-megertsuk-mirol-szolnak-a-mostani-intezkedesek?fbclid=IwAR2JOfDp9DtIhp-VSyT_grv5Uscz8k2d81-0ZwTK3_Rn_90TDWt-vayjiDc
% Claims that 1/gamma is the rate of recovery in the given unit of time. E.g.
% 1/gamma=5 is 5 day recovery period, 1/beta is how many people are
% infected given a unit time. R0 is then R0=beta/gamma

nPop=5441120;                   % Population of Slovakia
infected=108;                   % Current number of infected
days=300;                       % Days to run the simulation
resolution=24;                  % Integration resolution is hours

R0=1.5;                           % Reproduction factor
recovery=7;                    % Average recovery time

x0 = [nPop-infected; infected; 0];  % Initial state: Susceptible, Infected, Recovered
t = linspace(0, days, days*resolution);         % Time vector, duration, data
[t x] = SIR(t, x0, R0, recovery)

figure(1)
plot(t, [x,x(:,2)+x(:,3)]);
legend ('Susceptible', 'Infectious', 'Recovered','Infected');
grid on
title('SARS-CoV-2 SIR Simulation for Slovakia')
xlabel('Time (Days)')
ylabel('Numer of cases')
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