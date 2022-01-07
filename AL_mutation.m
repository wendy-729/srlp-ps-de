function local_al=AL_mutation(al,vl,nrsu,su,actNo,p_mutation)
% 交换两个没有优先关系的两个执行活动
local_al=al;
% 依次交换AL中的活动
for i=2:actNo-2
    pos1=i;
    w1=local_al(i);
    % 如果活动执行
    if vl(w1)==1
        if rand<=p_mutation
            % 找到下一个执行的活动
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
            % 判断有无优先关系
            su_b=su(w1,1:nrsu(w1));
            % 如果没有优先关系则交换两个活动的位置
            if any(w2==su_b)==0&& w2~=actNo
                local_al(pos1)=w2; 
                local_al(pos2)=w1;
            end
        end
    end
end
        
            
    

