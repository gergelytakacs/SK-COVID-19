% Gergely Takács, www.gergelytakacs.com
% No guarantees given, whatsoever.
% Yeah, I'm going for the messiest code ever. Sorry.

% Ideas: Weighted forgetting, SIR Model fi, SEIR model

clc; clear; close all;

importData;


load dataSKpred;

fitbegin=1;

d1=datetime(2020,3,6,'Format','d.M'); % First confirmed case
pDay=10;                  % Days to predict  
symptoms=5.1;              % Mean days before symptoms show
popSize=5.45;            % Population size in millions
nPop=popSize*1E6;        % Population size

dt = d1+length(Day);       % Length of last data
Date = datestr(d1:dt);     % Date array with data
dp = dt+pDay;              % End date ith prediction
DatePred = datestr(d1:dp); % Date array for predictions



Nd=cumsum(Confirmed); % Number of daily cases, cumulative sum of confirmed cases

%% Tests
totTest=negTest+Nd; %Total tests performed
popTest=totTest./popSize; % Tests per million people

newTest=diff(totTest);
changeTest=(newTest(end)/newTest(end-1)-1)*100; % Changes in testing

%NdLog=log2(Nd);

%% Growth factor
growthFactor= ([Nd; 0]./[0; Nd]);
growthFactor= (growthFactor(2:end-1)-1)*100;

%% Finding exponential fit to data

[fitresult,gof]=expFitStart(Day(fitbegin:end), Nd(fitbegin:end));
gF=fitresult.a; % Growth factor 
N0=fitresult.b; % Correction for zero day cases
ci=confint(fitresult); % Confidence intervals at 95% confidentce
R2=gof.rsquare;
DayPred=1:1:length(Day)+pDay;
DayPredRest=DayPred(1:end-max(Day)+1);


NdPredicted=round((gF.^DayPred)*N0);
NdPredHigh=round((ci(2,1).^DayPredRest*NdPredicted(max(Day)-1)));
NdPredLow=round((ci(1,1).^DayPredRest*NdPredicted(max(Day)-1)));


%% Shift data to account for onset of symptoms

NdSymptoms=round(gF.^(DayPred+symptoms)*N0);
NdSymptomsHigh=round(ci(2,1).^(DayPred+symptoms)*ci(2,2));
NdSymptomsLow=round(ci(1,1).^(DayPred+symptoms)*N0);

%% Residuals
NdResiduals=NdPredicted(1:max(Day))'-Nd;

%% First case
expFun = @(x)ceil(gF^(x)*N0);
firstCase = floor(fminbnd(expFun, -100, 0));

%% Testing changes

[fitresult,gof]=linFit(Day(2:end), newTest);
testA=fitresult.p1;
testB=fitresult.p2;



SIR_ID %% SIR estimation procedure
outFigures



%% Print


disp(['SARS-CoV-2 na Slovensku'])
disp(['============================'])
disp(['* Analýza ',datestr(now),''])
disp(' ')
disp('Exponenciálny model: (aktualny do konca dna)')
disp(['----------------------------'])
disp(['Overené prípady: ',num2str(NdPredicted(max(Day)+1)),' (',num2str(NdPredLow(2)),'-',num2str(NdPredHigh(2)),')']) %,'(',num2str(NdPredLow(max(Day)+1)),'-',NdPredHigh(max(Day)+1),')'])
disp(['Nové overené prípady: ',num2str(NdPredicted(max(Day)+1)-Nd(end)),' (',num2str(NdPredLow(2)-Nd(end)),'-',num2str(NdPredHigh(2)-Nd(end)),')']) %,'(',num2str(NdPredLow(max(Day)+1)),'-',NdPredHigh(max(Day)+1),')'])
disp(['Celkový predpokladaný pocet nakazených: ',num2str(NdSymptoms(max(Day)+1)),' (',num2str(NdSymptomsLow(max(Day)+1)),'-',num2str(NdSymptomsHigh(max(Day)+1)),')'])
%disp(['Predpokladaný dátum 100+ overených prípadov: ',datestr(d1+min(find(NdPredicted>100)))])
disp(['Predpokladaný dátum 1000+ overených prípadov: ',datestr(d1+min(find(NdPredicted>1000)))])
disp(['Predpokladaný dátum prvého nakazenia: ',datestr(d1+firstCase)])
disp(['Predpokladaný skutocný pocet infikovaných nultý den: ',num2str(round(N0)),' (',num2str(round(ci(1,2))),'-',num2str(round(ci(2,2))),'), (6-Mar-2020)'])
disp(['Faktor nárastu: ',num2str(round((gF-1)*100*10)/10),'% (',num2str(round((ci(1,1)-1)*100*10)/10),'%-',num2str(round((ci(2,1)-1)*100*10)/10),'%), R^2=',num2str(R2)])
disp(['Zdvojenie poctu prípadov za: ',num2str(round((70/((gF-1)*100))*10)/10),' dní'])
disp(' ')
disp(['SIR model: (aktualny do konca dna)'])
disp(['----------------------------'])
disp(['Odhad základného reprodukcného císla R0: ',num2str(round(R0est*10)/10),', (MSE: ',num2str(MSE),')'])
disp(['Denná miera odstránenia prípadov 1/gamma: ',num2str(round(dRest*10)/10),', (MSE: ',num2str(MSE),')'])


disp(['Overené prípady: ',num2str(Isim(max(Day)+1))])
disp(['Nové overené prípady: ',num2str(Isim(max(Day)+1)-Nd(end))])
disp(['Celkový predpokladaný pocet nakazených: ',num2str(Isim(max(Day)+round(symptoms)))])
disp(['Predpokladaný dátum 1000+ overených prípadov: ',datestr(d1+min(find(Isim>1000)))])
disp(['Predpokladaný dátum prvého nakazenia: ',datestr(d1-d0est)])
disp(['Predpokladaný skutocný pocet infikovaných nultý den: ',num2str(round(N0est)),' (6-Mar-2020)'])
%disp(['Predpokladaný dátum prvého nakazenia: ',datestr(d1+firstCase)])
disp(['Faktor nárastu: ',num2str(round((gFSIR*10))/10),'%'])
disp(['Zdvojenie poctu prípadov za: ',num2str( round((70/((gFSIR))*10))/10),' dní'])
disp(' ')
disp(['Stav testovania k ',datestr(dt-1),' (vratane)'])
disp(['----------------------------'])
disp(['Celkove testy na mil. obyvatelov: ',num2str(round(popTest(end)))])
disp(['Nove testy za den na mil. obyvatelov: ',num2str( round(newTest(end)/popSize))])
disp(['Denná zmena intenzity testovania: ',num2str(round(changeTest)),'%'])
disp(['Trend zmeny intenzity testovania: ',num2str(round((testA))),'% (lineárny fit)'])
disp(['============================='])
disp(['Viac na: http://covid19.gergelytakacs.com'])

%% Save data
if (max(dataSKpred(:,1))<=max(Day))
dataSKpred(end+1,:)=[(max(Day)+1),NdPredicted(max(Day)+1), NdPredLow(2), NdPredHigh(2), gF, ci(1,1), ci(2,1), 1+gFSIR/100];
save dataSKpred dataSKpred
end

