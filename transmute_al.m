% ����ֵ����ȷŻ�������ֵ��С�ȷ�
function al = transmute_al(new_implement,nrpr_i,pred_i,actNo,trial_al)
al = zeros(1,actNo);
al(1)=1;
al(actNo)=actNo;

no_index=find(new_implement(1:actNo)==0);
len=length(no_index);
% �������len��λ��
loc_index=randperm(actNo-2,len)+1;
% λ������
%     loc_index=sort(loc_index);
% ��δִ�еĻ����������ɵ�λ����
al(loc_index)=no_index;
inList=[1 actNo];
inList=[inList no_index];
for i=2:actNo-1
    if al(i)==0           
        % ����ϸ����������ǻ�Ƿ�ִ�С�
        eligSet=feasibleact(inList,nrpr_i,pred_i,actNo);
        % ���ֻ��һ���ϸ�
        if length(eligSet)==1
            al(i)=eligSet;
            inList=[inList eligSet];
        else
%             disp(eligSet)
            prio_value = trial_al(eligSet);
%             disp(prio_value)
            % ����ֵ�����ȷ���AL��
            [~,index]=max(prio_value);
            e= eligSet(index);
            al(i)=e;
            inList = [inList e];
        end
    end
end