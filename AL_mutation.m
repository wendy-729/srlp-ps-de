function local_al=AL_mutation(al,vl,nrsu,su,actNo,p_mutation)
% ��������û�����ȹ�ϵ������ִ�л
local_al=al;
% ���ν���AL�еĻ
for i=2:actNo-2
    pos1=i;
    w1=local_al(i);
    % ����ִ��
    if vl(w1)==1
        if rand<=p_mutation
            % �ҵ���һ��ִ�еĻ
            w2=local_al(i+1);
            pos2=i+1;
            while vl(w2)==0
                for j=i+2:actNo
                    w2=local_al(j); 
                    if vl(w2)==1
                        pos2=j;
                        break
                    end
                end
            end
            % �ж��������ȹ�ϵ
            su_b=su(w1,1:nrsu(w1));
            % ���û�����ȹ�ϵ�򽻻��������λ��
            if any(w2==su_b)==0&& w2~=actNo
                local_al(pos1)=w2; 
                local_al(pos2)=w1;
            end
        end
    end
end
        
            
    

