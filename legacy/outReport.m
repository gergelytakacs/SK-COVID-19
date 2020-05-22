
%% Print


disp(['SARS-CoV-2 na Slovensku'])
disp(['============================'])
disp(['* Anal�za ',datestr(now),''])
disp(' ')
disp(['SEIR homog�nn� infektologick� model'])
disp(['bez vit�lnej dynamiky (aktualny do konca dna):'])
disp(['(Kr�tkodob� predikcia s parametrami na z�klade �dajov.)'])
disp(['(Parametre nekonverguj� spr�vne pre ch�baj�ce d�ta na vyliecen� pripady a umrtia.)'])
disp(['----------------------------'])
disp(['Overen� pr�pady: ',num2str(round(NdSIRnext)),' (do konca dna)'])
disp(['Nov� overen� pr�pady: ',num2str(NdSIRnext-Nd(end)),' (do konca dna)'])
disp(['Celkov� predpokladan� pocet nakazen�ch: ',num2str(IsimPred(round(symptoms)+2))])
disp(['Predpokladan� d�tum 1000+ overen�ch pr�padov: ',datestr(d1+max(Day)+min(find(IsimPred>1000)))])
if (d0est<31)
disp(['Predpokladan� d�tum prv�ho nakazenia: ',datestr(d1-d0est)])
end
%disp(['Predpokladan� skutocn� pocet infikovan�ch nult� den: ',num2str(round(N0est)),' (6-Mar-2020)'])
disp(['Faktor n�rastu: ',num2str(round((gFSIR*10))/10),'%'])
disp(['Zdvojenie poctu pr�padov za: ',num2str( round((70/((gFSIR))*10))/10),' [dn�]'])
%disp(['Odhad z�kladn�ho reprodukcn�ho c�sla R0: ',num2str(round(R0est*10)/10),', (MSE: ',num2str(MSE),')'])
disp(['Miera r�chlosti infekcie 1/beta: ',num2str(round(1/betaEst*10)/10),' [dni], kr�tkodob� fit'])
disp(['Miera latencie infekcie 1/sigma: ',num2str(round(1/sigmaEst*10)/10),' [dni], kr�tkodob� fit'])
disp(['Miera odstr�nenia pr�padov gamma: ',num2str(gammaEst),', kr�tkodob� fit'])
disp(['Percentu�lna kvalita zhody modelu (akt. infekcie): ',num2str(round(fitPerc*10)/10),' %, MSE: ',num2str(round(MSE))])
%disp(['Miera odstr�nenia pr�padov 1/gamma: ',num2str(round(1/gammaEst*10)/10),', (MSE: ',num2str(MSE),')'])
disp(' ')
disp('Exponenci�lny model: (aktualny do konca dna)')
disp(['----------------------------'])
disp(['Overen� pr�pady: ',num2str(NdPredicted(max(Day)+1)),' (',num2str(NdPredLow(2)),'-',num2str(NdPredHigh(2)),')']) %,'(',num2str(NdPredLow(max(Day)+1)),'-',NdPredHigh(max(Day)+1),')'])
disp(['Nov� overen� pr�pady: ',num2str(NdPredicted(max(Day)+1)-Nd(end)),' (',num2str(NdPredLow(2)-Nd(end)),'-',num2str(NdPredHigh(2)-Nd(end)),')']) %,'(',num2str(NdPredLow(max(Day)+1)),'-',NdPredHigh(max(Day)+1),')'])
disp(['Celkov� predpokladan� pocet nakazen�ch: ',num2str(NdSymptoms(max(Day)+1)),' (',num2str(NdSymptomsLow(max(Day)+1)),'-',num2str(NdSymptomsHigh(max(Day)+1)),')'])
%disp(['Predpokladan� d�tum 100+ overen�ch pr�padov: ',datestr(d1+min(find(NdPredicted>100)))])
disp(['Predpokladan� d�tum 1000+ overen�ch pr�padov: ',datestr(d1+min(find(NdPredicted>1000)))])
if (firstCase>31)
disp(['Predpokladan� d�tum prv�ho nakazenia: ',datestr(d1+firstCase)])
end
disp(['Predpokladan� skutocn� pocet infikovan�ch nult� den: ',num2str(round(N0)),' (',num2str(round(ci(1,2))),'-',num2str(round(ci(2,2))),'), (6-Mar-2020)'])
disp(['Faktor n�rastu: ',num2str(round((gF-1)*100*10)/10),'% (',num2str(round((ci(1,1)-1)*100*10)/10),'%-',num2str(round((ci(2,1)-1)*100*10)/10),'%)'])
disp(['Zdvojenie poctu pr�padov za: ',num2str(round((70/((gF-1)*100))*10)/10),' dn�'])
disp(['Kvalita zhody modelu R^2 ',num2str(R2)])
disp(' ')

disp('Poynomi�lny model: (aktualny do konca dna)')
disp(['----------------------------'])
if (NdPredictedPoly(max(Day)+1)>Nd(end))
disp(['Overen� pr�pady: ',num2str(NdPredictedPoly(max(Day)+1))]) %,'(',num2str(NdPredLow(max(Day)+1)),'-',NdPredHigh(max(Day)+1),')'])
disp(['Nov� overen� pr�pady: ',num2str(NdPredictedPoly(max(Day)+1)-Nd(end))]) %,'(',num2str(NdPredLow(max(Day)+1)),'-',NdPredHigh(max(Day)+1),')'])
end
disp(['Celkov� predpokladan� pocet nakazen�ch: ',num2str(NdSymptomsPoly(max(Day)+1))])
disp(['Predpokladan� d�tum 1000+ overen�ch pr�padov: ',datestr(d1+min(find(NdPredictedPoly>1000)))])
%disp(['Predpokladan� d�tum prv�ho nakazenia: ',datestr(d1+firstCasePoly)])
%disp(['Predpokladan� skutocn� pocet infikovan�ch nult� den: ',num2str(round(N0)),' (',num2str(round(ci(1,2))),'-',num2str(round(ci(2,2))),'), (6-Mar-2020)'])
disp(['Faktor n�rastu (priemer, posledn� t��den): ',num2str(round( gFPoly*10)/10),'%'])
disp(['Zdvojenie poctu pr�padov za: ',num2str(round(70/gFPoly*10)/10),' dn�'])
disp(['Kvalita zhody modelu R^2 ',num2str(R2Poly)])
disp(' ')

disp(['Stav testovania k ',datestr(dt-1),' (vratane)'])
disp(['----------------------------'])
disp(['Celkove testy na mil. obyvatelov: ',num2str(round(popTest(end)))])
disp(['Nove testy za den na mil. obyvatelov: ',num2str( round(newTest(end)/popSize))])
disp(['Pomer pozit�vnych testov: ',num2str(round(Confirmed(end)/newTest(end)*100*10)/10),'%'])
disp(['Denn� zmena intenzity testovania: ',num2str(round(changeTest)),'%'])
disp(['Tyzdenny trend intenzity testovania: ',num2str(round((testA*10))/10),'% (line�rny fit)'])
disp(['============================='])
disp(['Viac na: http://covid19.gergelytakacs.com'])