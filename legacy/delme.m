%Delaytest
t=1:0.1:100;

gamma=1/10;

tau=20;



gammaT=gamma*(1-exp((-t/tau)));

plot(t,gammaT)
