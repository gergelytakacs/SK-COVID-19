% Gergely Tak�cs, www.gergelytakacs.com
% No guarantees given, whatsoever.

clc; clear; close all;
importData;
load dataSKpred;

d1=datetime(2020,3,6,'Format','d.M'); % First confirmed case
pDay=5;               % Days to predict
neg=950; %
symptoms=5;              % Mean days before symptoms show


dt = d1+length(Day);       % Length of last data
Date = datestr(d1:dt);     % Date array with data
dp = dt+pDay;              % End date ith prediction
DatePred = datestr(d1:dp); % Date array for predictions



Nd=cumsum(Confirmed); % Number of daily cases, cumulative sum of confirmed cases
NdLog=log2(Nd);

growthFactor= ([Nd; 0]./[0; Nd]);
growthFactor=growthFactor(2:end-1);

%% Finding exponential fit to data

[fitresult,gof]=expFit(Day, Nd);
gF=fitresult.a; % Growth factor 
ci=confint(fitresult); % Confidence intervals at 95% confidentce
R2=gof.rsquare;
DayPred=1:1:length(Day)+pDay;

NdPredicted=round(gF.^DayPred);
NdPredHigh=round(ci(2).^DayPred);
NdPredLow=round(ci(1).^DayPred);


% dataSKpred(2,:)=[(max(Day)+1),NdPredicted(max(Day)+1), NdPredLow(max(Day)+1), NdPredHigh(max(Day)+1), gF, ci(1), ci(2)]
% save dataSKpred dataSKpred
%% Shift data



NdSymptoms=round(gF.^(DayPred+symptoms));
NdSymptomsHigh=round(ci(2).^(DayPred+symptoms));
NdSymptomsLow=round(ci(1).^(DayPred+symptoms));

%% Plotting

figure(1)


patch([DayPred, DayPred(end:-1:1), DayPred(1)],[NdPredLow, NdPredHigh(end:-1:1),NdPredLow(1)],'r','EdgeAlpha',0,'FaceAlpha',0.2) % Confidence intervals
hold on
grid on
patch([DayPred, DayPred(end:-1:1), DayPred(1)],[NdSymptomsLow, NdSymptomsHigh(end:-1:1),NdSymptomsLow(1)],'b','EdgeAlpha',0,'FaceAlpha',0.2) % Confidence intervals

plot(Day,Nd,'.-','LineWidth',2) % Confirmed cumulative cases
bar(Day,Confirmed) % Confirmed new cases
plot(DayPred,NdPredicted) % Predicted cases

plot(DayPred,NdSymptoms) % Predicted Shifted Cases

% Previous predictions
plot(dataSKpred(:,1),dataSKpred(:,2),'k.')
errorbar(dataSKpred(:,1),dataSKpred(:,2),dataSKpred(:,2)-dataSKpred(:,3),dataSKpred(:,2)-dataSKpred(:,4),'k')

xticks(DayPred)
xticklabels(DatePred)
xtickangle(90)
xlabel('Date')
ylabel('Cases')
legend('95% Confidence (Confirmed prediction)','95% Confidence (Total, 5 d shift)','Cumulative confirmed','New confirmed',['Exp. Approximation (Confirmed) R^2=',num2str(R2)],['Exp. Approximation (Total)'],'Location','northwest')
title(['SARS-CoV-2 Cases in Slovakia, ',datestr(dt)])
axis([0,length(DayPred),0,NdSymptoms(max(Day)+1)])
text(0.2,0.9,'github.com/gergelytakacs/SK-COVID-19','FontSize',7,'rotation',90,'Color',[0.7 0.7 0.7])
text(0.6,0.9,'gergelytakacs.com','FontSize',7,'rotation',90,'Color',[0.7 0.7 0.7])
fig = gcf;
fig.PaperUnits = 'centimeters';
fig.PaperPosition = [0 0 20 10];

cd out
print(['skCOVID19_Cases_',datestr(dt)],'-dpng','-r0')
print(['skCOVID19_Cases_',datestr(dt)],'-dpdf','-r0')
cd ..

disp(['SARS-CoV-2 na Slovensku'])
disp(['----------------------------'])
disp(['V�hlad na ',datestr(dt),' (do konca d?a):'])
disp(['Overen� pr�pady: ',num2str(NdPredicted(max(Day)+1)),' (',num2str(NdPredLow(max(Day)+1)),'-',num2str(NdPredHigh(max(Day)+1)),')']) %,'(',num2str(NdPredLow(max(Day)+1)),'-',NdPredHigh(max(Day)+1),')'])
disp(['Nov� overen� pr�pady: ',num2str(NdPredicted(max(Day)+1)-Nd(end)),' (',num2str(NdPredLow(max(Day)+1)-Nd(end)),'-',num2str(NdPredHigh(max(Day)+1)-Nd(end)),')']) %,'(',num2str(NdPredLow(max(Day)+1)),'-',NdPredHigh(max(Day)+1),')'])
disp(['Celkov� predpokladan� po?et nakazen�ch: ',num2str(NdSymptoms(max(Day)+1)),' (',num2str(NdSymptomsLow(max(Day)+1)),'-',num2str(NdSymptomsHigh(max(Day)+1)),')'])
disp(['Predpokladan� d�tum 100+ overen�ch pr�padov: ',datestr(d1+min(find(NdPredicted>100)))])
disp(['Faktor n�rastu: ',num2str((gF-1)*100),'%'])
disp(['----------------------------'])
disp(['Viac na: https://github.com/gergelytakacs/SK-COVID-19'])
