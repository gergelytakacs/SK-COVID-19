%Based on%https://www.researchgate.net/post/Does_anybody_has_a_working_Matlab_code_for_a_disease-spread_simulation

nPop=5441120
x0 = [nPop; 78; 0]; % Initial 495 Susceptible and 5 Infectious
t = linspace(0, 60, 600); % 60-week duration (600 data points)
[t y] = ode45(@SIR, t, x0); % in MATLAB, use the 'ode45' command

figure(1)
plot(t, [y]);
legend ('Susceptible', 'Infectious', 'Recovered');

figure(2)
plot(diff(y(:,3)))
legend('Daily cases')

function xdot = SIR(t, x)
xdot = zeros(3, 1);
b = 1.4; % probability of contracting the disease (1.4-2.5)
N = x(1) + x(2) + x(3); % a fixed population for 500 individuals
g = 0.7; % recovery rate %91.75
xdot(1) = - b*x(2)*x(1)/N; % Susceptible differential equation
xdot(2) = b*x(2)*x(1)/N - g*x(2); % Infectious differential equation
xdot(3) = g*x(2); % Recovered differential equation
end