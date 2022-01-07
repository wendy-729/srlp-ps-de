function[feasible]=scheduleFeasible(schedule,act,nrsu,su,implement,duration)
% 判断生成的进度计划是否可行
feasible=0;
f=zeros(1,act);
implement = implement(1:act);
% len=length(implement(logical(implement==1)));
% len=length(find(implement==1));
len = sum(implement);
for i=1:act-1
    if implement(i)==1
        min_pr=-Inf;
       % 活动i的紧后活动
        for j=1:nrsu(i)
            if implement(su(i,j))==1
                min_pr=schedule(su(i,j));
                break
            end
        end
        % 紧后活动的最小开始时间
        for j=1:nrsu(i)
            if implement(su(i,j))==1
                 min_pr=min(schedule(su(i,j)),min_pr);
            end
        end
        % 活动i的完成时间<=活动i的紧后活动的开始时间
        if schedule(i)+duration(i)<=min_pr  
            f(i)=1;
        end
    end
end
f(act) = 1;
if sum(f)==len
    feasible=1;
else
    disp(f)
end

    