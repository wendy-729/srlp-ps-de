function [ est, eft ] = forwardPass( projRelation, duration ,implement)
act=length(duration);
est = zeros(act,1);
eft = zeros(act,1);
% ���� ��һ����Ľ�����est eft
for i=2:projRelation(1,1)+1
    eft(projRelation(1,i))=est(i)+duration(projRelation(1,i));
end
for i=2:act-1
    if implement(i)==1 % ����ʵʩ
        for j=2:projRelation(i,1)+1  % ��Ľ���
            if implement(projRelation(i,j))==1
                if eft(i)>est(projRelation(i,j))
                    est(projRelation(i,j))=eft(i);
                    eft(projRelation(i,j))=est(projRelation(i,j))+duration(projRelation(i,j));
                end
            end
        end
    end
end
        
    