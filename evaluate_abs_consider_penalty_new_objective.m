% ���㵽��ֹ����,��ȫ��������Ŀ����ɸ���
% 20220228
% ���㵽��Ŀʵ�ʵ����ʱ��
% Ŀ�꺯�����ͷ�
% ����
function expected_obj=evaluate_abs_consider_penalty_new_objective(AL,rep,implement,req,resNumber,nrpr,pred,nrsu,su,deadline,resNo,actNo,stochatic_d,C)

% �ܵ�Ŀ�꺯��ֵ
obj=0;
% �����������
index=1:rep;
duration_data=stochatic_d(index,:);
% ����ÿ�������µ�Ŀ�꺯��ֵ
for i=1:rep
    d=duration_data(i,:);
    % ԭ���Ľ��룬�������ȹ�ϵ����Դʹ�ÿ���
    [schedule, u_kt] = SSGS(AL,implement,req,resNumber,d,nrpr,pred,deadline,resNo);
%     disp(schedule)
    u_kt = u_kt(:,1:schedule(actNo));
%     u_kt=u_kt(:,1:deadline);
%     disp(u_kt)
    
    % �жϽ��ȼƻ��Ƿ����(���ȹ�ϵ������Դ����
    if scheduleFeasible(schedule,actNo,nrsu,su,implement,d)==1 && resourceFeasible(u_kt,resNumber)==1 
        % �龰�µ�Ŀ�꺯��
        scen_obj = 0;
        
        for k=1:resNo
            temp_obj = 0;
            % ʵ�ʵ����ʱ��
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
        % ���������ֹ���ڼӳͷ�
        if schedule(actNo)>deadline
            scen_obj = scen_obj+C*(schedule(actNo)-deadline);
        end
        
        obj = obj+scen_obj;
        
    else
        if scheduleFeasible1(schedule,actNo,nrsu,su,implement,d)==0
            disp('���ȼƻ�������')
        end
        if resourceFeasible(u_kt,resNumber)==0
            disp('��Դ������')
        end
    end
end %  �龰��
expected_obj=obj/rep;
                