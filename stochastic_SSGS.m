% �������SSGS
function [schedule,u_kt]=stochastic_SSGS(al,implement,req,resNumber,duration,nrpr,pred,deadline,resNo)
actNo=length(duration);
schedule=zeros(1,actNo);
% �еĽ��Ƚ������ܳ����˽�ֹ���ڣ����Ծ�������deadline
u_kt=zeros(resNo,ceil(20*deadline));
current=0;
for i=2:length(al)
    act=al(i);
    if implement(act)==1
%        s=schedule(act);
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
       ss = max(max_end,current);
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
       current = ss;
       schedule(act)=ss;
%        current=ss;
       % ������Դ��ʹ����
       for k=1:resNo
           for tt=(schedule(act)+1):schedule(act)+duration(act)
               u_kt(k,tt)=u_kt(k,tt)+req(act,k);
           end
       end
    else
        % ������ִ����ô�俪ʼʱ��ΪINF
        schedule(act)=Inf;
    end
end
% ��������ֹ��Ŀ�ʼʱ��
% for i=1:
% schedule(actNo)=schedule(pred(actNo,1))+duration(pred(actNo,1));
% for i=1:nrpr(actNo)
%     if implement(pred(actNo,i))==1
%         if schedule(actNo)<schedule(pred(actNo,i))+duration(pred(actNo,i))
%             % ȡ���
%             schedule(actNo)=schedule(pred(actNo,i))+duration(pred(actNo,i));
%         end
%     end
% end
    
