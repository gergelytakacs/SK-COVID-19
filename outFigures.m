
%% Colors
blue   = [0    0.4470    0.7410];
orange = [0.8500    0.3250    0.0980];

%% Cases


figure(1)

patch([DayPred(max(Day):end), DayPred(end:-1:max(Day)), DayPred(max(Day))],[NdPredLow, NdPredHigh(end:-1:1),NdPredLow(1)],'r','EdgeAlpha',0,'FaceAlpha',0.2) % Confidence intervals
hold on
grid on
patch([DayPred, DayPred(end:-1:1), DayPred(1)],[NdSymptomsLow, NdSymptomsHigh(end:-1:1),NdSymptomsLow(1)],'b','EdgeAlpha',0,'FaceAlpha',0.2) % Confidence intervals

plot(Day,Nd,'.-','LineWidth',2,'Color',blue,'Marker','.','MarkerSize',12) % Confirmed cumulative cases
bar(Day,Confirmed) % Confirmed new cases
plot(DayPred,NdPredicted,'Color',orange,'LineWidth',1) % Predicted cases

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
title(['SARS-CoV-2 Cases in Slovakia: Exponential model, ',datestr(dt)])
axis([0,length(DayPred),0,NdSymptoms(max(Day)+1)])
text(0.5,0.9,'covid19.gergelytakacs.com','FontSize',10,'rotation',90,'Color',[0.7 0.7 0.7])
fig = gcf;
fig.PaperUnits = 'centimeters';
fig.PaperPosition = [0 0 20 10];

cd out
print(['skCOVID19_Exp_Cases_',datestr(dt)],'-dpng','-r0')
print(['skCOVID19_Exp_Cases_',datestr(dt)],'-dpdf','-r0')

axis([0,length(Day)+1,0,dataSKpred(end,4)])

print(['skCOVID19_Exp_Cases_Detail',datestr(dt)],'-dpng','-r0')
print(['skCOVID19_Exp_Cases_Detail',datestr(dt)],'-dpdf','-r0')
cd ..


%% Growth factor

figure(2)

% Previous predictions
plot(dataSKpred(:,1)-1,(dataSKpred(:,5)-1)*100,'k.')
hold on
errorbar(dataSKpred(:,1)-1,(dataSKpred(:,5)-1)*100,(dataSKpred(:,6)-1)*100-(dataSKpred(:,5)-1)*100,(dataSKpred(:,7)-1)*100-(dataSKpred(:,5)-1)*100,'k')
plot(dataSKpred(:,1)-1,(dataSKpred(:,8)-1)*100,'kx')
hold on
grid on

plot(Day(2:end),growthFactor,'.-','LineWidth',2) % Predicted Shifted Cases

xticks(DayPred)
xticklabels(DatePred)
xtickangle(90)
xlabel('Date')
ylabel('Growth factor [%]')
legend('Growth factor (exponential fit)','Growth factor (exponential fit, conf.)','Growth factor (SIR)','Growth factor (data)','Location','northwest')
title(['SARS-CoV-2 Growth factor in Slovakia, ',datestr(dt)])
axis([2,length(Day+1),0,150])
text(2.5,0.9,'covid19.gergelytakacs.com','FontSize',10,'rotation',90,'Color',[0.7 0.7 0.7])
cd out
print(['skCOVID19_GrowthFactor_',datestr(dt)],'-dpng','-r0')
print(['skCOVID19_GrowthFactor_',datestr(dt)],'-dpdf','-r0')
cd ..

%% Testing

figure(3)

hold on
plot(Day,totTest,'.-','LineWidth',2) % Predicted Shifted Cases
bar(Day(2:end),newTest) % Confirmed new cases
plot(Day(2:end),testA.*Day(2:end)+testB,'k--')
grid on

xticks(DayPred)
xticklabels(DatePred)
xtickangle(90)
xlabel('Date')
ylabel('Tests')
legend('Total tests','New Tests','Trend','Location','northwest')
title(['SARS-CoV-2 Tests in Slovakia, ',datestr(dt)])
axis([1,max(Day)+1,0,max(totTest)])
text(1.5,100,'covid19.gergelytakacs.com','FontSize',10,'rotation',90,'Color',[0.7 0.7 0.7])
cd out
print(['skCOVID19_Tests_',datestr(dt)],'-dpng','-r0')
print(['skCOVID19_Tests_',datestr(dt)],'-dpdf','-r0')
cd ..

%% Residuals
% 
% figure(4)
% 
% patch([0 max(Day), max(Day) 0 ],[mean(NdResiduals)+std(NdResiduals) mean(NdResiduals)+std(NdResiduals),mean(NdResiduals)-std(NdResiduals) mean(NdResiduals)-std(NdResiduals)],'b','EdgeAlpha',0,'FaceAlpha',0.2) % Confidence intervals
% patch([0 max(Day), max(Day) 0 ],[mean(NdResiduals)+2*std(NdResiduals) mean(NdResiduals)+2*std(NdResiduals),mean(NdResiduals)-2*std(NdResiduals) mean(NdResiduals)-2*std(NdResiduals)],'b','EdgeAlpha',0,'FaceAlpha',0.1) % Confidence intervals
% 
% patch([0 max(Day), max(Day) 0 ],[mean(Isim(1:max(Day))-Nd)+std(Isim(1:max(Day))-Nd) mean(Isim(1:max(Day))-Nd)+std(Isim(1:max(Day))-Nd),mean(Isim(1:max(Day))-Nd)-std(Isim(1:max(Day))-Nd) mean(Isim(1:max(Day))-Nd)-std(Isim(1:max(Day))-Nd)],'r','EdgeAlpha',0,'FaceAlpha',0.2) % Confidence intervals
% patch([0 max(Day), max(Day) 0 ],[mean(Isim(1:max(Day))-Nd)+2*std(Isim(1:max(Day))-Nd) mean(Isim(1:max(Day))-Nd)+2*std(Isim(1:max(Day))-Nd),mean(Isim(1:max(Day))-Nd)-2*std(Isim(1:max(Day))-Nd) mean(Isim(1:max(Day))-Nd)-2*std(Isim(1:max(Day))-Nd)],'r','EdgeAlpha',0,'FaceAlpha',0.1) % Confidence intervals
% 
% hold on
% plot(Day,NdResiduals,'.-','LineWidth',2) % Predicted Shifted Cases
% grid on
% plot(Day,Isim(1:max(Day))-Nd,'.-','LineWidth',2) % Predicted Shifted Cases
% 
% xticks(DayPred)
% xticklabels(DatePred)
% xtickangle(90)
% xlabel('Date')
% ylabel('Cases (difference)')
% legend('1 sigma (Exponential)','2 sigma (Exponential)','1 sigma (SIR)','2 sigma (SIR)','Case residuals (Exponential)','Case residuals (SIR)','Location','northwest')
% title(['SARS-CoV-2 Case prediction residuals for Slovakia, ',datestr(dt)])
% %axis([1,max(Day)+1,0,max(totTest)])
% text(0.5,-40,'covid19.gergelytakacs.com','FontSize',10,'rotation',90,'Color',[0.7 0.7 0.7])
% cd out
% print(['skCOVID19_Residuals_',datestr(dt)],'-dpng','-r0')
% print(['skCOVID19_Residuals_',datestr(dt)],'-dpdf','-r0')
% cd ..

%% Output (Infected)
figure(5)

plot(Day,I,'-o','MarkerSize',6)
hold on
grid on
plot(DayPred(max(Day):end-1),IsimPred,'--','Color',blue)      % Prediction only
plot(Day(SIR_fitBegin:end),IsimFit)      % Prediction only
plot(-symptoms:1:(length(IsimSymptoms)-symptoms-1),IsimSymptoms)


xticks(DayPred)
xticklabels(DatePred)
xtickangle(90)
xlabel('Date')
ylabel('Cases')
legend('Infections (data)','Predicted infections (SIR model)','SIR model fit','Total Infected (SIR model, 5d shift)','Location','northwest')
title(['SARS-CoV-2 Infections in Slovakia: SIR model w/ vital dynamics, ',datestr(dt)])
axis([0,length(DayPred),0,NdSymptoms(max(Day)+1)])
text(0.5,0.9,'covid19.gergelytakacs.com/','FontSize',10,'rotation',90,'Color',[0.7 0.7 0.7])
fig = gcf;
fig.PaperUnits = 'centimeters';
fig.PaperPosition = [0 0 20 10];

cd out
print(['skCOVID19_SIR_Cases_',datestr(dt)],'-dpng','-r0')
print(['skCOVID19_SIR_Cases_',datestr(dt)],'-dpdf','-r0')

axis([0,length(Day)+1,0,dataSKpred(end,4)])

print(['skCOVID19_SIR_Cases_Detail',datestr(dt)],'-dpng','-r0')
print(['skCOVID19_SIR_Cases_Detail',datestr(dt)],'-dpdf','-r0')
cd ..

%% Tests per positive

%plot(Day(2:end),newTest/Confirmed(2:end))



