function [t x] = SIR(t, x0, R0, recovery)

[t x] = ode45(@SIR_base,t,x0);

function xdot = SIR_base(t, x);
xdot = zeros(3, 1);

gamma = 1/recovery; % recovery rate 1/g = e.g. 14 [days]
beta=R0*gamma;% probability of contracting the disease (1.4-2.5)

N = x(1) + x(2) + x(3);                  % Computing total population from original data
xdot(1) = - beta*x(2)*x(1)/N;            % Differential equation for Susceptible cases
xdot(2) =   beta*x(2)*x(1)/N - gamma*x(2); % Differential equation for Infected cases
xdot(3) =   gamma*x(2);                     % Differential equation for Recovered cases
end

end