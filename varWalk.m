function [stpReg, strReg, stpSym, nSteps, walkTime, stepTime] = varWalk(acc, walkSeg, walk)

fs = 100;
nSeg = size(walkSeg,1);
ln = 8*nSeg;

stpReg = zeros(1,nSeg); strReg = stpReg; stpSym = stpReg;
nSteps = 0; walkTime = 0; stepTime = [];

for ii = 1:nSeg
    %Calculate Step/Stride Regularity and Step Symmetry
    vert = acc(walkSeg(ii,1):walkSeg(ii,2),1);
    vert = (vert-mean(vert)) ./ std(vert);

    [c, lags] = xcov(vert, 'unbiased');
    d0 = find(lags==0);
    c = c(d0:end);
    lags = lags(d0:end);
    
    if max(c)>1
        c = c./max(c);
    end

    thresh = 0.05;
    [Ad, ind] = findpeaks(c, 'MinPeakProminence', thresh, 'MinPeakHeight', 0.1);
    d=lags(ind);
    
    if length(d)<2
        [Ad, ind] = findpeaks(c);
        rem = find(Ad<0);
        Ad(rem) = [];
        ind(rem) = [];
        d = lags(ind);
        
        %If there are no peaks in c, something is wrong with the signal
        if isempty(d)
            %Find new walking segment using vertical acc
            [~, tempInd] = findpeaks(vert, 'MinPeakProminence', thresh, 'MinPeakHeight', 0);
            vInd = (tempInd(1):tempInd(end)) + walkSeg(ii,1);
            vNew = acc(vInd,1);
            vNew = (vNew - mean(vNew)) ./ std(vNew);
            [c, lags] = xcov(vNew, 'unbiased');
            d0 = find(lags==0);
            c = c(d0:end);
            lags = lags(d0:end);
            if max(c)>1, c = c./max(c); end
            [Ad, ind] = findpeaks(c, 'MinPeakProminence', thresh, 'MinPeakHeight', 0.1);
            d=lags(ind);
        end
    end

    
    d1=d(1); Ad1=Ad(1);
    if length(d)>=2
        d2=d(2); Ad2=Ad(2);
    else
        d2 = length(c);
        Ad2 = c(d2);
    end
        
    
    if (d2-d1) < d1/2 && length(d) > 3
        Ad1 = max([Ad1, Ad2]);
        d1 = d(find(Ad==Ad1));
        d2 = d(3);
        Ad2 = c(d(3));
    end
    
    stpReg(ii) = Ad1;
    strReg(ii) = Ad2;
    stpSym(ii) = Ad1/Ad2;
    
    %Calculate Step Characteristics
    nSteps = nSteps + length(walk{ii}) - 1;
    walkTime = walkTime + (walkSeg(ii,2) - walkSeg(ii,1));
    stepTime = [stepTime, diff(walk{ii})];
    
end

walkTime = walkTime/fs;
stepTime = stepTime/fs;

stepTimeAvg = mean(stepTime);
stepTimeSD = std(stepTime);
stepTimeCV = stepTimeSD/stepTimeAvg;

stepLen = ln/nSteps;
cadence = (nSteps/walkTime)*60;
speed = ln/walkTime;




end