function [ est, eft ] = forward( projRelation, duration )

activities=length(duration); %�����
est=zeros(activities,1);
eft=zeros(activities,1);
%���� ��һ����Ľ�����est eft
for i1=2:projRelation(1,1)+1
    eft(projRelation(1,i1))=est(i1)+duration(projRelation(1,i1));
end

for i=2:activities-1 %�ӵڶ������ʼ����i���
    for j=2:projRelation(i,1)+1 %ÿ����Ľ���
        if eft(i)>est(projRelation(i,j))
            est(projRelation(i,j))=eft(i);
            eft(projRelation(i,j))=est(projRelation(i,j))+duration(projRelation(i,j));
        end
    end
end


end

