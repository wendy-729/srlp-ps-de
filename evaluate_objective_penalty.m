% ���㵽��ֹ����,��ȫ��������Ŀ����ɸ���
% ƽ�����ڣ�������
function obj=evaluate_objective_penalty(AL,rep,implement,req,resNumber,nrpr,pred,nrsu,su,deadline,resNo,actNo,C,duration)
% �ܵ�Ŀ�꺯��ֵ
obj=0;
% ƽ������
[schedule, u_kt] = stochastic_SSGS(AL,implement,req,resNumber,duration,nrpr,pred,deadline,resNo);
u_kt1=u_kt(:,1:deadline);   
% �жϽ��ȼƻ��Ƿ���С���Դ����
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
    % ���������ֹ����
    if schedule(actNo)>deadline
        obj = obj+C*(schedule(actNo)-deadline);
    end 
else
    if scheduleFeasible1(schedule,actNo,nrsu,su,implement,duration)==0
        disp('���ȼƻ�������')
    end
    if resourceFeasible(u_kt1,resNumber)==0
        disp('��Դ������')
    end
end


