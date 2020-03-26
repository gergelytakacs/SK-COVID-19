% Gergely Takács, www.gergelytakacs.com
% No guarantees given, whatsoever.
% Yeah, I'm going for the messiest code ever. Sorry.

% Ideas: Weighted forgetting, SIR Model fi, SEIR model

clc; clear; close all;

importData;


load dataSKpred;

% DS
% nPOP=22768
% lambda=195/y
% mu=258/y

fitbegin=1;

d1=datetime(2020,3,6,'Format','d.M'); % First confirmed case
pDay=14;                  % Days to predict  
symptoms=5.1;              % Mean days before symptoms show

%https://www.cia.gov/library/publications/the-world-factbook/geos/lo.html
popSize=5.440602;            % Population size in millions
nPop=popSize*1E6;        % Population size

dt = d1+length(Day);       % Length of last data
Date = datestr(d1:dt);     % Date array with data
dp = dt+pDay;              % End date ith prediction
DatePred = datestr(d1:dp); % Date array for predictions


%% Prepping data from the mess provided by the Slovak state

Nd=cumsum(Confirmed);                % Number of total cases, cumulative sum of new confirmed cases


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



%SIR_ID %% SIR estimation procedure
SIR_VD_ID
outFigures
outReport




%% Save data
if (max(dataSKpred(:,1))<=max(Day))
dataSKpred(end+1,:)=[(max(Day)+1),NdPredicted(max(Day)+1), NdPredLow(2), NdPredHigh(2), gF, ci(1,1), ci(2,1), 1+gFSIR/100];
save dataSKpred dataSKpred
end

