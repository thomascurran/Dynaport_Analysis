%Assumes normal naming convention and file locations from Dynaport_QC
%useQC = 0 to not include the QC files
useQC = 0;

p = 'C:\Users\Thomas\Documents\Dynaport_Errors\';
fileTxt = '0000-19796-50019-1539691955.156372-1539692475.885483_32FT.txt';
filename = [p fileTxt];

if useQC
    pathRemove = 'segmented\';
    pathQC = [p(1:end-length(pathRemove)) 'qc\'];
    fileRemove = '_32FT.txt';
    fileQC = [fileTxt(1:end-length(fileRemove)) '.qcd'];
    filenameQC = [pathQC fileQC];
end

fs = 100;

signal = textread(filename);
remBeg = 5*fs; remEnd = 3*fs;
avgOr = mean(signal(fs/2:remBeg - (fs/2),:));
acc = signal(remBeg:length(signal)-remEnd, :);
acc = CorrectAlignment(acc, avgOr);
acc = real(acc);
g = 32.174;
acc(:,1:3) = acc(:,1:3)*g;

fc = 3;
[b, a] = butter(4,fc/(fs/2));
accFilt = filtfilt(b,a, acc);
ap = accFilt(:,3);
yaw = accFilt(:,4);

if useQC
    qc = importdata(filenameQC);
    qcData = qc.data;
    t360(1) = qcData(4,4) - qcData(4,3);
    t360(2) = qcData(5,4) - qcData(5,3);
    if any(t360 ==0)
        t360 = sum(t360);
    elseif sum(t360) == 0
        t360 = 250;
    end
else
    t360 = 250;
end

turnMin = min(t360);
[peaks, turns] = findTurns(yaw, turnMin);

[ walkSeg, walk, steps ] = findSteps( ap, turns );

rem = [];
nSeg = size(walkSeg,1);
for count = 1:nSeg
    if walkSeg(count,1)==walkSeg(count,2) || walkSeg(count,1) > walkSeg(count,2)
        rem = [rem;count];
    end
end
walkSeg(rem,:) = [];
nSeg = nSeg - length(rem);

walkLN = 8*length(walkSeg);

%Check turn segments are acceptable
rem2 = [];
nTurns = size(turns,1);
for count2 = 1:nTurns
    if turns(count2,1)==turns(count2,2) || turns(count2,1) > turns(count2,2)
        rem2 = [rem2;count2];
    end
end
turns(rem2,:) = [];
    

[stpReg, strReg, stpSym, nSteps, walkTime, stepTime] = varWalk(acc, walkSeg, walk);

%%
%Plotting 

timevec = linspace(0.0, (length(acc) -1 )/100, length(acc));
    
tSteps = (steps - 1) ./ 100;
tPeaks = (peaks - 1) ./ 100;
tTurns = (turns - 1) ./ 100;



%AP Acc Plot
apLim = [min(ap) , max(ap)];
figure, hold on

line(timevec, ap, 'Color' , 'k');
line(tSteps, ap(steps), 'Marker', '*', 'Color' , 'g', 'LineStyle' , 'none');

for ii = 1:size(tTurns,1)
    removeAP(ii) = rectangle('Position' , [tTurns(ii,1), apLim(1), diff(tTurns(ii,:)), diff(apLim)], 'FaceColor', [1 .72 .72], 'EdgeColor', [0 0 0], 'LineStyle', 'none');
    uistack(removeAP(ii), 'bottom');
end

for ii = 1:length(walk)
    walkLim = [walk{ii}(1), walk{ii}(end)]/100;
    walkSeg(ii) = rectangle('Position' , [walkLim(1), apLim(1), diff(walkLim), diff(apLim)], 'EdgeColor', 'b');
end
title('AP Acc');

yawLim = [min(yaw) , max(yaw)];
figure, hold on
line(timevec, yaw, 'Color', 'k');
line(tPeaks, yaw(peaks), 'Marker', '*', 'Color' , 'r', 'LineStyle' , 'none');
for ii = 1:size(tTurns,1)
    removeYaw(ii) = rectangle('Position' , [tTurns(ii,1), yawLim(1), diff(tTurns(ii,:)), diff(yawLim)], 'FaceColor', [1 .72 .72], 'EdgeColor', [0 0 0], 'LineStyle', 'none');
    uistack(removeYaw(ii), 'bottom');
end
title('Yaw');