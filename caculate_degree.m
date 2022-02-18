% 考察平均工期在情景数下的优先关系概率和资源约束的概率（置信度）
% 或者是考虑不可行程度，权衡两者，选择小的
function degree=caculate_degree(schedule,implement,req,resNumber,nrpr,pred,nrsu,su,deadline,resNo,actNo,stochatic_d,C)
for i=2:actNo
    if implement(i)==1
        % 紧前
        for j=1:nrpr
            jinqian = pred(i,j);
            