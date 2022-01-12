% 编码执行SSGS或PSGS
% 刚开始只满足优先关系
% 安排活动的开始时间有两种方式：第一种类似SSGS，第二种类似并行，考虑了其他可能的开始时间，类似于将活动往后推
function [schedule, u_kt] = SSGS_PSGS1(al,implement,req,resNumber,duration,nrpr,pred,deadline,resNo,actNo,code)
% code = ones(1,actNo);
schedule=zeros(1,actNo);
% 有的进度进化可能超过了截止日期，所以就扩大了deadline
u_kt=zeros(resNo,ceil(20*deadline));
% 正在调度的活动
actSet = zeros(1,ceil(actNo/2));
actValue = Inf(1,ceil(actNo/2));
count = 1;
actSet(count) = 1;
actValue(count) = 0;
for i=2:length(al)-1
    act=al(i);
    if implement(act)==1
       % 根据紧前活动确定活动可能的开始时间
       max_end = -Inf;       
       for p=1:nrpr(act)
           jq=pred(act,p);
           if implement(jq)==1
               % 紧前活动的完成时间
               if schedule(jq)+duration(jq)>max_end
                   max_end=schedule(jq)+duration(jq);
               end
           end
       end
       % ss是可能的开始时间【满足优先关系】
       ss = max_end;  
       % 串行进度机制解码
       if code(act) == 1  
            % 判断资源够不够用
           conflict=1;
           while conflict==1
               conflict=0;
               for k=1:resNo 
                   for t=(ss+1):(ss+duration(act))
                       if req(act,k)+u_kt(k,t)>resNumber(k)
                           conflict=1;
                           break;
                       end
                   end
               end
               % 资源不满足
               if conflict==1
                   ss=ss+1;
               end
           end 
           schedule(act)=ss;
           end_s = schedule(act)+duration(act);
           
           count = count+1;
           actSet(count) = act;
           actValue(count) = end_s;
           % 更新资源的使用量
           for k=1:resNo
               for tt=(schedule(act)+1):end_s
                   u_kt(k,tt)=u_kt(k,tt)+req(act,k);
               end
           end
       else
            % 类似于并行进度生成机制
            % 当前时间【上一阶段正在执行活动的最小完成时间,且大于该活动可能的开始时间（紧前活动的完成时间）】
            current_t = Inf;
            actValue = sort(actValue);
%             disp(actValue)
            for v = actValue
%                 disp(v)
                if v>ss
                    current_t = v;
                    break
                end
            end
%             disp(current_t)
           % 判断是否满足资源约束
           conflict=1;
           while conflict==1
               conflict=0;
               for k=1:resNo                       
                   for t=(current_t+1):(current_t+duration(act))
                       if req(act,k)+u_kt(k,t)>resNumber(k)
                           conflict=1;
                           break;
                       end
                   end
               end
               % 资源不满足
               if conflict==1
                   current_t=current_t+1;
               end
           end
            % 更新正在调度的活动集合，将已经完成的活动从正在调度的活动集合中移除
            index = actValue>current_t;
            actSet = actSet(index);
            actValue = actValue(index);
            index_1 = actValue<Inf;
            count = sum(index_1);
            
            schedule(act)=current_t;
            end_s = schedule(act)+duration(act);
            count = count+1;
            actSet(count) = act;
            actValue(count) = end_s;
            % 更新资源
            for k=1:resNo
               for tt=(schedule(act)+1):end_s
                   u_kt(k,tt)=u_kt(k,tt)+req(act,k);
               end
           end
        end
    else
        % 如果活动不执行那么其开始时间为INF
        schedule(act)=Inf;
    end
end
% 计算虚终止活动的开始时间
schedule(actNo)=-Inf;
for i=1:nrpr(actNo)
    % 紧前活动
    pr = pred(actNo,i);
    if implement(pr)==1
        tt = schedule(pr)+duration(pr);
        if schedule(actNo)<tt
            % 取最大
            schedule(actNo)=tt;
        end
    end
end
end % 函数结束