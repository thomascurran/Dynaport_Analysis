close all;
clear all;


p = 'C:\Users\Thomas\Documents\Dynaport_Errors\TUG\';
fileTxt = '0000-19796-50019-1541414036.160614-1541414718.870148_TUG_1.txt';
filename = [p fileTxt];

signal = textread(filename);

g = 32.174;
fs = 100;
remBeg = 3*fs; remEnd = 1.5*fs;

orient1 = mean(signal(1:remBeg,:));

%Leave 1 second on either side of marker
acc = signal(remBeg:length(signal)-remEnd, :);
acc1 = CorrectAlignment(acc, orient1);
acc1 = real(acc1);
acc1(:,1:3) = acc1(:,1:3)*g;

fc = 3;
[B, A] = butter(4,fc/(fs/2));
acc1 = filtfilt(B,A, acc1);


[ apIX, yawIX, pitchIX, sts1 ] = findTugEvents( acc1 );
six1 = apIX(1); six2 = apIX(2);
p1a = pitchIX(1); p1b = pitchIX(2);

seg = floor((yawIX(4) - yawIX(3))/8);
orWalk = mean(acc(yawIX(3)+seg:yawIX(4)-seg,:));
acc2 = CorrectAlignment(acc, orWalk);
acc2 = real(acc2);
acc2(:,1:3) = acc2(:,1:3)*g;
acc2 = filtfilt(B,A,acc2);


[ apIX, yawIX, pitchIX, ~] = findTugEvents( acc2 );
%Replace First Transitions with calculations from Sit Orientation
apIX(1) = six1; apIX(2) = six2;
pitchIX(1) = p1a; pitchIX(2) = p1b;

ap2 = acc2(:,3);
[ walkSeg, walk, steps ] = findTugSteps( ap2, apIX, yawIX );

[ DATA ] = varTUG( apIX, yawIX, pitchIX, acc1, acc2 );

[stpReg, strReg, stpSym, nSteps, walkTime, stepTime] = varWalk(acc2, walkSeg, walk);

%%
%Plot Signal

ap = acc2(:,3);
yaw = acc2(:,4);
pitch = acc2(:,5);

timevec = linspace(0.0, (length(acc2) -1 )/100, length(acc2));

tAp = (apIX - 1) ./ 100;
tPitch = (pitchIX - 1) ./ 100;
tYaw = (yawIX - 1) ./ 100;
tTurns = [tYaw(1), tYaw(2); tYaw(3), tYaw(4)];
tPeaks = [tYaw(5), tYaw(6)];
tWalkSeg = (walkSeg - 1) ./ 100;
tSteps = (steps - 1) ./ 100;


figure, hold on
%AP Acc Plot
subplot(3,1,1)
apLim = [min(ap) , max(ap)];
line(timevec, ap, 'Color' , 'k');
line(tAp, ap(apIX), 'Marker', 'o', 'Color' , 'r', 'LineStyle' , 'none');
line(tSteps, ap(steps), 'Marker', '*', 'Color' , 'g', 'LineStyle' , 'none');

for ii = 1:size(tTurns,1)
    removeAP(ii) = rectangle('Position' , [tTurns(ii,1), apLim(1), diff(tTurns(ii,:)), diff(apLim)], 'FaceColor', [1 .72 .72], 'EdgeColor', [0 0 0], 'LineStyle', 'none');
    uistack(removeAP(ii), 'bottom');
end
for ii = 1:size(walkSeg,1)
    walkLim(ii) = rectangle('Position' , [tWalkSeg(ii,1), apLim(1), tWalkSeg(ii,2) - tWalkSeg(ii,1), diff(apLim)], 'EdgeColor', 'b');
end


%Pitch Acc Plot
subplot(3,1,2)
pitchLim = [min(pitch) , max(pitch)];
line(timevec, pitch, 'Color' , 'k');
line(tPitch, pitch(pitchIX), 'Marker', 's', 'Color' , 'r', 'LineStyle' , 'none');


%Yaw Plot
subplot(3,1,3)
yawLim = [min(yaw) , max(yaw)];
line(timevec, yaw, 'Color', 'k');
line(tYaw(5:6), yaw(yawIX(5:6)), 'Marker', '*', 'Color' , 'r', 'LineStyle' , 'none');

for ii = 1:size(tTurns,1)
    removeYaw(ii) = rectangle('Position' , [tTurns(ii,1), yawLim(1), diff(tTurns(ii,:)), diff(yawLim)], 'FaceColor', [1 .72 .72], 'EdgeColor', [0 0 0], 'LineStyle', 'none');
    uistack(removeYaw(ii), 'bottom');
end