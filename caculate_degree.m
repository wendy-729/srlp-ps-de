% ����ƽ���������龰���µ����ȹ�ϵ���ʺ���ԴԼ���ĸ��ʣ����Ŷȣ�
% �����ǿ��ǲ����г̶ȣ�Ȩ�����ߣ�ѡ��С��
function degree=caculate_degree(schedule,implement,req,resNumber,nrpr,pred,nrsu,su,deadline,resNo,actNo,stochatic_d,C)
for i=2:actNo
    if implement(i)==1
        % ��ǰ
        for j=1:nrpr
            jinqian = pred(i,j);
            