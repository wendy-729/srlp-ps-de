function AL = stochastic_al(projRelation,nrpr,nrsu,su,pred,choiceList,implement,actNo)
AL = zeros(1,actNo);
AL(1)=1;
AL(actNo)=actNo;
[projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,implement,actNo);
% û��ִ�еĻ
no_index=find(implement(1:actNo)==0);
len=length(no_index);
% �������len��λ��
loc_index=randperm(actNo-2,len)+1;

% ��δִ�еĻ����������ɵ�λ����
AL(loc_index)=no_index;
% �Ѿ����ڻ�б��еĻ
inList=[1 actNo];
inList=[inList no_index];
%   ���ɻ�б�
for j=2:actNo-1
    % �����λ����û�з��û
    if AL(j)==0
        % �ϸ���������δִ�л��
        eligSet=feasibleact(inList,nrpr_i,pred_i,actNo);
%                 eligSet=feasibleact_rsa(inList,nrpr_i,pred_i,actNo);
        % ���ѡ��һ���ϸ�
        index = randi([1,length(eligSet)],1);
        AL(j)=eligSet(index);
        inList = [inList eligSet(index)];
    end
end
