% ����ִ��SSGS��PSGS
% �տ�ʼֻ�������ȹ�ϵ
% ���Ż�Ŀ�ʼʱ�������ַ�ʽ����һ������SSGS���ڶ������Ʋ��У��������������ܵĿ�ʼʱ�䣬�����ڽ��������
function [schedule, u_kt] = SSGS_PSGS1(al,implement,req,resNumber,duration,nrpr,pred,deadline,resNo,actNo,code)
% code = ones(1,actNo);
schedule=zeros(1,actNo);
% �еĽ��Ƚ������ܳ����˽�ֹ���ڣ����Ծ�������deadline
u_kt=zeros(resNo,ceil(20*deadline));
% ���ڵ��ȵĻ
actSet = zeros(1,ceil(actNo/2));
actValue = Inf(1,ceil(actNo/2));
count = 1;
actSet(count) = 1;
actValue(count) = 0;
for i=2:length(al)-1
    act=al(i);
    if implement(act)==1
       % ���ݽ�ǰ�ȷ������ܵĿ�ʼʱ��
       max_end = -Inf;       
       for p=1:nrpr(act)
           jq=pred(act,p);
           if implement(jq)==1
               % ��ǰ������ʱ��
               if schedule(jq)+duration(jq)>max_end
                   max_end=schedule(jq)+duration(jq);
               end
           end
       end
       % ss�ǿ��ܵĿ�ʼʱ�䡾�������ȹ�ϵ��
       ss = max_end;  
       % ���н��Ȼ��ƽ���
       if code(act) == 1  
            % �ж���Դ��������
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
               % ��Դ������
               if conflict==1
                   ss=ss+1;
               end
           end 
           schedule(act)=ss;
           end_s = schedule(act)+duration(act);
           
           count = count+1;
           actSet(count) = act;
           actValue(count) = end_s;
           % ������Դ��ʹ����
           for k=1:resNo
               for tt=(schedule(act)+1):end_s
                   u_kt(k,tt)=u_kt(k,tt)+req(act,k);
               end
           end
       else
            % �����ڲ��н������ɻ���
            % ��ǰʱ�䡾��һ�׶�����ִ�л����С���ʱ��,�Ҵ��ڸû���ܵĿ�ʼʱ�䣨��ǰ������ʱ�䣩��
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
           % �ж��Ƿ�������ԴԼ��
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
               % ��Դ������
               if conflict==1
                   current_t=current_t+1;
               end
           end
            % �������ڵ��ȵĻ���ϣ����Ѿ���ɵĻ�����ڵ��ȵĻ�������Ƴ�
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
            % ������Դ
            for k=1:resNo
               for tt=(schedule(act)+1):end_s
                   u_kt(k,tt)=u_kt(k,tt)+req(act,k);
               end
           end
        end
    else
        % ������ִ����ô�俪ʼʱ��ΪINF
        schedule(act)=Inf;
    end
end
% ��������ֹ��Ŀ�ʼʱ��
schedule(actNo)=-Inf;
for i=1:nrpr(actNo)
    % ��ǰ�
    pr = pred(actNo,i);
    if implement(pr)==1
        tt = schedule(pr)+duration(pr);
        if schedule(actNo)<tt
            % ȡ���
            schedule(actNo)=tt;
        end
    end
end
end % ��������