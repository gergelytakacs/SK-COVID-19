function coef = fitVirus03(getData)
%FITVIRUS Estimation of coronavirus epidemic size by logistic model

warning('off')

% obtain data
[country,sampleC,date0] = getData();
nc = length(sampleC);

% print header
fprintf('**** Estimation of epidemy size for %s\n',country)

% set time
samplaTime = 0:1:length(sampleC)-1;
% set date
samplaDate = date0 + samplaTime;

% initial guess ****************************
% Regression convergence depends significantly on the initial approximation
% It may fails for pure initial guess or for small data set.
[b0] = iniGuess(sampleC);
if isempty(b0)
    fprintf('***Warning: Fail to calculate initial quess. Use default.\n');
    b0 = [max(sampleC) 0.5 max(sampleC)]';
end
K0 = b0(1);
r0 = b0(2);
A0 = b0(3);
fprintf('  Initial guess K = %g  r = %g  A = %g\n',K0,r0,A0);
%*********************************************

% allocate arrays
K      = NaN(length(sampleC),1);
r      = NaN(length(sampleC),1);
A      = NaN(length(sampleC),1);
C0     = NaN(length(sampleC),1);
tpeak  = NaN(length(sampleC),1);
dpeak  = NaN(length(sampleC),1);
dend   = NaN(length(sampleC),1);
dCpeak = NaN(length(sampleC),1);
tau    = NaN(length(sampleC),1);
err    = NaN(length(sampleC),1);
R2     = NaN(length(sampleC),1);
R2d     = NaN(length(sampleC),1);

%initial estimaton time
n0 = ceil(0.4*length(sampleC));

% calculate daily predictions
opts = optimoptions('lsqcurvefit','Display','off',...
    'SpecifyObjectiveGradient',true);
for n = n0:length(sampleC)
    [b,resnorm,~,exitflag,output] = lsqcurvefit(@fun,b0,...
        samplaTime(1:n),sampleC(1:n),[0 0 0],[],opts);
    % save results
   % b0 = b;
    err(n) = resnorm;
    [R2(n),R2d(n)] = calcR2(samplaTime(1:n),sampleC(1:n),b);
    K(n)   = fix(b(1));
    r(n)   = b(2);
    A(n)   = b(3);
    C0(n)  = fix(K(n)/(A(n) + 1));
    % calculate turning time, max. growth rate, and growth time
    tpeak(n)  = fix(log(A(n))/r(n));
    dpeak(n)  = tpeak(n) + date0;
    dend(n)   = 2*tpeak(n) + date0;    
    dCpeak(n) = fix(r(n)*K(n)/4);
    tau(n)    = fix(4/r(n));
end

% final fit (print include statistics !)
% opts = statset('nlinfit');
% opts.RobustWgtFun = 'bisquare';
fprintf('Regression parameters for complet data set\n')
mdl = fitnlm(samplaTime(1:n),sampleC(1:n),@fun,b,...
    'CoefficientNames',{'K','r','A'}) %,'ErrorModel','combined') %,'Options',opts)
coef = mdl.Coefficients.Estimate;
if abs(coef(1)/K(nc)) > 2
    fprintf('***Warning: results of lsqcurvefit and fitnlm differs significantly. \n');
    fprintf('   Knlm/Klsq = %g\n',coef(1)/K(nc));
    fprintf('   rnlm/rlsq = %g\n',coef(2)/r(nc));
    fprintf('   Anlm/Alsq = %g\n',coef(3)/A(nc));
end

% print results
fprintf('\nEvaluation of model parameters for %s\n',country)
fprintf('%4s %10s %8s %8s %7s %5s %5s %10s %5s %5s %10s %5s\n',...
    'day','date','C','K','r','C0','Tau','end','dCdt','tpeak','peak','R2')
fprintf('%4s %10s %8s %8s %7s %5s %5s %10s %5s %5s %10s\n',...
    ' ',' ','(cases)','(cases)','(1/day)','(cases)','(day)',' ','(c/day)','(day)',' ')
for n = n0:length(sampleC)
    fprintf('%4d %10s %8d %8d %7.3f %5d %5d %10s %5d %5d %10s %5.3f\n',...
        n,datestr(samplaDate(n)),sampleC(n),K(n),r(n),C0(n),...
        tau(n),datestr(dend(n)),dCpeak(n),tpeak(n),datestr(dpeak(n)),R2(n));
end

% if fwb
%     % fit estimated final sizes
%     fprintf('\nWeibull regression of predicted final sizes for %s\n',country)
%     % Initial guess !!!!!!!!!!!!!!!!!!!!!!!!!
%     f0 = [sampleC(end) 0.13 12]';
%     n = length(sampleC);
%     mdl2 = fitnlm(samplaTime(n0:n),bb(1,n0:n),@fun1,f0)
%     f = mdl2.Coefficients.Estimate;
%     
%     % fit estimated peak time
%     fprintf('\nWeibull regression of predicted peak time for %s\n',country)
%     % Initial guess !!!!!!!!!!!!!!!!!!!!!!!!!!!!
%     ff0 = [tpeak(end) 0.13 12]';
%     n = length(sampleC);
%     mdl2 = fitnlm(samplaTime(n0:n),tpeak(n0:n),@fun1,ff0)
%     ff = mdl2.Coefficients.Estimate;
%     fprintf('Peak date %s\n',datestr(ceil(ff(1))+date0))
% end

% set simulation time and date
time = 0:1:ceil(2.75*tpeak(n));
date = date0 + time;

% plot final prediction of epedimy evaluation
figure
hold on
% ...plot prediction
plot(date,fun(b,time)/1000,'k','LineWidth',2)
% for i = 1:length(time)
%     fprintf('%s  %g  %g\n',datestr(date(i)),time(i),fun(b,time(i)));
% end
%ax = gca;
%ax.XTick = linspace(date(1),date(end),7);
%------------------------------
% ...plot limits epidemy phases
ylm = get(gca,'Ylim');  % get y-axes limits
xlm = get(gca,'Xlim');  % get x-axes limits
www = xlm(2);
hhh = ylm(2); 
tp2 = tpeak(nc) - fix(2/r(nc)) + date0;
tp3 = tpeak(nc) + fix(2/r(nc)) + date0;
tp4 = 2*tpeak(nc) + date0;  % end date
tp = tpeak(nc) + date0;
h = plot([tp,tp],[0,hhh],'r','LineWidth',1);
h.Annotation.LegendInformation.IconDisplayStyle = 'off';

% tp = tpeak(nc) - fix(2/r(nc)) + date0;
% h = plot([tp,tp],[0,hhh],'r','LineWidth',1);
h.Annotation.LegendInformation.IconDisplayStyle = 'off';
h = fill([tp2,tp3,tp3,tp2],[0 0 hhh hhh],'r','FaceAlpha',0.15,'EdgeColor','none');
h.Annotation.LegendInformation.IconDisplayStyle = 'off';

%h = plot([tp3,tp3],[0,hhh],'r','LineWidth',1);
%h.Annotation.LegendInformation.IconDisplayStyle = 'off';
h = fill([tp3,tp4,tp4,tp3],[0 0 hhh hhh],'y','FaceAlpha',0.15,'EdgeColor','none');
h.Annotation.LegendInformation.IconDisplayStyle = 'off';

%h = plot([tp4,tp4],[0,hhh],'r','LineWidth',1);
%h.Annotation.LegendInformation.IconDisplayStyle = 'off';
h = fill([tp4,www,www,tp4],[0 0 hhh hhh],'g','FaceAlpha',0.15,'EdgeColor','none');
h.Annotation.LegendInformation.IconDisplayStyle = 'off';
%------------
%... plot data
scatter(samplaDate,sampleC/1000,50,'k','filled')
h = scatter(samplaDate,sampleC/1000,30,'w','filled');
h.Annotation.LegendInformation.IconDisplayStyle = 'off';
% for i = 1:length(samplaDate)
%     fprintf('%s  %g\n',datestr(samplaDate(i)),sampleC(i));
% end
%-------------------------
% ...add axes labels
%xtk = get(gca, 'XTick');
datetick('x',20,'keeplimits')
%xlim([date(1) date(end)])
%set(gca, 'XTick',date(1):7:date(end))

ylabel('Infected (1000)')
xlabel('Date')
% add growth rate
yyaxis right
plot(date,dfun(b,time),'b','LineWidth',1)
ddC=diff(sampleC);
ddC(ddC<0) = 0;
scatter(samplaDate(1:end-1),ddC,30,'b','filled')
% dd = 7;
% xtk = get(gca, 'XTick')
% set(gca, 'XTick', [date(1):dd:date(end)])
ylabel('Infected/day')
%... add legend
legend('Predicted','Actual','Infection rate','Actual','Location','best')
% ...add title
title(sprintf('Coronavirus epidemic in %s',country))
% ...add grid
grid on
%... add tick marks
% % xtk = get(gca, 'XTick')
% dd = 7;
% set(gca, 'XTick', [date(1):dd:date(end)])
hold off

% plot growth rate of epidemic
% figure
% hold on
% plot(date,dfun(b,time),'LineWidth',2)
% ylabel('Infected/day')
% % yyaxis right
% % plot(date,dfun(b,time)./fun(b,time),'LineWidth',2)
% % ylabel('Infected/per capita/day')
% datetick('x',20,'keeplimits')
% title(sprintf('Coronavirus epidemic rate for %s',country))
% grid on
% hold off

%short-term forecasting
predict()

% plot evaluation of final size
figure
hold on
bar(samplaDate(n0:nc),K(n0:nc)/1000); %,'LineWidth',2)
datetick('x',20,'keeplimits')
ylabel('Infected (1000)')
xlabel('Date')
title(sprintf('Daily estimated final size of epidemic for %s',country))
mxx = max(K(n0:nc)/1000);
if mxx > 2*K(nc)/1000
    ylim([0 2*K(nc)/1000]);
end
grid on
hold off

warning('on')

fprintf('Summary\n')
fprintf('-------\n')
fprintf(' date: %10s  day: %3d\n',datestr(samplaDate(nc)),nc);
fprintf(' start date: %s \n',datestr(date0));
fprintf(' number of cases: %d\n',sampleC(nc));
fprintf(' estimated epidemic size (cases): %d\n',K(nc));
fprintf(' estimated epidemic rate (1/day): %d\n',r(nc));
fprintf(' estimated initial state (cases): %d\n',C0(nc));
fprintf(' estimated initial doubling time (day): %3.1f\n',round(log(2)/r(nc),1));
fprintf(' estimated duration of fast growth phase (day): %d\n',tau(nc));
fprintf(' estimated peak date: %s  day: %d \n',datestr(dpeak(nc)),tpeak(nc));
fprintf(' estimated peak rate (cases/day): %d\n',dCpeak(nc));
fprintf(' estimated end of transition phase: %s  day: %d\n',datestr(dend(nc)),2*tpeak(nc));
tp2 = tpeak(nc) - fix(2/r(nc));
tp3 = tpeak(nc) + ceil(2/r(nc)) ;
tp4 = 2*tpeak(nc);  % end date
tp = tpeak(nc) ;
if nc < tp2
    phase = 1;
    txt = 'slow growth';
elseif nc < tp
    phase = 2;
    txt = 'fast growth acceleration phase';
elseif nc < tp3
    phase = 3;
    txt = 'fast growth deceleration phase';
elseif nc < tp4
    phase = 4;
    txt = 'slow growth transition phase';
else
    phase = 5;
    txt = 'ending phase';
end

fprintf(' epidemic phase: %g/5 %s\n',phase, txt);
fprintf('Statistics: total R2 = %6.3f, rate R2 = %6.3f\n',R2(end),R2d(end));


%=========================================================================%

    function [y,J] = fun(b,t)
        % Logistic model
        y = b(1)./(1 + b(3)*exp(-b(2)*t));
        if nargout > 1
            nt = length(t);
            J = zeros(3,nt);
             J(1,1:nt) = 1./(1 + b(3)*exp(-b(2)*t));
             J(3,1:nt) = -b(1)*exp(-b(2)*t).*J(1,1:nt).^2;
             J(2,1:nt) = -b(3)*t.*J(3,1:nt);
             J = J';
        end
    end

    function y = dfun(b,t)
        % logistic model growth rate
        y = b(1)*b(2)*b(3)*exp(-b(2)*t)./(1 + b(3)*exp(-b(2)*t)).^2;
    end

    function y = fun1(b,t)
        % Weibull model
        y = b(1)./(1 + b(3)*exp(-b(2)*t));
    end

    function predict
        %PREDICT - short time forcasting.

        K0 = K(nc);
        r0 = r(nc);
        A0 = A(nc);
        
        fprintf('\nShort-term forecasting for %s\n',country)
        fprintf('%4s %12s %10s %10s %10s %10s %10s  %10s\n',...
            'day','date','actual','predict','error %','c./day act.','c./day pred.','error %')
        for n = nc-5:nc+6
            
            if n <= nc
                c0 = sampleC(n) - sampleC(n-1);
                c1 = round(funC(n-1),0)-round(funC(n-2),0);
                fprintf('%4d %12s %10d %10d %10.2f %10d %10d  %10.2f\n',n,datestr(n-1+date0),sampleC(n),round(funC(n-1),0),...
                    abs(round(funC(n-1),0)/sampleC(n)-1)*100,...
                    c0,c1,abs(c1/c0-1)*100) ;
            else
                if round(funC(n-1),0) > sampleC(end)
                fprintf('%4d %12s %10s %10d %10s %10s %10d\n',n,datestr(n-1+date0),'-',...
                    round(funC(n-1),0),'-','-',round(funC(n-1),0)-round(funC(n-2),0));
                else
                fprintf('%4d %12s %10s\n',n,datestr(n-1+date0),'**** Fail: actual > predict');                
                break
                end
            end
        end
        
        %=======================================
        
        function C = funC(t)
            C = K0/(1+A0*exp(-r0*t));
        end
    end

    function [R2,R2d] = calcR2(t,C,b)
        % calculate R2
        K00 = b(1);
        r00 = b(2);
        A00 = b(3);
        Ca = funC(t);
        zbar = sum(C)/length(C);
        SStot = sum((C - zbar).^2);
        SSres = sum((C - Ca).^2);
        R2 = 1 - SSres/SStot;      
        dCa = diff(Ca);
        dC = diff(C);
        zbar = sum(dC)/length(dC);
        SStot = sum((dC - zbar).^2);
        SSres = sum((dC - dCa).^2);
        R2d = 1 - SSres/SStot;           
        function Ca = funC(t)
            Ca = K00./(1+A00*exp(-r00*t));
        end
    end

end

function [b0] = iniGuess(C)
%INIGUESS Initial guess for logistic regression
% calculate initial K, r, A using data from three equidistant points 
%
% Input:
%   C -- data
%
% Output:
%   b0 -- initial guess = [K r A]' or [] if calculation fails

    b0 = [];
    n = length(C);

    nmax = max(1,fix(0.5*n));

    for i = 1:nmax

        % calculate time interval for equidistant points: k-2*m, k-m, k
        if mod(n-i+1,2) == 0
            k1 = i;
            k3  = n-1;
        else
            k1 = i;
            k3 = n;
        end
        k2 = (k1 + k3)/2;
        m = k2 - k1 -1;

        if k1 <1 || k2 < 1 || k3 < 1 || m < 1
            break
        end

        % calculate K, r, A ...

        %.. calculate K
        q = C(k2)^2 - C(k3)*C(k1);
        if q <= 0
            %      fprintf('***Warning: iniGuess q = %g  k1 = %d k2= %d k3 = %d \n',...
            %          q, k1, k2, k3)
            continue
        end
        p = C(k1)*C(k2) - 2*C(k1)*C(k3) + C(k2)*C(k3);
        if p <= 0
            %   fprintf('***Warning: iniGuess p = %g\n',p)
            continue
        end
        K = C(k2)*p/q;

        % ... calculate r
        r = log(C(k3)*(C(k2) - C(k1))/C(k1)/(C(k3) - C(k2)))/m;
        if r < 0
            %  fprintf('***Warning: iniGuess r = %g\n',r)
            continue
        end

        %... calculate A
        A = (C(k3) - C(k2))*(C(k2) - C(k1))/q*...
            (C(k3)*(C(k2) - C(k1))/C(k1)/(C(k3) - C(k2)))^((k3-m)/m);
        if A <= 0
            %   fprintf('***Warning: iniGuess A = %g\n',r)
            continue
        end

        % this is initial guess
        b0 = [K r A]';
        break

    end
end



