% 优先值最大先放还是优先值最小先放
function al = transmute_al(new_implement,nrpr_i,pred_i,actNo,trial_al)
al = zeros(1,actNo);
al(1)=1;
al(actNo)=actNo;

no_index=find(new_implement(1:actNo)==0);
len=length(no_index);
% 随机生成len个位置
loc_index=randperm(actNo-2,len)+1;
% 位置排序
%     loc_index=sort(loc_index);
% 将未执行的活动放在随机生成的位置上
al(loc_index)=no_index;
inList=[1 actNo];
inList=[inList no_index];
for i=2:actNo-1
    if al(i)==0           
        % 计算合格活动【考不考虑活动是否执行】
        eligSet=feasibleact(inList,nrpr_i,pred_i,actNo);
        % 如果只有一个合格活动
        if length(eligSet)==1
            al(i)=eligSet;
            inList=[inList eligSet];
        else
%             disp(eligSet)
            prio_value = trial_al(eligSet);
%             disp(prio_value)
            % 优先值最大的先放在AL上
            [~,index]=max(prio_value);
            e= eligSet(index);
            al(i)=e;
            inList = [inList e];
        end
    end
end