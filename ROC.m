% I = importdata('file.txt');				% Import file with Average level values
%							% File contains two columns of the form:
%							% Average Level (signal present) Average Level (signal absent)
% S = std(I,0,1);					% Compute Standard Deviation
% M = mean(I,1);					% Compute Mean

% Create a normal probability distribution with mu = final average and
% sigma = standard deviation
M(1) = -60.89583; M(2) = -77.80833;
S(1) = 11.8 ; S(2) = 0.8177;
Psignalpresent = makedist('Normal', 'mu', M(1), 'sigma', S(1));
Psignalabsent = makedist('Normal', 'mu', M(2), 'sigma', S(2));
threshold = -60;
% Compute cumulative distributed function values for the probability
% distribution values at the threshold level
Pdetection = 1-cdf(Psignalpresent,threshold)
Pfalsealarm = 1-cdf(Psignalabsent,threshold)

level = [-90:-30];
% Receiver Performance
figure(1);
plot(Level,Psignalabsent.pdf(Level));
hold on
plot(Level,Psignalpresent.pdf(Level),’m’);
hold on
Y = 0:0.1:0.3;
X = threshold * ones(size(Y))
plot(X, Y, 'r--');
xlabel ('Level (dB)');
legend(’No signal present’,’Signal present’,’Threshold’);

% ROC Plot
Pfa_ROC = 1-cdf(Psignalabsent,Level);
Pd_ROC = 1-cdf(Psignalpresent,Level);		
figure(2);
plot(Pfa_ROC, Pd_ROC);
title('Receiver Operating Characteristics');
ylabel ('Probability of Detection');
xlabel ('Probability of False Alarm');
