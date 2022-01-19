% 计算到截止日期,完全不考虑项目的完成概率
% 超过截止日期也计算资源波动
% 惩罚，最大的偏差*gap_d
% 不考虑超过了deadline的多少日期
function [expected_obj,time_pro]=evaluate_abs_consider_penalty(AL,rep,implement,req,resNumber,nrpr,pred,nrsu,su,deadline,resNo,actNo,stochatic_d,code)
% 满足截止日期的次数
p=0;
% 总的目标函数值
obj=0;
% 随机工期数据
index=1:rep;
duration_data=stochatic_d(index,:);
% 计算每个工期下的目标函数值
for i=1:rep
    d=duration_data(i,:);
    %  解码生成进度计划
    [schedule, u_kt] = SSGS_PSGS1(AL,implement,req,resNumber,d,nrpr,pred,deadline,resNo,actNo,code);
    % 原来的解码
%     [schedule, u_kt] = stochastic_SSGS(AL,implement,req,resNumber,d,nrpr,pred,deadline,resNo);
    u_kt1=u_kt(:,1:schedule(actNo));
    % 标记是否超过deadline
    flag = 0;
    % 判断进度计划是否可行、资源可行
    if scheduleFeasible(schedule,actNo,nrsu,su,implement,d)==1 && resourceFeasible(u_kt1,resNumber)==1 
        if schedule(actNo)<=deadline
            % 统计及时完成的次数
            p=p+1;
        else
            flag = 1;
        end
        % 情景下的目标函数
        scen_obj = 0;
        % 进度计划没有超过deadline，计算目标函数值
        if flag ==0
            for k=1:resNo
                for t=2:schedule(actNo)+1
                    if u_kt(k,t)-u_kt(k,t-1)<0
                        temp = u_kt(k,t-1)-u_kt(k,t);
                    else
                        temp = u_kt(k,t)-u_kt(k,t-1);
                    end
                    scen_obj=scen_obj+temp;
                end                
                scen_obj = scen_obj+u_kt(k,1);
            end  
        else
            % 超过deadline，考虑惩罚    
            for k=1:resNo
                max_abs = 0;
                for t=2:schedule(actNo)+1
                    if u_kt(k,t)-u_kt(k,t-1)<0
                        temp = u_kt(k,t-1)-u_kt(k,t);
                        if temp>max_abs
                            max_abs = temp;
                        end
                    else
                        temp = u_kt(k,t)-u_kt(k,t-1);
                        if temp>max_abs
                            max_abs = temp;
                        end
                    end
                    scen_obj=scen_obj+temp;
                end
                 % 加惩罚
                penalty_k = max_abs*((schedule(actNo)-deadline));
                scen_obj = scen_obj+u_kt(k,1)+penalty_k;
            end % 资源类型
        end
        obj = obj+scen_obj;
    else
        if scheduleFeasible1(schedule,actNo,nrsu,su,implement,d)==0
            disp('进度计划不可行')
        end
        if resourceFeasible(u_kt1,resNumber)==0
            disp('资源不可行')
        end
    end
end %  情景数
expected_obj=obj/rep;
time_pro=p/rep;
                