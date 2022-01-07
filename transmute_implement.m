function implement = transmute_implement(mandatory,depend,choice,trial_implement,actNo)
implement = zeros(1,actNo+2);
implement(actNo+1) = Inf;
implement(actNo+2) = Inf;
for j=mandatory
    implement(j)=1;
end
[r,c]=size(choice);
% 确定可选和依赖活动
choice_depend=depend(:,1);
for j=1:r
    if implement(choice(j,1))==1
        prio_value = trial_implement(choice(j,2:end));
            [~,index]=max(prio_value);     
            temp_act=choice(j,index+1);
            implement(temp_act)=1;
        if any(temp_act==choice_depend)==1
            index=find(choice_depend==temp_act);
           for d=depend(index,2:end)     % 更新依赖活动
                implement(d)=1;
           end 
        end
    end
end
if projectFeasible(implement,choice,depend)==0
    disp('不可行')
end