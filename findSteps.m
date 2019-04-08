function [ walkSeg, walk, steps ] = findSteps( ap, turns )

nTurns = size(turns,1);
turnInt = [];
for ii = 1:nTurns
    turnInt = [turnInt turns(ii,1):turns(ii,2)];
end

%Steps are counted as the peak that preceeds the change in sign of the AP acceleration
apCross = find(diff(sign(ap))<0);

% %Some Samples show a second peak in the AP acceleration, if this happens,
% %choose the first peak
% [~,vly] = findpeaks(-ap, 'MinPeakProminence', 1);
% vly(ap(vly)<0) = [];
% apCross = sort([vly; apCross]);
% apCross(apCross<30) = [];

checkDiff = diff(apCross);
minDist = 40;
checkDiff = find(checkDiff < minDist);
checkDiff(ismember(checkDiff,turnInt)) = [];
apCross(checkDiff+1) = [];


steps = zeros(1,length(apCross));
for jj = 1:length(apCross)
    [~ , loc] = findpeaks(ap(1:apCross(jj)));
    if ~isempty(loc), steps(jj) = loc(end); end         
end
steps(steps==0) = [];



%Partition steps into differnt walking segments defined as time inbetween turns
%Include last step in turn preceeding walkin segment and first step in turn
%following walking segment IF it is within last/first 25% of turn AND time
%to next step is within 2 std of mean tim between steps



sd = 2*std(diff(steps));
m = mean(diff(steps));
walk = cell(1,nTurns+1);
for ii = 1:nTurns+1
    if ii==1, 
       walk{ii} = steps(steps < turns(ii,1));
       int = round(diff(turns(ii,:))/4);
       endInt = turns(ii,1):turns(ii,1)+int;
       endStep = intersect(steps, endInt);
       if ~isempty(endStep) && ~isempty(walk{ii})
           temp = endStep(1) - walk{ii}(end);
           if  temp < m+sd && temp > m-sd
               walk{ii} = [walk{ii}, endStep(1)];
           end
       end
    elseif ii>nTurns
        walk{ii} = steps(steps > turns(ii-1,2));
        int = round(diff(turns(ii-1,:))/4);
        startInt = turns(ii-1,2)-int:turns(ii-1,2);
        startStep = intersect(steps, startInt );
        if ~isempty(startStep) && ~isempty(walk{ii})
            temp = walk{ii}(1) - startStep(end);
            if temp < m+sd && temp > m-sd
                walk{ii} = [startStep(end), walk{ii}];
            end
        end
    else
        walk{ii} = steps(steps<turns(ii,1)); 
        walk{ii} = walk{ii}(walk{ii} > turns(ii-1,2));
        int = round(diff(turns(ii-1,:))/4);
        startInt = turns(ii-1,2)-int:turns(ii-1,2);
        startStep = intersect(steps, startInt );
        if ~isempty(startStep) && ~isempty(walk{ii})
            temp = walk{ii}(1) - startStep(end);
            if temp < m+sd && temp > m-sd
                walk{ii} = [startStep(end), walk{ii}];
            end
        end
        int = round(diff(turns(ii,:))/4);
        endInt = turns(ii,1):turns(ii,1)+int;
        endStep = intersect(steps, endInt);
        if ~isempty(endStep) && ~isempty(walk{ii})
           temp = endStep(1) - walk{ii}(end);
           if temp < m+sd && temp > m-sd
               walk{ii} = [walk{ii}, endStep(1)];
           end
        end
    end
end

walk(cellfun(@isempty, walk)) = [];
walkSeg = zeros(length(walk),2);
for III = 1:length(walk)
    walkSeg(III,1) = min(walk{III});
    walkSeg(III,2) = max(walk{III});
end


end

