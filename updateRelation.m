function [proj,nr_pr,nr_su,s,pr]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,implementList,actNo)
proj=projRelation;
nr_pr=nrpr;
nr_su=nrsu;
s=su;
pr=pred;
for i=choiceList
    if implementList(i)==0
        for j=1:nr_pr(i)
            jinqian=pr(i,j);
% �����ʵʩ�Ļ�Ľ�ǰ��Ľ���ֻ��1������ô���������actNo
            if nr_su(jinqian)==1
                proj(jinqian,proj(jinqian,1)+2)=actNo;
                proj(jinqian,1)=proj(jinqian,1)+1;
                nr_su(jinqian)=nr_su(jinqian)+1;
                s(jinqian,nr_su(jinqian))=actNo;
                nr_pr(actNo)=nr_pr(actNo)+1;
                pr(actNo,nr_pr(actNo))=jinqian;
            end 
        end
    end
end
%  ���ǽ���
for i=choiceList
    if implementList(i)==0
        for j=1:nr_su(i)
            jinhou=s(i,j);
            if nr_pr(jinhou)==1
                proj(1,proj(1,1)+2)=jinhou;
                proj(1,1)=proj(1,1)+1;
                nr_su(1)=nr_su(1)+1;
                s(1,nr_su(1))=jinhou;
                nr_pr(jinhou)=nr_pr(jinhou)+1;
                pr(jinhou,nr_pr(jinhou))=1;
            end                        
        end
    end
end

% ���һ��������н�������ʵʩ
% ������������⣬�����ʱ�����Ϊ1�Ļ�
al=find(implementList==1);
al_length=length(al);
al(al_length)=[];
for i=al
    count=0;
    for j=1:nr_su(i)
        ss=s(i,j);
        if implementList(ss)==0
            count=count+1;
        end
    end
%     ss=s(i,1:nr_su(i));
%     ip = implementList(ss);
    if count==nr_su(i)
        proj(i,proj(i,1)+2)=actNo;
        proj(i,1)=proj(i,1)+1;
        nr_su(i)=nr_su(i)+1;
        s(i,nr_su(i))=actNo;
        nr_pr(actNo)=nr_pr(actNo)+1;
        pr(actNo,nr_pr(actNo))=i;
    end
end
%% һ��ʵʩ����н�ǰ����ʵʩ
% ���һ��������н�������ʵʩ��
al(1)=[];
for i=al
    count=0;
    for j=1:nr_pr(i)
        p=pr(i,j);
        if implementList(p)==0
            count=count+1;
        end
    end
    if count==nr_pr(i)
        proj(1,proj(1,1)+2)=i;
        proj(1,1)=proj(1,1)+1;
        nr_su(1)=nr_su(1)+1;
        s(1,nr_su(1))=i;
        nr_pr(i)=nr_pr(i)+1;
        pr(i,nr_pr(i))=1;
    end
end
