% �������龰����󲻷���
clc
clear
% profile on 
global rn_seed; % ���������
rn_seed = 13776;
% ��������㷨
% ��Ⱥ��С
popsize=1;
% �������
rep = 100;
% ��ʱ��ɸ���
Pr = 0.9;
flag=0;
C=3;
% �����
for actN=[30]
actNumber=num2str(actN);
% ������һ������   
for gd=[1,8]
groupdata = num2str(gd);
for dtime=[1.2,1.4]
% for act = 1:20
for act=6:30:480
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
fpathRoot=['C:\Users\ASUS\Desktop\��ģ�Ͳ���ʵ��-srlp-ps\RSA\J',actNumber,'\'];
setName = ['srlp_',num2str(actNo)];
dt=num2str(dtime);

% EDA��õĽ�
best_AL=zeros(1,actNo);
best_implement=zeros(1,actNo+1);
best_implement(1,actNo+1)=Inf;

best_nrpr=nrpr;
best_nrsu=nrsu;
best_pred=pred;
best_projRelation=projRelation;
best_su=su;
% �ͷ��ɱ�����Ϊ1��
cost=ones(1,resNo);
%% ���л��ִ�е���Ŀ��ֹ����[cpm] ƽ������
[all_est, all_eft]= forward(projRelation, duration);
lftn=all_eft(actNo);
deadline=floor(dtime*all_eft(actNo));
%
end_time =30;
% tic
tstart = tic;
tused =  toc(tstart);
nr_schedules = 0;
end_schedules = 3000;
while nr_schedules<end_schedules
% while tused<end_time
    %% �������ִ���б�����ʼ��б���
    implementList=zeros(popsize,actNo+2);
    implementList(:,actNo+1)=Inf;
    % ����ʵʩ���Ϊ1
    for i=1:popsize
        for j=mandatory
            implementList(i,j)=1;
        end
    end
    [r,c]=size(choice);
    % ȷ����ѡ�������
    choice_depend=depend(:,1);
    for i=1:popsize
        for j=1:r
            if implementList(i,choice(j,1))==1
                index = randi([2 c],1,1);  % �ڿ�ѡ���������ѡ��һ���
                a = choice(j,index);
                implementList(i,a)=1;
                if any(a==choice_depend)==1
                    index=find(choice_depend==a);
                   for d=depend(index,2:end)     % ���������
                        implementList(i,d)=1;
                   end 
                end
            end
        end
    end    
    %% ��ʼ��б�AL������VL���������AL��
    EDA_AL=zeros(popsize,actNo);
    EDA_AL(:,1)=1;
    EDA_AL(:,actNo)=actNo;
    % ����ϸ����ϣ�����ִ�еĽ�ǰ����Ѿ�ִ�У��л��������ʼʱ�䣬����(lst)�ߵĻ��ͷŽ���б�,δִ�еĻ����š�
    for i=1:popsize
        implement=implementList(i,:);
        [projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,implement,actNo);
        % û��ִ�еĻ
        no_index=find(implement(1:actNo)==0);
        len=length(no_index);
        % �������len��λ��
        loc_index=randperm(actNo-2,len)+1;
        % λ������
        % loc_index=sort(loc_index);
        AL=EDA_AL(i,:);
        % ��δִ�еĻ����������ɵ�λ����
        AL(loc_index)=no_index;
        % �Ѿ����ڻ�б��еĻ
        inList=[1 actNo];
        inList=[inList no_index];
    %   ���ɻ�б�
        for j=2:actNo-1
            % �����λ����û�з��û
            if AL(j)==0
                % �ϸ���������δִ�л��
                eligSet=feasibleact(inList,nrpr_i,pred_i,actNo);
%                 eligSet=feasibleact_rsa(inList,nrpr_i,pred_i,actNo);
                % ���ѡ��һ���ϸ�
                index = randi([1,length(eligSet)],1);
                AL(j)=eligSet(index);
                inList = [inList eligSet(index)];
            end
        end
        EDA_AL(i,:)=AL;
    end
    %% ��ʼ�����뷽ʽ
    decodeList=zeros(popsize,actNo);
    for i=1:popsize
        temp = rand(1,actNo);
        decodeList(i,:) = (temp>0.5==1) ;
    end
    % ���۸���
    for i=1:popsize
        implement=implementList(i,1:actNo);
        % �ж���Ŀ�ṹ�Ƿ����
        if projectFeasible(implement,choice,depend)==1
             al=EDA_AL (i,:);
             decode = decodeList(i,:);
            % �������ȹ�ϵ
             [projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,implement,actNo);         
             
             % �����棬��ƽ�����ڣ��㷨����ֹ����������������ٸ�����
             if flag==1
                expected_obj=evaluate_objective_penalty(al,rep,implement,req,resNumber,nrpr_i,pred_i,nrsu_i,su_i,deadline,resNo,actNo,C,duration);
             else 
                  % ����
                 expected_obj=evaluate_abs_consider_penalty_new_objective(al,rep,implement,req,resNumber,nrpr_i,pred_i,nrsu_i,su_i,deadline,resNo,actNo,stochatic_d,C);      
             end
             implementList(i,actNo+1)=expected_obj;
            
             % ��¼��õĸ��塾��֤����ˮƽ��
             if implementList(i,actNo+1)<best_implement(actNo+1)
                 best_decode = decode;
                 best_implement = implementList(i,:);
                 best_AL=al;
                 best_projRelation=projRelation_i;
                 best_nrpr=nrpr_i;
                 best_nrsu=nrsu_i;
                 best_pred=pred_i;
                 best_su=su_i;
             end
        else
            disp('��Ŀ�ṹ������')
        end
    end  % ���۸������
%     tused = toc(tstart);
    nr_schedules = nr_schedules+1;
end % �������� 
% cputime = toc;
cputime = tused;

outResults=[act,best_implement(actNo+1),cputime,best_AL,best_implement,end_schedules];
if flag==1
    outFile=[fpathRoot,num2str(end_schedules),'_sch_rsa_mean_',setName,'_dt_',dt,'_',num2str(rep),'.txt'];
else
    outFile=[fpathRoot,num2str(end_schedules),'_sch_rsa_',setName,'_dt_',dt,'_',num2str(rep),'.txt'];
end
% % ʱ��
% outResults=[act,best_implement(actNo+1),best_implement(actNo+2),cputime,best_al,best_implement];
% outFile=[fpathRoot,num2str(end_time),'s_sch_de_target_ssgs1_',setName,'_dt_',dt,'_',num2str(rep),'.txt'];
dlmwrite(outFile,outResults,'-append', 'newline', 'pc',  'delimiter', '\t');
outResults=[];
disp(['Instance ',num2str(act),' has been solved.']);
end % ʵ��
end % ��Ŀ��ֹ����
end %����
end %��ģ��С