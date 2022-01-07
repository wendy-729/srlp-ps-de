% 不是随机SSGS
function [schedule,u_kt]=stochastic_SSGS(al,implement,req,resNumber,duration,nrpr,pred,deadline,resNo)
actNo=length(duration);
schedule=zeros(1,actNo);
% 有的进度进化可能超过了截止日期，所以就扩大了deadline
u_kt=zeros(resNo,ceil(20*deadline));
current=0;
for i=2:length(al)
    act=al(i);
    if implement(act)==1
%        s=schedule(act);
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
       ss = max(max_end,current);
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
       current = ss;
       schedule(act)=ss;
%        current=ss;
       % 更新资源的使用量
       for k=1:resNo
           for tt=(schedule(act)+1):schedule(act)+duration(act)
               u_kt(k,tt)=u_kt(k,tt)+req(act,k);
           end
       end
    else
        % 如果活动不执行那么其开始时间为INF
        schedule(act)=Inf;
    end
end
% 计算虚终止活动的开始时间
% for i=1:
% schedule(actNo)=schedule(pred(actNo,1))+duration(pred(actNo,1));
% for i=1:nrpr(actNo)
%     if implement(pred(actNo,i))==1
%         if schedule(actNo)<schedule(pred(actNo,i))+duration(pred(actNo,i))
%             % 取最大
%             schedule(actNo)=schedule(pred(actNo,i))+duration(pred(actNo,i));
%         end
%     end
% end
    
