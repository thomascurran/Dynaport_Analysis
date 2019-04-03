function [jerk, rms_RD, rms_ML, rms_AP, mv_RD, cf, tp, ML, AP, pML, pAP, tTot, ln] = varsSway(a)
%a is the acceleration signal, fs is the sampling frequency
%tp (Total power) is the integrated area of the power spectrum
%cf (centroidal frequency) is the frequency at which the spectral mass is concentrated
%jerk is the time derivative of acceleration is a measure of smoothness of postural corrections. it is used quantifies the amount of these active postural corrections during quiet standing.
%jerk is dependent on signal size
%rms is the magnitude of acc traces
%mv is mean velocity
%all variables are calculated from the resultant distance (RD = sqrt(AP^2 +
%ML^2)

jerk = []; rms_RD = []; mv_RD = []; cf = []; tp = [];

fs = 100;

tTot = length(a)/fs;

%Convert Signal from units of g to m/s^2
g = 9.81;
a(:, 1:6) = g * a(:, 1:6);

%Remove the first half second from the begining and end
%since some variables are dependent on signal size, analyze same length of
%signal accross all cases
a = a(fs/2:end-(fs/2) , :);
ln = length(a);
newdur=17; 
mid=floor(ln/2);
ddt=newdur/2; 
ssmp=ddt*fs; %number of samples from each side
newlen=length([mid-ssmp:mid+ssmp]);
if (newlen<ln)
    a=a(mid-ssmp:mid+ssmp,:);
    ln=length(a(:,1));
end

APo=a(:,3);%AP
MLo=a(:,2);%ML
RDo=sqrt(APo.^2+MLo.^2);%resultant distance


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Frequency Measures

%Estimate Power Spectral Density
[Pxx,f] = pmtm(RDo,4.5,[],fs);
len=length(Pxx);
len_vec=(1:len);

%Limit PSD within frequency band defined by f0 and f1
f0 = 0.15;
f1 = 3.5;
f0ix=find(f<=f0,1,'last');
f1ix=find(f<=f1,1,'last');
Pxx=Pxx(f0ix:f1ix);
Pxx = Pxx';
f=f(f0ix:f1ix);
len_vec=len_vec(f0ix:f1ix);

df=diff(f); df=df(1);

M0=sum(Pxx);
M1=df*sum(len_vec.*Pxx);
M2=sum(((df*len_vec').^2)'.*Pxx);

tp=M0;
cf=sqrt(M2/M0);
fd=sqrt(1-(M1^2)/(M0*M2)); %frequency dispersion is a unitless measure of the variability in the frequency content of the power spectral density


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Acceleration Measures

%Filter data with 4th order lowpass butterworth filter
fc=3.5; %3.5 if eliminating PD tremor
[B,A] = butter(4,2*fc/fs,'low');
APo = filtfilt(B,A,APo);
MLo = filtfilt(B,A,MLo);


%Subtract the average from the signal
APav=(1/ln)*sum(APo);
MLav=(1/ln)*sum(MLo);
AP=APo-APav;
ML=MLo-MLav;
RD=sqrt(AP.^2+ML.^2);

rms_RD = sqrt((1/ln)*sum(RD.^2));

dfAP=diff(AP);
dfML=diff(ML);
jerk = 0.5*(sum(dfAP.^2)+sum(dfML.^2));

%Calculate Velocity and Position
vAP = diff(cumtrapz(AP))/fs;
vML = diff(cumtrapz(ML))/fs;
vRD = sqrt(vAP.^2+ vML.^2);
pAP = diff(cumtrapz(vAP))/fs;
pML = diff(cumtrapz(vML))/fs;
pRD = sqrt(pAP.^2+ pML.^2);


%Convert position from m to cm
pAP = pAP*100;
pML = pML*100;


mv_RD = mean(vRD);
totex = sum(pRD); %Total Excursion


t = (1:length(AP))/fs;

rms_AP = sqrt((1/ln)*sum(AP.^2));
rms_ML = sqrt((1/ln)*sum(ML.^2));
rms_AP_line = rms_AP*ones(size(t));
rms_ML_line = rms_ML*ones(size(t));

ln = ln/fs;

% figure, plot(pML,pAP);
% 
% figure
% subplot(2,1,1), hold on, plot(t, ML,'b', t, rms_ML_line, 'r'), title('ML')
% subplot(2,1,2), hold on, plot(t, AP,'b', t, rms_AP_line, 'r'), title('AP')



end



    

