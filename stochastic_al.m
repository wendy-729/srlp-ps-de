function AL = stochastic_al(projRelation,nrpr,nrsu,su,pred,choiceList,implement,actNo)
AL = zeros(1,actNo);
AL(1)=1;
AL(actNo)=actNo;
[projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,implement,actNo);
% 没有执行的活动
no_index=find(implement(1:actNo)==0);
len=length(no_index);
% 随机生成len个位置
loc_index=randperm(actNo-2,len)+1;

% 将未执行的活动放在随机生成的位置上
AL(loc_index)=no_index;
% 已经放在活动列表中的活动
inList=[1 actNo];
inList=[inList no_index];
%   生成活动列表
for j=2:actNo-1
    % 如果该位置上没有放置活动
    if AL(j)==0
        % 合格活动【不包含未执行活动】
        eligSet=feasibleact(inList,nrpr_i,pred_i,actNo);
%                 eligSet=feasibleact_rsa(inList,nrpr_i,pred_i,actNo);
        % 随机选择一个合格活动
        index = randi([1,length(eligSet)],1);
        AL(j)=eligSet(index);
        inList = [inList eligSet(index)];
    end
end
