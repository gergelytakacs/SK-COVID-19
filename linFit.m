function [fitresult, gof] = linFit(testDay, newTest)

%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( testDay, newTest );

% Set up fittype and options.
ft = fittype( 'poly1' );

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft );




