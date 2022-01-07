function elig=feasibleact(al,nrpr,pred,actNo)
% al是已经在活动列表中的活动(包括未执行活动)
elig=[];
actSet=1:actNo;
same=ismember(actSet,al);
% 未调度的活动
unschedule=actSet(~same);
for i=1:length(unschedule)
    act=unschedule(i);
    % 判断紧前是否都已经调度【考虑紧前是否执行，因为已经将不执行活动放在AL中，所以不考虑没有影响】
    flag=1;
    for j=1:nrpr(act)
        p=pred(act,j);
        if any(p==al)==0
            flag=0;
            break
        end
    end
    if flag==1
        elig(end+1)=act;
%         elig=[elig act];
    end
end
            
        
        