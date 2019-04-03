function [ DATA ] = varTUG( apIX, yawIX, pitchIX, acc1, acc2 )
%Updated by TC on 01/22/19

DATA = [];

%acc1 is for the sitting orientation, acc2 is for the standing orientation

six1 = apIX(1); six2 = apIX(2); eix1 = apIX(3); eix2 = apIX(4);
ts1 = yawIX(1); te1 = yawIX(2); ts2 = yawIX(3); te2 = yawIX(4); yix1 = yawIX(5); yix2 = yawIX(6);
p1a = pitchIX(1); p1b = pitchIX(2); p2a = pitchIX(3); p2b = pitchIX(4);

fs = 100;
T=(1:length(acc1))./fs;
DATA.dur = (eix2 - six1) / fs;
if DATA.dur < 0, DATA.dur = NaN; end

%First Transition (Sit to Stand)
v = acc1(:,1); ml = acc1(:,2); ap = acc1(:,3);
yaw = acc1(:,4); pitch = acc1(:,5); roll = acc1(:,6);


DATA.apRNG_STS1 = max(ap(six1:six2)) - min(ap(six1:six2));
DATA.apDUR_STS1 = T(six2) - T(six1);
if DATA.apDUR_STS1 < 0, DATA.apDUR_STS1 = NaN; end
jerk1=polyfit(T(six1:six2),ap(six1:six2)',1);
DATA.apJERK_STS1 = jerk1(1);
if DATA.apJERK_STS1 > 0, DATA.apJERK_STS1 = NaN; end
DATA.apMD_STS1=median(ap(six1:six2));
DATA.apSD_STS1=std(ap(six1:six2));
DATA.apRMS_STS1 = rms(ap(six1:six2));

six_m=six1+floor((six2-six1)/2);
jerk1A=polyfit(T(six1:six_m),ap(six1:six_m)',1);
DATA.apJERK_STS1_A = jerk1A(1);
jerk1B=polyfit(T(six_m:six2),ap(six_m:six2)',1);
DATA.apJERK_STS1_B = jerk1B(1);


DATA.p1aAMP = pitch(p1a);
DATA.p1bAMP = pitch(p1b);
DATA.pitchDUR_STS1 = T(p1b) - T(p1a);
if DATA.pitchDUR_STS1 < 0, DATA.pitchDUR_STS1 = NaN; end
DATA.pitchRNG_STS1 = max(pitch(p1a:p1b)) - min(pitch(p1a:p1b));
DATA.pitchMD_STS1 = median(pitch(p1a:p1b));
jerk1 = polyfit( T(p1a:p1b), pitch(p1a:p1b)' ,1);
DATA.pitchJERK_STS1 = jerk1(1);
if DATA.pitchJERK_STS1 < 0, DATA.pitchJERK_STS1 = NaN; end
DATA.pitchRMS_STS1 = rms(pitch(p1a:p1b));
DATA.pitchSD_STS1 = std(pitch(p1a:p1b));


p1=p1a+floor((p1b-p1a)/2);
jerkp1A=polyfit(T(p1a:p1),pitch(p1a:p1)',1);
DATA.pitchJERK_STS1_A = jerkp1A(1);
jerkp1B=polyfit(T(p1:p1b),pitch(p1:p1b)',1);
DATA.pitchJERK_STS1_B = jerkp1B(1);

mlRNG_STS1= max(ml(six1:six2)) - min(ml(six1:six2));
mlSD_STS1=std(ml(six1:six2));
mlMD_STS1=median(ml(six1:six2));
mlRMS_STS1=rms(ml(six1:six2));

vRNG_STS1= max(v(six1:six2)) - min(v(six1:six2)); 
vSD_STS1=std(v(six1:six2));
vMD_STS1=median(v(six1:six2));
mvRMS_STS1=rms(v(six1:six2));

rollRNG_STS1=max(roll(six1:six2)) - min(roll(six1:six2));
rollSD_STS1=std(roll(six1:six2));
rollMD_STS1=median(roll(six1:six2));
rollRMS_STS1=rms(roll(six1:six2));

yawRNG_STS1=max(yaw(six1:six2)) - min(yaw(six1:six2)); 
yawSD_STS1=std(yaw(six1:six2));
yawMD_STS1=median(yaw(six1:six2));
yawRMS_STS1=rms(yaw(six1:six2));

%Change to standing Orientation
v = acc2(:,1); ml = acc2(:,2); ap = acc2(:,3);
yaw = acc2(:,4); pitch = acc2(:,5); roll = acc2(:,6);

%First Turn
DATA.yawAMP_T1 = abs(yaw(yix1));
DATA.yawRNG_T1 = max(yaw(ts1:te1)) - min(yaw(ts1:te1));
yawDUR_T1 = (T(te1) - T(ts1))/fs;
DATA.yawDUR_T1 = yawDUR_T1;
if DATA.yawDUR_T1 < 0, DATA.yawDUR_T1 = NaN; end
[~,f_AP_T1]=FFTplot(T(ts1:te1),ap(ts1:te1),fs,0.5,3,0);
DATA.yawF_T1 = f_AP_T1;
DATA.NUM_steps_AP_T1=f_AP_T1*yawDUR_T1;

%Second Turn
DATA.yawAMP_T2 = abs(yaw(yix2));
DATA.yawRNG_T1 = max(yaw(ts2:te2)) - min(yaw(ts2:te2));
yawDUR_T2 = (T(te2) - T(ts2))/fs;
DATA.yawDUR_T2 = yawDUR_T2;
if DATA.yawDUR_T2 < 0, DATA.yawDUR_T2 = NaN; end
[~,f_AP_T2]=FFTplot(T(ts2:te2),ap(ts2:te2),fs,0.5,3,0);
DATA.yawF_T2 = f_AP_T2;
DATA.NUM_steps_AP_T2=f_AP_T2*yawDUR_T2;


%Second Transition (St-Si)

DATA.apRNG_STS2 = max(ap(eix1:eix2)) - min(ap(eix1:eix2));
DATA.apDUR_STS2 = T(eix2) - T(eix1);
if DATA.apDUR_STS2 < 0, DATA.apDUR_STS2 = NaN; end
jerk2=polyfit(T(eix1:eix2),ap(eix1:eix2)',1);
DATA.apJERK_STS2 = jerk2(1);
if DATA.apJERK_STS2 < 0, DATA.apJERK_STS2 = NaN; end
DATA.apMD_STS2=median(ap(eix1:eix2));
DATA.apSD_STS2=std(ap(eix1:eix2));
DATA.apRMS_STS2 = rms(ap(eix1:eix2));

eix_m=eix1+floor((eix2-eix1)/2);
jerk2A=polyfit(T(eix1:eix_m),ap(eix1:eix_m)',1);
DATA.apJERK_STS2_A = jerk2A(1);
jerk2B=polyfit(T(eix_m:eix2),ap(eix_m:eix2)',1);
DATA.apJERK_STS2_B = jerk2B(1);

DATA.p2aAMP = pitch(p2a);
DATA.p2bAMP = pitch(p2b);
DATA.pitchDUR_STS2 = T(p2a) - T(p2b);
if DATA.pitchDUR_STS2 < 0, DATA.pitchDUR_STS2 = NaN; end
DATA.pitchRNG_STS2 = max(pitch(p2b:p2a)) - min(pitch(p2b:p2a));
DATA.pitchMD_STS2 = median(pitch(p2b:p2a));
jerk2 = polyfit( T(p2b:p2a), pitch(p2b:p2a)' ,1);
DATA.pitchJERK_STS2 = jerk2(1);
if DATA.pitchJERK_STS2 < 0, DATA.pitchJERK_STS2 = NaN; end
DATA.pitchRMS_STS2 = rms(pitch(p2b:p2a));
DATA.pitchSD_STS2 = std(pitch(p2b:p2a));

p2=p2b+floor((p2a-p2b)/2);
jerkp2A=polyfit(T(p2b:p2),pitch(p2b:p2)',1);
DATA.pitchJERK_STS2_A = jerkp2A(1);
jerkp2B=polyfit(T(p2:p2a),pitch(p2:p2a)',1);
DATA.pitchJERK_STS2_B = jerkp2B(1);

mlRNG_STS2= max(ml(eix1:eix2)) - min(ml(eix1:eix2)); 
mlSD_STS2=std(ml(eix1:eix2));
mlMD_STS2=median(ml(eix1:eix2));
mlRMS_STS2=rms(ml(eix1:eix2));

vRNG_STS2= max(v(eix1:eix2)) - min(v(eix1:eix2)); 
vSD_STS2=std(v(eix1:eix2));
vMD_STS2=median(v(eix1:eix2));
mvRMS_STS2=rms(v(eix1:eix2));

rollRNG_STS2= max(roll(eix1:eix2)) - min(roll(eix1:eix2)); 
rollSD_STS2=std(roll(eix1:eix2));
rollMD_STS2=median(roll(eix1:eix2));
rollRMS_STS2=rms(roll(eix1:eix2));

yawRNG_STS2= max(yaw(eix1:eix2)) - min(yaw(eix1:eix2));
yawSD_STS2=std(yaw(eix1:eix2));
yawMD_STS2=median(yaw(eix1:eix2));
yawRMS_STS2=rms(yaw(eix1:eix2));



end

