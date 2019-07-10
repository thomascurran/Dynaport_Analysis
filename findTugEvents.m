function [ apIX, yawIX, pitchIX, sts1 ] = findTugEvents( acc )
%Input acc has been filtered with 4th order butterworth filter with cutoff
%frequency of 3 Hz

%Acc-Derived start/end times of TUG come from AP: six1, six2, eix1, eix2
%Start/end times of turns from YAW: tst1, tet1, tst2, tet2, and yix1, yix2
%Start/end times of transitions come from PITCH: p1a, p1b, p2a, p2b

%apIX = [six1, six2, eix1, eix2];
%yawIX = [tst1, tet1, tst2, tet2, yix1, yix2];
%pitchIX = [p1a, p1b, p2a, p2b];


ap = acc(:,3); yaw = acc(:,4); pitch = acc(:,5);
ln = length(acc);
mdpt = floor(ln/2);
fs = 100;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find Start and End Index

%Separate windows b/c more time added prior to start than after end
win1 = floor(ln/3); %win2 = floor(ln/4);

%Check to see if ap changes sign multiple times
tempAlign = length(find(diff(sign(ap))));
if tempAlign < 10, ap = ap-mean(ap); end;

%Find Start Location
[pkS2, locS2]=findpeaks(-ap(1:win1));
if ~isempty (pkS2)
    [~, indS2] = max(pkS2);
    six2 = locS2(indS2);
else
    [~,six2] = min(ap(1:win1));
end

aX = find(diff(sign(ap(1:six2))));
if isempty(aX)
    th = 0.1;
    aThresh = ap(six2)*th;
    aX = find(diff(sign(ap(1:six2)-aThresh)));
    if isempty(aX), aX = six2;
    else aX = aX(end); end 
end
[~, locS1]=findpeaks(ap(1:aX(end)));
if isempty(locS1)
    six2 = locS2(indS2+1);
    aX = six2;
    [~, locS1]=findpeaks(ap(1:aX(end)));
    if isempty(locS1), [~, locS1]=max(ap(1:aX(end))); end
end
six1 = locS1(end);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Find Turns


absYaw = abs(yaw(six2:ln));
[mag, ind] = findpeaks(absYaw, 'MinPeakWidth', fs/4);
M1 = max(mag);
ix1 = find(mag==M1);
peaks(1) = ind(ix1);
mag(ix1) = []; ind(ix1) = [];
M2 = max(mag);
ix2 = find(mag==M2);
peaks(2) = ind(ix2);
mag(ix2) = []; ind(ix2) = [];

%Find new peak if peaks are within 2 seconds of each other
MinDist = 2*fs;
while abs(diff(peaks)) < MinDist
    M2 = max(mag);
    ix2 = find(mag==M2);
    peaks(2) = ind(ix2);
    if numel(mag)>0
        mag(ix2) = []; ind(ix2) = [];
    else
        break;
    end
end

peaks = sort(peaks);
peaks = peaks + six2 - 1;


%Turn period is defined as when the yaw signal crosses threshold on either side of a peak/valley
%Threshold for turns is considered the max absolute value of yaw in the first 1.5 seconds after acc derived start 
lim = max(absYaw(1:150));       %absYaw defined from apIX(1):apIX(4)
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
% [~, pLoc] = findpeaks(yaw);
% [~, vLoc] = findpeaks(-yaw);
% tol = 1.75;
% for ii = 1:length(peaks)
%     if yaw(peaks(ii)) > 0
%         loc = pLoc;
%     else
%         loc = vLoc;
%     end
%     turnS = turns(ii,1);
%     lPeak = loc - turnS;
%     lPeak(lPeak>0) = [];
%     lPeak = lPeak(end) + turnS;
%     if abs(yaw(lPeak)) > tol*lim
%         lCross = ind - lPeak;
%         lCross(lCross>0)= [];
%         turns(ii,1) = lCross(end) + lPeak;
%     end
%     turnE = turns(ii,2); 
%     rPeak = loc - turnE;
%     rPeak(rPeak<0) = [];
%     if numel(rPeak)>0
%         rPeak = rPeak(1) + turnE;
%         if abs(yaw(rPeak)) > tol*lim
%             rCross = ind - rPeak;
%             rCross(rCross<0)= [];
%             turns(ii,2) = rCross(1) + rPeak;
%         end
%     end
% end



tst1 = turns(1,1); tet1 = turns(1,2);
tst2 = turns(2,1); tet2 = turns(2,2);
yix1 = peaks(1); yix2 = peaks(2);

yawIX = [tst1, tet1, tst2, tet2, yix1, yix2];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Find End Index

%Added buffer so Eix1 is not at end of test
eixWin = ln-50;
[pkE1, locE1]=findpeaks(-ap(tst2:eixWin));
if ~isempty(pkE1)
    [~, indE1] = max(pkE1);
    eix1 = locE1(indE1) + tst2 - 1;
else
    [~, indE1] = min(ap(tst2:eixWin));
    eix1 = indE1 + tst2 - 1;
end
aX = find(diff(sign(ap(eix1:ln))));
if isempty(aX)
    tol = 0.25;
    thresh = tol*ap(eix1);
    xThresh = ap(eix1:ln) > thresh;
    aX = find(xThresh>0, 1, 'first');
    if isempty(aX), aX=0; end
end
aX = aX(1) + eix1;
[~, locE2]=findpeaks(ap(aX:ln));
if isempty(locE2) 
    %Find first point that is within 10% of max height (may change 10%)
    tol = .10;
    thresh = tol*max(ap(eix1:ln));
    xThresh = ap(eix1:ln) - thresh;
    locE2 = find(xThresh>0);
    if isempty(locE2)
        eix2 = length(ap);
    else
        eix2 = locE2(1) + eix1 - 1;
    end
else
    eix2 = locE2(1)+aX - 1;
end


%Check that the ending is correct
%If range of AP acc in middle of performance is LARGER than range between
%EIX1 and EIX2, recalculate End Index by reversing the order in which EIX 1
%and 2 are calculated
tol = 0.8;
apRng = max(ap(mdpt-fs:mdpt+fs)) - min(ap(mdpt-fs:mdpt+fs));
apCheck = (ap(eix2) - ap(eix1));
if  apCheck < apRng*tol
    [pkE2, locE2]=findpeaks(ap(tst2:ln));
    if ~isempty(pkE2)
        [~, indE2] = max(pkE2);
        eix2 = locE2(indE2) + tst2 - 1;
    else
        [~,indE2] = max(ap(tst2:ln));
        eix2 = indE2 + tst2 - 1;
    end
    [~, locE1]=findpeaks(-ap(tst2:eix2));
    if ~isempty(locE1), eix1 = locE1(end) + tst2 - 1; end

end
    

apIX = [six1, six2, eix1, eix2];

    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Find Transitions



ss1=apIX(1)-0.5*fs;if (ss1<1 ), ss1=1; end
ee1 = apIX(2)+fs;
if ss1>ee1, ee1 = mdpt; end
ss2 = yawIX(3);
ee2=apIX(4); %+0.5*fs;if (ee2>ln ), ee2=ln; end
if ss2>ee2, ss2 = mdpt; ee2 = ln; end

pProm = 5;


[pk1A, loc1A]=findpeaks(-pitch(ss1:ee1), 'MinPeakProminence', pProm);
if isempty(pk1A), [pk1A, loc1A]=findpeaks(-pitch(ss1:ee1)); end   
if isempty(pk1A), [pk1A, loc1A]=min(pitch(ss1:ee1)); end
[~, ind] = max(pk1A);
p1a = loc1A(ind) + ss1 - 1;
if (ee1-p1a) < 50
    p1a = loc1A(1);
end
pX = find(diff(sign(pitch(p1a:ee1))));
if isempty(pX)
    th = 0.1;
    pThresh = pitch(p1a)*th;
    pX = find(diff(sign(pitch(p1a:ee1)-pThresh)));
    if isempty(pX), pX = 0;
    else pX = pX(1); end 
end
pX = pX(1) + p1a;
[~, loc1B]=findpeaks(pitch(pX:ee1), 'MinPeakProminence', pProm);
if isempty(loc1B),
    [~, loc1B] = findpeaks(pitch(p1a:ee1), 'MinPeakProminence', pProm);
    if isempty(loc1B), [~, loc1B] = max(pitch(p1a:ee1)); end
end
p1b = loc1B(1) + pX - 1;


[pk2A, loc2A]=findpeaks(pitch(ss2:ee2), 'MinPeakProminence', pProm);
if isempty(loc2A), [pk2A, loc2A]=findpeaks(pitch(ss2:ee2)); end
if isempty(loc2A), [pk2A, loc2A]=max(pitch(ss2:ee2)); end
[~,ind2A] = max(pk2A);
p2a = loc2A(ind2A) + ss2;
pX = find(diff(sign(pitch(ss2:p2a))));
if isempty(pX)
    th = 0.1;
    pThresh = pitch(p2a)*th;
    pX = find(diff(sign(pitch(ss2:p2a)-pThresh)));
    if isempty(pX), pX = p2a;
    else pX = pX(end)+ss2; end 
else pX = pX(end)+ss2; end
[~, loc2B] = findpeaks(-pitch(ss2:pX), 'MinPeakProminence', pProm);
if isempty(loc2B),
    [~, loc2B] = findpeaks(-pitch(ss2:p2a), 'MinPeakProminence', pProm);
    if isempty(loc2B), [~, loc2B] = min(-pitch(ss2:p2a)); end
end
p2b = loc2B(end)+ss2-1;



% [pk2B, loc2B]=findpeaks(-pitch(ss2:ee2));
% %if peak is detected at end, remove it from list b/c p2b occurs before p2a
% temp = ee2-ss2;
% if (loc2B(end) == temp)
%     loc2B(end) = [];
%     pk2B(end) = [];
% end
% 
% [~, ind] = max(pk2B);
% p2b = loc2B(ind) + ss2;
% %If less than half second between p2b and end of search, take second min
% if (ee2-p2b) < 50
%     loc2B(ind) = [];
%     pk2B(ind) = [];
%     [~, ind2] = max(pk2B);
%     p2b = loc2B(ind2) + ss2;
% end
% pX = find(diff(sign(pitch(p2b:ee2))));
% if isempty(pX), pX = 0; end
% pX = pX(1) + p2b;
% [pk2A, loc2A]=findpeaks(pitch(pX:ee2));
% [~, ind] = max(pk2A);
% p2a = loc2A(ind) + pX;
% 
% if isempty(p2a)
%     [pk, loc]=findpeaks(pitch(ss2:ee2));
%     [~, ind] = max(pk);
%     p2a = loc(ind) + ss2;
%     pX = find(diff(sign(pitch(ss2:p2a))));
%     if isempty(pX)
%         pX = ee2;
%     else
%         pX = pX(end) + ss2;
%     end
%     [pk, loc]=findpeaks(-pitch(ss2:pX));
%     [~, ind] = max(pk);
%     p2b = loc(ind) + ss2;
% end
%     
% 
% %Check magnitude of peak differences
% check = 0;
% [pk, loc] = findpeaks(pitch(ss2:p2b));
% if ~isempty(pk)
%     pk = pk(end); 
%     loc = loc(end)+ss2;
% end
% check = abs(pk-pitch(p2b)) > abs(pitch(p2a) - pitch(p2b));
% 
% if check
%     p2a = loc;
%     pX = find(diff(sign(pitch(ss2:p2a))));
%     pX = pX(end) + ss2;
%     [~, loc] = findpeaks(-pitch(ss2:pX));
%     p2b = loc(end)+ss2;
% end

pitchIX = [p1a p1b, p2a, p2b];

%Determine if multiple attempts for sts1
sts1 = 0;
temp = find(diff(sign(pitch(1:p1a))));
if ~isempty(temp)
    temp = temp(end);
    begAMP = max(abs(pitch(1:temp)));
    pitchAMP = max(abs(pitch(p1a:p1b)));
    tol = 0.5;
    sts1 = begAMP >= pitchAMP * tol;
end


end