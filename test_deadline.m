% ֻ��DE
% ����AL-PR-AL
% ��gap������100�Σ��õ���gap�����ھ�ȷ�㷨����
% �ӽ��뷽ʽ
% ���˽���ķ�ʽ
% ִ���б�ת��Ϊ��������
% ����˴洢
% �ı��˽�ֹ���ڵļ���ʱ��


clc
clear
% profile on 
global rn_seed; % ���������
rn_seed = 13776;
% EDA��������
para=[100,0.1,0.3,100];
% ��Ⱥ��С
popsize=para(1);
% �ֲ������ĸ�����
elit_p=popsize*para(2);
% AL�ֲ������ĸ���
p_mutation=para(3);
% �龰�ĸ���
rep=para(4);
% ��ʱ��ɵĸ���
Pr=0.9;
count_lftn = 0;
% �����
for actN=[30]
actNumber=num2str(actN);
%�ֲ�����
distribution=cell(1,1);
distribution{1,1}='U1';
for disT=distribution
disT=char(disT);
% ������һ������ J10�ǵ���������
gdset = [1];
for gd=gdset
groupdata = num2str(gd);
for dtime=[1.4]
% for act=1:20
for act=6:10:480
% iter_d = [];
rng(rn_seed,'twister');% �������������
actno=num2str(act);
%% ��ʼ������
if actN==30
    fpath=['D:\�о�������\RLP-PS����\ʵ�����ݼ�\PSPLIB\j',actNumber,'\J'];
    filename=[fpath,actNumber,'_',actno,'.RCP'];
elseif actN==5||actN ==10
    filename =['D:\�о�������\SRLP-PS-����-20211220\����\SRLP_PS����\J',actNumber,'\��Ŀ��������','\J',actNumber,'_',actno,'.txt'];
end
% ��ȡ��Ŀ����ṹ
[projRelation,actNo,resNo,resNumber,duration,nrsu,nrpr,pred,su,req] = initData(filename);
%% �������
fp_duration = ['D:\�о�������\SRLP-PS-����-20211220\����\SRLP-PS�������\J',actNumber,'\J',actNumber,'_',actno,'_duration.txt'];
stochatic_d = initfile(fp_duration);

% ������Խṹ����
if actN==30
    fp_choice=['D:\�о�������\SRLP-PS����\���ݺʹ���_final\SRLP-PSʵ������\J',actNumber,'\'];
elseif actN==5||actN ==10
    fp_choice = ['D:\�о�������\SRLP-PS-����-20211220\����\SRLP_PS����\J',actNumber,'\',];
end

choicename=[fp_choice,groupdata,'\choice\J',actNumber,'_',actno,'.txt'];
dependname=[fp_choice,groupdata,'\dependent\J',actNumber,'_',actno,'.txt'];
choice = initfile(choicename);
depend = initfile(dependname);
mandatoryname=[fp_choice,groupdata,'\mandatory\J',actNumber,'_',actno,'.txt'];
mandatory = initfile(mandatoryname);
choiceListname=[fp_choice,groupdata,'\choiceList\J',actNumber,'_',actno,'.txt'];
choiceList = initfile(choiceListname);


% д���ļ�·��
% fpathRoot=['C:\Users\ASUS\Desktop\srlp-ps����ʵ��1\DE\J',actNumber,'\'];
fpathRoot=['C:\Users\ASUS\Desktop\����ʵ��-srlp-ps\DE\J',actNumber,'\'];
setName = ['srlp_',num2str(actNo)];
dt=num2str(dtime);

% DE��õĽ�
best_al=zeros(1,actNo);
best_decode = zeros(1,actNo);
best_implement=zeros(1,actNo+2);
best_implement(1,actNo+1)=Inf;
best_implement(1,actNo+2)=Inf;

best_nrpr=nrpr;
best_nrsu=nrsu;
best_pred=pred;
best_projRelation=projRelation;
best_su=su;
% �洢
memory_vl = zeros(1,actNo+2);
memory_vl(actNo+1)=Inf;
memory_vl(actNo+2)=-Inf;
memory_al = zeros(1,actNo);
memory_dl = zeros(1,actNo);
% �ͷ��ɱ�����Ϊ1��
cost=ones(1,resNo);
%% ���л��ִ�е���Ŀ��ֹ����[cpm] ƽ������
[all_est, all_eft]= forward(projRelation, duration);
lftn=all_eft(actNo);
deadline=floor(all_eft(actNo)*dtime);
% disp(deadline)
% % �µĽ�ֹ����
% % ������ɵ��Ȳ���
% implement=zeros(1,actNo+2);
% implement(:,actNo+1)=Inf;
% implement(:,actNo+2)=Inf;
% % ����ʵʩ���Ϊ1
% for j=mandatory
%     implement(j)=1;
% end
% 
% [r,c]=size(choice);
% % ȷ����ѡ�������
% choice_depend=depend(:,1);
% for j=1:r
%     if implement(choice(j,1))==1
%         index = randi([2 c],1,1);  % �ڿ�ѡ���������ѡ��һ���
%         a = choice(j,index);
%         implement(a)=1;
%         if any(a==choice_depend)==1
%             index=find(choice_depend==a);
%            for d=depend(index,2:end)     % ���������
%                 implement(d)=1;
%            end 
%         end
%     end
% end   
% %% ��ʼ�Ľ��뷽ʽ��0 ���У�1 ���С�
% decode=zeros(1,actNo);
% for i=1:popsize
%     temp = rand(1,actNo);
%     decode(i,:) = (temp>0.5==1) ;
% end
% AL = stochastic_al(projRelation,nrpr,nrsu,su,pred,choiceList,implement,actNo);
% [projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,implement,actNo);
% [schedule, u_kt] = SSGS_PSGS1(AL,implement,req,resNumber,duration,nrpr_i,pred_i,deadline,resNo,actNo,decode);
% disp(schedule(actNo))
% % [all_est, all_eft]= forward(projRelation_i, duration);

% ���л������ʱ��
% max_duration = max(stochatic_d,[],1);
% [all_est, all_eft]= forward(projRelation, max_duration);
% max_lftn = all_eft(actNo);
max_lftn = sum(duration);
% disp(max_lftn)
% ƽ�����ڵ��ܺ�
% disp(max_lftn)
% disp('------------')
if max_lftn<deadline
    count_lftn = count_lftn+1;
end
end %ʵ��
end % ��ֹ����
end %����
end % �ֲ�
disp(count_lftn)
end % �����