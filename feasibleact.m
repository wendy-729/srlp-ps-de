function elig=feasibleact(al,nrpr,pred,actNo)
% al���Ѿ��ڻ�б��еĻ(����δִ�л)
elig=[];
actSet=1:actNo;
same=ismember(actSet,al);
% δ���ȵĻ
unschedule=actSet(~same);
for i=1:length(unschedule)
    act=unschedule(i);
    % �жϽ�ǰ�Ƿ��Ѿ����ȡ����ǽ�ǰ�Ƿ�ִ�У���Ϊ�Ѿ�����ִ�л����AL�У����Բ�����û��Ӱ�졿
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
            
        
        