% 计算到截止日期,完全不考虑项目的完成概率
% 平均工期，不仿真
function obj=evaluate_objective_penalty(AL,rep,implement,req,resNumber,nrpr,pred,nrsu,su,deadline,resNo,actNo,C,duration)
% 总的目标函数值
obj=0;
% 平均工期
[schedule, u_kt] = stochastic_SSGS(AL,implement,req,resNumber,duration,nrpr,pred,deadline,resNo);
u_kt1=u_kt(:,1:deadline);   
% 判断进度计划是否可行、资源可行
if scheduleFeasible(schedule,actNo,nrsu,su,implement,duration)==1 && resourceFeasible(u_kt1,resNumber)==1 
    for k=1:resNo
        for t=1:deadline-1
            if u_kt(k,t+1)-u_kt(k,t)<0
                temp = u_kt(k,t)-u_kt(k,t+1);
            else
                temp = u_kt(k,t+1)-u_kt(k,t);
            end
            obj=obj+temp;
        end                
    end  
    % 如果超过截止日期
    if schedule(actNo)>deadline
        obj = obj+C*(schedule(actNo)-deadline);
    end 
else
    if scheduleFeasible1(schedule,actNo,nrsu,su,implement,duration)==0
        disp('进度计划不可行')
    end
    if resourceFeasible(u_kt1,resNumber)==0
        disp('资源不可行')
    end
end


