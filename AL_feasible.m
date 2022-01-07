function feasible=AL_feasible(implement,al,nrpr,pred,actNo)
sum_feasible=0;
feasible=0;
len=length(find(implement(1:actNo)==1));
for ii=2:length(al)
    act=al(ii);
    if implement(act)==1
        flag=1;
        % 紧前活动
        for j=1:nrpr(act)
            jinqian=pred(act,j);
            if implement(jinqian)==1
                % 活动列表中该活动的之前的活动
                partial_AL=al(1:ii-1);
                % 紧前活动在其紧后活动之前
                if any(partial_AL==jinqian)==0
                    flag=0;
                end
            end
            if flag==0
        %       disp('不满足')
                break;
            end
        end
        if flag==1
            sum_feasible=sum_feasible+1;
        end
    end
end
if sum_feasible==len-1
    feasible=1;
end