function [ walkSeg, walk, steps ] = findTugSteps( ap, apIX, yawIX )

turns = [yawIX(1), yawIX(2); yawIX(3), yawIX(4)];

nTurns = 2;
turnInt = [yawIX(1):yawIX(2), yawIX(3):yawIX(4)];



minStep = 30;
steps = [];
for ii=apIX(2):apIX(3)
    a=ap(ii-minStep:ii+minStep);
    if ap(ii) == max(a)
        steps = [steps ii];
    end
end

sd = 2*std(diff(steps));
m = mean(diff(steps));
walk = cell(1,2);


FLAG = zeros(1,2);

walk{1} = steps(steps < yawIX(1));
%eliminate errors from small walking segments
if isempty(walk{1})
   FLAG(1) = 1;
else
   int = round((yawIX(2)-yawIX(1))/4);
   endInt = yawIX(1):yawIX(1)+int;
   endStep = intersect(steps, endInt);
   if ~isempty(endStep)
       temp = endStep(1) - walk{1}(end);
       if  temp < m+sd && temp > m-sd
           walk{1} = [walk{1}, endStep(1)];
       end
   end
   if length(walk{1}) < 3, FLAG(1) = 1; end
end



walk{2} = steps(steps < yawIX(3)); 
walk{2} = walk{2}(walk{2} > yawIX(2));
%eliminate errors from small walking segments
if isempty(walk{2})
   FLAG(2) = 1;
else
    int = round((yawIX(2) - yawIX(1))/4);
    startInt = yawIX(2)-int:yawIX(2);
    startStep = intersect(steps, startInt );
    if ~isempty(startStep)
        temp = walk{2}(1) - startStep(end);
        if temp < m+sd && temp > m-sd
            walk{2} = [startStep(end), walk{2}];
        end
    end
    int = round((yawIX(4) - yawIX(3))/4);
    endInt = yawIX(3):yawIX(3)+int;
    endStep = intersect(steps, endInt);
    if ~isempty(endStep)
       temp = endStep(1) - walk{2}(end);
       if temp < m+sd && temp > m-sd
           walk{2} = [walk{2}, endStep(1)];
       end
    end
    if length(walk{2}) < 3, FLAG(2) = 1; end
end


%eliminate walking segments without steps
check = find(FLAG);
walk(check) = [];

walkSeg = zeros(length(walk),2);
for ii = 1:length(walk)
    walkSeg(ii,1) = min(walk{ii});
    walkSeg(ii,2) = max(walk{ii});
end

end