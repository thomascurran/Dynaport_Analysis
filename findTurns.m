function [peaks, turns] = findTurns(yaw, turnMin)
%Turns are identified by the peaks in the yaw signal that are more than 1
%standard deviation of the yaw signal away from 0
%Each turn period is defined by the zero crossing of the yaw signal before
%and after the peaks of the yaw signal
%MinCycle is in terms of data samples, not time

%Find Turns

ln = length(yaw);
MinCycle = round(turnMin/2);            %Window size is half the time it took for 360 turn
MinDist=floor(MinCycle/3);              %Turns must be at least a sixth of time for 360 turn

lowa=[]; higha=[];

%Search for local peaks and valleys in window size
for ii=MinCycle+1:ln-MinCycle
    a=yaw(ii-MinCycle:ii+MinCycle);
    if(yaw(ii)==min(a))
        lowa=[lowa ii];
    end
    if(yaw(ii)==max(a))
        higha=[higha ii];
    end
end

%Include only peaks/valleys that are more than 1 std from 0
peaks = higha(find(yaw(higha) > std(yaw)));
peaks = [peaks, lowa(find(yaw(lowa) < -(std(yaw))))];
peaks = sort(peaks);

%Turn period is defined as when the yaw signal crosses threshold on either side of a peak/valley
%Threshold for turns is considered the max absolute value of yaw in the first 1.5 seconds 
lim = max(abs(yaw(1:150)));
ind = find(abs(yaw) < lim);
turns = zeros(length(peaks), 2);

for jj = 1:length(peaks)
    limCross = ind - peaks(jj);
    l = limCross(limCross<0);
    l = l(end);
    r = limCross(limCross>0);
    r = r(1);
    turns(jj,:) = peaks(jj) + [l(end) , r(1)];
end

%Check if peaks on either side of turn is within 75% of peak height, if so,
%recalculate turn period to include new peak
[~, pLoc] = findpeaks(yaw);
[~, vLoc] = findpeaks(-yaw);
tol = 1.75;
for iii = 1:length(peaks)
    if yaw(peaks(iii)) > 0
        loc = pLoc;
    else
        loc = vLoc;
    end
    turnS = turns(iii,1);
    lPeak = loc - turnS;
    lPeak(lPeak>0) = [];
    lPeak = lPeak(end) + turnS;
    if abs(yaw(lPeak)) > tol*lim
        lCross = ind - lPeak;
        lCross(lCross>0)= [];
        turns(iii,1) = lCross(end) + lPeak;
    end
    turnE = turns(iii,2); 
    rPeak = loc - turnE;
    rPeak(rPeak<0) = [];
    rPeak = rPeak(1) + turnE;
    if abs(yaw(rPeak)) > tol*lim
        rCross = ind - rPeak;
        rCross(rCross<0)= [];
        turns(iii,2) = rCross(1) + rPeak;
    end
end

%Remove turns that are considered too short
short = diff(turns') < MinDist;
short = find(short);
turns(short,:) = [];
peaks(short) = [];

%Remove repeated turns
rem = [];
for jjj = 2:size(turns,1)
    if turns(jjj,:) == turns(jjj-1,:)
        rem = [rem;jjj];
    end
end
turns(rem,:) = [];

end