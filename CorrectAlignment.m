function [AccCorr] = CorrectAlignment(ACC, AvgOr)

I_X_SIG =3;%ap
I_Y_SIG =1;%V
I_Z_SIG=2;%ML

if mean(ACC(:,I_Y_SIG)) < -0.5
    ACC(:,I_Y_SIG) = ACC(:,I_Y_SIG)*-1;
    ACC(:,I_Z_SIG) = ACC(:,I_Z_SIG)*-1;
end

if nargin ==1
    % mean of the 3 axes
    AvgOr = mean(ACC);
end

% angle around Z axis (uses mean(X))
xphi = asin(AvgOr(1,I_X_SIG)); %AP
% angle around X axis (uses mean(Z))
zphi = asin(AvgOr(1,I_Z_SIG)); %ML

% correct data
AccCorr(:,I_X_SIG) = (cos(xphi)*ACC(:,I_X_SIG)) - (sin(xphi)*ACC(:,I_Y_SIG));
tmpv        = (sin(xphi)*ACC(:,I_X_SIG)) + (cos(xphi)*ACC(:,I_Y_SIG));
AccCorr(:,I_Z_SIG) = (cos(zphi)*ACC(:,I_Z_SIG)) - (sin(zphi)*tmpv);
AccCorr(:,I_Y_SIG) = (sin(zphi)*ACC(:,I_Z_SIG)) + (cos(zphi)*tmpv)-1;

%correct rotation
AccCorr(:,I_X_SIG+3) = (cos(xphi)*ACC(:,I_X_SIG+3)) - (sin(xphi)*ACC(:,I_Y_SIG+3));
tmpr        = (sin(xphi)*ACC(:,I_X_SIG+3)) + (cos(xphi)*ACC(:,I_Y_SIG+3));
AccCorr(:,I_Z_SIG+3) = (cos(zphi)*ACC(:,I_Z_SIG+3)) - (sin(zphi)*tmpr);
AccCorr(:,I_Y_SIG+3) = (sin(zphi)*ACC(:,I_Z_SIG+3)) + (cos(zphi)*tmpr);