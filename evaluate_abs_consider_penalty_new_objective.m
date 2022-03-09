% 计算到截止日期,完全不考虑项目的完成概率
% 20220228
% 计算到项目实际的完成时间
% 目标函数带惩罚
% 仿真
function expected_obj=evaluate_abs_consider_penalty_new_objective(AL,rep,implement,req,resNumber,nrpr,pred,nrsu,su,deadline,resNo,actNo,stochatic_d,C)

% 总的目标函数值
obj=0;
% 随机工期数据
index=1:rep;
duration_data=stochatic_d(index,:);
% 计算每个工期下的目标函数值
for i=1:rep
    d=duration_data(i,:);
    % 原来的解码，满足优先关系和资源使用可行
    [schedule, u_kt] = SSGS(AL,implement,req,resNumber,d,nrpr,pred,deadline,resNo);
%     disp(schedule)
    u_kt = u_kt(:,1:schedule(actNo));
%     u_kt=u_kt(:,1:deadline);
%     disp(u_kt)
    
    % 判断进度计划是否可行(优先关系）、资源可行
    if scheduleFeasible(schedule,actNo,nrsu,su,implement,d)==1 && resourceFeasible(u_kt,resNumber)==1 
        % 情景下的目标函数
        scen_obj = 0;
        
        for k=1:resNo
            temp_obj = 0;
            % 实际的完成时间
            for t = 1:schedule(actNo)-1
%             for t=1:deadline-1
                if u_kt(k,t+1)-u_kt(k,t)<0
                    temp = u_kt(k,t)-u_kt(k,t+1);
                else
                    temp = u_kt(k,t+1)-u_kt(k,t);
                end
                temp_obj = temp_obj +temp;
            end
            scen_obj = scen_obj+temp_obj;
        end  
%         disp(scen_obj)
        % 如果超过截止日期加惩罚
        if schedule(actNo)>deadline
            scen_obj = scen_obj+C*(schedule(actNo)-deadline);
        end
        
        obj = obj+scen_obj;
        
    else
        if scheduleFeasible1(schedule,actNo,nrsu,su,implement,d)==0
            disp('进度计划不可行')
        end
        if resourceFeasible(u_kt,resNumber)==0
            disp('资源不可行')
        end
    end
end %  情景数
expected_obj=obj/rep;
                