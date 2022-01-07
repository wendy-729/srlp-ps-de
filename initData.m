function [projRelation,actNo,resNo,resNumber,duration,nrsu,nrpr,pred,su,req] = initData(filename)
% dlmread(filename)�� ASCII �ָ�����ֵ�����ļ���ȡ������ M
projNetwork=dlmread(filename);
% �����
actNo=projNetwork(1,1);
% ��Դ����
resNo=projNetwork(1,2);
% ��Դ�Ĺ�Ӧ��
resNumber = projNetwork(2,1:resNo);
% ��Դ������
req=projNetwork(3:end,2:1+resNo);
% ����
duration = projNetwork(3:end,1);
% �����������ͱ��
projRelation = projNetwork(3:end,resNo+2:end);
%������������ nrsu
nrsu = projRelation(:,1);
% �����ı��
su = projRelation(:,2:end);
% ��ǰ�����
nrpr = zeros(actNo,1);
max_nrpr = 0;
for i = 1:actNo
    for j = 1:nrsu(i)
%         disp(su(i,j))
        nrpr(su(i,j)) = nrpr(su(i,j))+1;
        if max_nrpr < nrpr(su(i,j))
            max_nrpr = nrpr(su(i,j));
        end
    end
end
%��ǰ�����pred
pred = zeros(actNo,max_nrpr);
counter = zeros(actNo,1);
for i=1:actNo
    for j=1:nrsu(i)
        counter(su(i,j))=counter(su(i,j))+1;
        pred(su(i,j),counter(su(i,j)))=i;
    end
end