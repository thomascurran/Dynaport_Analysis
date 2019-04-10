function [a1,f1]=FFTplot(t,y,Fs,fc1,fc2,toplot)

a1=[];f1=[];%a2=[];f2=[];
y=(y-mean(y))./std(y);
T = 1/Fs;                     % Sample time
L = length(y);                     % Length of signal
NFFT = 2^nextpow2(L); % Next power of 2 from length of y
Y = fft(y,NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);
SSFFT=2*abs(Y(1:NFFT/2+1));


ix0=find(f>fc1);ix2=find(f<fc2);
ix02=intersect(ix0,ix2);
f02=f(ix02);
SSFFT02=SSFFT(ix02);

IIImm=find(imregionalmax(SSFFT02));
if (numel(IIImm)>1)
%     IIImm=IIImm(2:end);
    iiiii=find(SSFFT02(IIImm)==max(SSFFT02(IIImm)));
    if (numel(iiiii)>0)  
            ii1=IIImm(iiiii(1));
            f1=f02(ii1);
            a1=SSFFT02(ii1);
    end
end

% % % Plot single-sided amplitude spectrum.
if (toplot==1)
        figure;
        subplot(2,1,1); plot(f,SSFFT) ;grid on;hold on; stem(f1,a1,'r');
        title('Single-Sided Amplitude Spectrum of y(t)') ;xlabel('Frequency (Hz)'); ylabel('|Y(f)|');
        subplot(2,1,2); plot(t,y); grid on;
        title('Origonal signal   y(t)') ;xlabel('t'); ylabel('y(t)');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ix1=find(f>0.5);ix2=find(f<3);ix3=find(f>3);ix4=find(f<8);
% ix01=intersect(ix1,ix2);ix12=intersect(ix3,ix4);
% f01=f(ix01);
% f12=f(ix12);
% SSFFT01=SSFFT(ix01);
% SSFFT12=SSFFT(ix12);
% 
% ii1=find(SSFFT01==max(SSFFT01(imregionalmax(SSFFT01))));
% if (numel(ii1)>0)  
%         ii1=ii1(1);
%         f1=f01(ii1)
%         a1=SSFFT01(ii1);
% end
% 
% ii2=find(SSFFT12==max(SSFFT12(imregionalmax(SSFFT12))));
% if (numel(ii2)>0)  
%         ii2=ii2(1);
%         f2=f12(ii2)
%         a2=SSFFT12(ii2);
% end
% % % % % % Plot single-sided amplitude spectrum.
% figure;
% subplot(2,1,1); plot(f,SSFFT) ;grid on;hold on; stem(f1,a1,'r'); hold on; stem(f2,a2,'r');
% title('Single-Sided Amplitude Spectrum of y(t)') ;xlabel('Frequency (Hz)'); ylabel('|Y(f)|');
% subplot(2,1,2); plot(t,y); grid on;
% title('Origonal signal   y(t)') ;xlabel('t'); ylabel('y(t)');


