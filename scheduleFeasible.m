function[feasible]=scheduleFeasible(schedule,act,nrsu,su,implement,duration)
% �ж����ɵĽ��ȼƻ��Ƿ����
feasible=0;
f=zeros(1,act);
implement = implement(1:act);
% len=length(implement(logical(implement==1)));
% len=length(find(implement==1));
len = sum(implement);
for i=1:act-1
    if implement(i)==1
        min_pr=-Inf;
       % �i�Ľ���
        for j=1:nrsu(i)
            if implement(su(i,j))==1
                min_pr=schedule(su(i,j));
                break
            end
        end
        % ��������С��ʼʱ��
        for j=1:nrsu(i)
            if implement(su(i,j))==1
                 min_pr=min(schedule(su(i,j)),min_pr);
            end
        end
        % �i�����ʱ��<=�i�Ľ����Ŀ�ʼʱ��
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

    