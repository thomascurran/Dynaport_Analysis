function [ steps, walk, walkSeg ] = stepsNoZeroCross( ap, turns )
%Method for calculating steps when the zero crossing method causes errors
ln = length(ap);
minStep = 40;
steps = [];
for jj=minStep+1:ln-minStep
    a=ap(jj-minStep:jj+minStep);
    if ap(jj) == max(a)
        steps = [steps jj];
    end
end

nTurns = size(turns,1);
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
remWalk = [];
walkSeg = zeros(length(walk),2);
for III = 1:length(walk)
    if length(walk{III}) <= 2
        remWalk = [remWalk; III];
    else
        walkSeg(III,1) = min(walk{III});
        walkSeg(III,2) = max(walk{III});
    end
end
walkSeg(remWalk,:) = [];



end

