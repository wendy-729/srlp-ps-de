% ���㵽��ֹ����,��ȫ��������Ŀ����ɸ���
function [expected_obj,time_pro,gap]=evaluate_abs_nopenalty_code(AL,rep,implement,req,resNumber,nrpr,pred,nrsu,su,deadline,resNo,actNo,stochatic_d,code)
gap = [];
% �����ֹ���ڵĴ���
p=0;
% �ܵ�Ŀ�꺯��ֵ
obj=0;
% �����������
index=1:rep;
duration_data=stochatic_d(index,:);
% ����ÿ�������µ�Ŀ�꺯��ֵ
for i=1:rep
    d=duration_data(i,:);
%  �������ɽ��ȼƻ�
    [schedule, u_kt] = SSGS_PSGS1(AL,implement,req,resNumber,d,nrpr,pred,deadline,resNo,actNo,code);  
    % ԭ���Ľ���
%     [schedule, u_kt] = stochastic_SSGS(AL,implement,req,resNumber,d,nrpr,pred,deadline,resNo);
    u_kt1=u_kt(:,1:schedule(actNo));
    % �жϽ��ȼƻ��Ƿ���С���Դ����
    if scheduleFeasible(schedule,actNo,nrsu,su,implement,d)==1 && resourceFeasible(u_kt1,resNumber)==1 
        if schedule(actNo)<=deadline
            % ͳ�Ƽ�ʱ��ɵĴ���
            p=p+1;
        else
            gap_d = schedule(actNo)-deadline;
            gap = [gap gap_d];
        end
        for k=1:resNo
            for t=2:schedule(actNo)+1
               
                if u_kt(k,t)-u_kt(k,t-1)<0
                    temp = u_kt(k,t-1)-u_kt(k,t);
                else
                    temp = u_kt(k,t)-u_kt(k,t-1);
                end
                obj=obj+temp;
            end
            obj = obj+u_kt(k,1);
        end % ��Դ����
    end
end %  �龰��

expected_obj=obj/rep;
time_pro=p/rep;

                