% ֻ��DE
% ����AL-PR-AL
% ��gap������100�Σ��õ���gap�����ھ�ȷ�㷨����
% �ӽ��뷽ʽ
% ���˽���ķ�ʽ
% ִ���б�ת��Ϊ��������
% û�б����б�

clc
clear
% profile on 
global rn_seed; % ���������
rn_seed = 13776;
decode = zeros(1,32);
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
for dtime=[1.5]
% for act=1:20
for act=6:10:100
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
fpathRoot=['C:\Users\ASUS\Desktop\srlp-ps����ʵ��\DE\J',actNumber,'\'];
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
% �ͷ��ɱ�����Ϊ1��
cost=ones(1,resNo);
%% ���л��ִ�е���Ŀ��ֹ����[cpm] ƽ������
[all_est, all_eft]= forward(projRelation, duration);
lftn=all_eft(actNo);
deadline=floor(dtime*all_eft(actNo));
% disp(deadline)
% % ���л������ʱ��
% max_duration = max(stochatic_d,[],1);
% [all_est, all_eft]= forward(projRelation, max_duration);
% max_lftn = all_eft(actNo);
% disp(max_lftn)
% % disp(floor(max_lftn*dtime))
%% ��ʱ
tstart = tic;
%% �������ִ���б���ʼ��б�
% ����ʵʩ���Ϊ1
implementList=zeros(popsize,actNo+2);
implementList(:,actNo+1)=Inf;
implementList(:,actNo+2)=Inf;
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
% %% ��ʼ�Ľ��뷽ʽ��0 ���У�1 ���С�
% decodeList=zeros(popsize,actNo);
% for i=1:popsize
%     temp = rand(1,actNo);
%     decodeList(i,:) = (temp>0.5==1) ;
% end
%% ��ʼ��б�AL������VL������ʼʱ�����ɡ�
alList=zeros(popsize,actNo);
alList(:,1)=1;
alList(:,actNo)=actNo;
% ����ϸ����ϣ�����ִ�еĽ�ǰ����Ѿ�ִ�У��л������ʼʱ�䣬����(lst)�ߵĻ��ͷŽ���б�,δִ�еĻ����š�
for i=1:popsize
    implement=implementList(i,:);
    [projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,implement,actNo);
    % �������翪ʼʱ�������ʼʱ�䡾ƽ����Ŀ��
    [est, ef]= forwardPass( projRelation_i, duration ,implement);
    [lst, lf]= backwardPass(projRelation_i, duration, deadline,implement);    
    %% ����ʼʱ���������ɳ�ʼAL
    ss=lst;
    % û��ִ�еĻ
    no_index=find(implement(1:actNo)==0);
    len=length(no_index);
    % �������len��λ��
    loc_index=randperm(actNo-2,len)+1;
    AL=alList(i,:);
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
            % ѡ�������ߵĻ
            if ~isempty(eligSet)
                pro=(1/ss(eligSet(1)));
                % �ϸ����еĵ�һ���
                index=eligSet(1);
                for e1=eligSet
                    pro_e=1/ss(e1);
                    if pro_e>pro
                        index=e1;
                    end
                end
                AL(j)=index;
                inList(end+1)=index;
            end
        end
    end
    alList(i,:)=AL;
end
%% ���۳�ʼ��Ⱥ
for i=1:popsize
    implement=implementList(i,1:actNo);
    % �ж���Ŀ�ṹ�Ƿ����
    if projectFeasible(implement,choice,depend)==1
%          decode = decodeList(i,:);
         al=alList(i,:);
         % �������ȹ�ϵ
         [projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,implement,actNo);
         % �Ի�б���з���rep��
         [expected_obj,time_pro,gap_d]=evaluate_abs_consider_gap_code(al,rep,implement,req,resNumber,nrpr_i,pred_i,nrsu_i,su_i,deadline,resNo,actNo,stochatic_d,decode);
         
         implementList(i,actNo+1)=expected_obj;
         implementList(i,actNo+2)=time_pro;

         % ��¼��õĸ��塾�����Ƿ���ˮƽ��
         if implementList(i,actNo+1)<best_implement(actNo+1)
             best_implement=implementList(i,:);
             best_al=al;
             best_decode = decode;
             best_projRelation=projRelation_i;
             best_nrpr=nrpr_i;
             best_nrsu=nrsu_i;
             best_pred=pred_i;
             best_su=su_i;
         end
    else
        disp('��Ŀ�ṹ������')
    end
end 
%% ����
% ʱ����ֹ����
end_time = 30;
end_schedules=2000;
nr_schedules=popsize;
% ����������
tused = toc(tstart);
max_iter = ceil(end_time/tused);
% max_iter = ceil(end_schedules/popsize);
% �����ֹ������ʱ�����ƣ����ĵ���������ô���㣿
% �����е���Ⱥ
new_implementList=implementList;
new_alList = alList;
% new_decodeList = decodeList;
% ��ʼ��������
A_min = 0.3;
A_max = 1.5;
r_min = 0.1;
r_max = 1;
c_i_min = 0.5;
c_i_max = 0.9;
c_a_min = 0.3;
c_a_max = 0.9;

% ����DE����
iter_count = 0;
% while tused<end_time
while nr_schedules<end_schedules
    iter_count = iter_count+1;
    % �����µ���Ⱥ�����ո���ͨ�����ʾ������ɻ��߲�ֽ���
    for pop = 1:popsize 
        % ���ѡ����������
        r_list = randperm(popsize,3);
        temp_value = [new_implementList(r_list(1),actNo+1) new_implementList(r_list(2),actNo+1) new_implementList(r_list(3),actNo+1)];
        % ��Ŀ�꺯��ֵ��������
        [~,b]=sort(temp_value);
        r_list = r_list(b);
        r1 = r_list(1);
        r2 = r_list(2);
        r3 = r_list(3);
        % ת��Ϊʵֵ
        al_prio_r1 = transmute_prio(new_alList(r1,:),actNo);
        al_prio_r2 = transmute_prio(new_alList(r2,:),actNo);
        al_prio_r3 = transmute_prio(new_alList(r3,:),actNo);
        implement_r1 = new_implementList(r1,1:actNo)+rand(1,actNo);
        implement_r2 = new_implementList(r2,1:actNo)+rand(1,actNo);
        implement_r3 = new_implementList(r3,1:actNo)+rand(1,actNo);
%         code_r1 = new_decodeList(r1,:)+rand(1,actNo);
%         code_r2 = new_decodeList(r2,:)+rand(1,actNo);
%         code_r3 = new_decodeList(r3,:)+rand(1,actNo);
       %% ����
        % �µı������
        mutation_implement = zeros(1,actNo+2);
        mutation_implement(actNo+1)=Inf;
        mutation_implement(actNo+2)=Inf;
        mutation_decode = zeros(1,actNo);
        mutation_al = zeros(1,actNo);
        % ������Ⱥ�Ľ������ʡ��ɴ��С����ָ����С
        A = A_max*exp(iter_count*log(A_min/A_max)/max_iter);
        if A <A_min
            A = A_min;
        end
        % rҪ������
        r_m = r_min*exp(-(iter_count*log(r_min/r_max)/max_iter)); % ָ������
        if r_m>r_max
            r_m = r_max;
        end
        %��ǰ����ת��
%         current_code = new_decodeList(pop,1:actNo)+rand(1,actNo);
        current_implement = new_implementList(pop,1:actNo)+rand(1,actNo);
        current_prio = transmute_prio(new_alList(pop,:),actNo);
        for i = 1:actNo 
            if rand>r_m
                mutation_implement(i) = implement_r1(i)+A*(implement_r2(i)-implement_r3(i));
%                 mutation_decode(i) = code_r1(i)+A*(code_r2(i)-code_r3(i));
                mutation_al(i) = al_prio_r1(i)+A*(al_prio_r2(i)- al_prio_r3(i));
            else
                % ת��best_al
                best_prio = transmute_prio(best_al,actNo);
                best_implement_pro = best_implement(1:actNo)+rand(1,actNo);
                best_decode_pro = best_decode(1:actNo)+rand(1,actNo);

%                 mutation_implement(i) = current_implement(i)+A*(best_implement_pro(i)-current_implement(i)+implement_r2(i)-implement_r3(i));
%                 mutation_decode(i) = current_code(i)+A*(best_decode_pro(i)-current_code(i)+code_r2(i)-code_r3(i));
%                 mutation_al(i) = current_prio(i)+A*(best_prio(i)-current_prio(i)+al_prio_r2(i)- al_prio_r3(i));
                
                mutation_implement(i) = current_implement(i)+A*(best_implement_pro(i)-current_implement(i));
%                 mutation_decode(i) = current_code(i)+A*(best_decode_pro(i)-current_code(i));
                mutation_al(i) = current_prio(i)+A*(best_prio(i)-current_prio(i));
            end
        end
       %% ����
        target_implement = current_implement;
%         target_decode = current_code;
        target_al = current_prio;
        % �������
        trial_implement = zeros(1,actNo);
        trial_al = zeros(1,actNo);
        trial_decode = zeros(1,actNo);
        % ������ʡ�CR�ɴ��С����ָ����С
        c_i = c_i_max*exp(iter_count*log(c_i_min/c_i_max)/max_iter);
        c_a = c_a_max*exp(iter_count*log(c_a_min/c_a_max)/max_iter);
        if c_i<c_i_min
            c_i=c_i_min;
        end
        if c_a<c_a_min
            c_a=c_a_min;
        end
        % ���ڽ�������������
        rand_i = rand(1,actNo);
        rand_a = rand(1,actNo);
        for i=1:actNo
            if rand_i(i)<=c_i
                trial_implement(i) = mutation_implement(i);
                trial_decode(i)=mutation_decode(i);
            else
                trial_implement(i) = target_implement(i);
%                 trial_decode(i)=target_decode(i);
            end
            if rand_a(i)<=c_a
                trial_al(i) = mutation_al(i);
            else
                trial_al(i) = target_al(i);
            end 
        end
       %% ����������ת��ִ���б���б�ͱ����б�
        new_code = (trial_decode>=1==1);
        new_implement = transmute_implement(mandatory,depend,choice,trial_implement,actNo);
        [projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,new_implement(1:actNo),actNo);
        new_al = transmute_al(new_implement,nrpr_i,pred_i,actNo,trial_al);
        % ��������
        [expected_obj,time_pro,gap_d]=evaluate_abs_consider_gap_code(new_al,rep,new_implement,req,resNumber,nrpr_i,pred_i,nrsu_i,su_i,deadline,resNo,actNo,stochatic_d,new_code);
%         iter_d = [iter_d gap_d];
        
        new_implement(actNo+1)=expected_obj;
        new_implement(actNo+2)=time_pro; 

        if expected_obj<new_implementList(pop,actNo+1)
            new_implementList(pop,:) = new_implement;
            new_alList(pop,:) = new_al;     
            new_decodeList(pop,:)=new_code;
        end
        if  expected_obj<best_implement(actNo+1)
            best_implement = new_implement;
            best_al = new_al;  
            best_decode = new_code;
            best_nrpr=nrpr_i;
            best_nrsu=nrsu_i;
            best_pred=pred_i;
            best_projRelation=projRelation_i;
            best_su=su_i;
        end
    end % �����¸������ һ�ε�������
    nr_schedules=nr_schedules+popsize;
   %% ѡ��B����õĸ���
    p=new_implementList;
    %  ѡ����õ�pop������Ϊ����������Ŀ�꺯��ֵ�����ţ���С����ǰ�棩
    [~,fitIndex]=sort(new_implementList(:,actNo+1));
    fitIndex=fitIndex(1:elit_p);
    %% �ֲ��������ڹ̶���Ŀ�ṹ�£���һ��̽�����Ż�б�ͽ��뷽ʽ,����ֲ������õ��ĸ������ԭ���ĸ��壬���滻��
    for i=fitIndex'
        temp_code = new_decodeList(i,:);
        temp_VL=new_implementList(i,:);
        temp_AL=new_alList(i,:);
        new_implement=temp_VL;       
        [projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,new_implement(1:actNo),actNo);
        % ��code
        temp_code = decode_mutation1(temp_code,actNo,p_mutation);
        % �����ڵĻ�ƶ�
        new_AL=AL_mutation(temp_AL,new_implement,nrsu_i,su_i,actNo,p_mutation);
        [expected_obj,time_pro,gap_d]=evaluate_abs_consider_gap_code(new_AL,rep,new_implement,req,resNumber,nrpr_i,pred_i,nrsu_i,su_i,deadline,resNo,actNo,stochatic_d,temp_code);
%         iter_d = [iter_d gap_d];
        
        new_implement(actNo+1)=expected_obj;
        new_implement(actNo+2)=time_pro;
        if expected_obj<new_implementList(i,actNo+1)
            new_implementList(i,:) = new_implement;
            new_alList(i,:) = new_AL;     
            new_decodeList(i,:)=temp_code;
        end
        if expected_obj<best_implement(actNo+1)
            best_implement=new_implement;
            best_al=new_AL;
            best_decode = temp_code;
            best_nrpr=nrpr_i;
            best_nrsu=nrsu_i;
            best_pred=pred_i;
            best_projRelation=projRelation_i;
            best_su=su_i;
        end
    end  
    nr_schedules=nr_schedules+elit_p; 
    tused = toc(tstart);
end % ��������
end_gap = [];
%% ����������Ŀ�꺯��
if best_implement(actNo+1)~=Inf
    [expected_obj,time_pro,gap]=evaluate_abs_nopenalty_code(best_al,rep,best_implement,req,resNumber,best_nrpr,best_pred,best_nrsu,best_su,deadline,resNo,actNo,stochatic_d,best_decode);
    best_implement(actNo+1) = expected_obj;
    best_implement(actNo+2) = time_pro;
    end_gap = [end_gap gap];
end
cputime = tused;
disp(cputime)
disp(best_implement(actNo+1))
disp(best_implement(actNo+2))
% disp('------------')

if isempty(end_gap)
    end_gap = 0;
else
    end_gap = max(end_gap);
end
% disp(end_gap)
% profile  viewer
% %% д���ļ�
% outResults=[act,best_implement(actNo+1),best_implement(actNo+2),cputime,best_al,best_implement,end_schedules];
% outFile=[fpathRoot,num2str(end_schedules),'_sch_de_',setName,'_dt_',dt,'_',num2str(rep),'.txt'];
% % ʱ��
% % outResults=[act,best_implement(actNo+1),best_implement(actNo+2),cputime,best_al,best_implement];
% % outFile=[fpathRoot,num2str(end_time),'s_sch_de_target_ssgs1_',setName,'_dt_',dt,'_',num2str(rep),'.txt'];
% dlmwrite(outFile,outResults,'-append', 'newline', 'pc',  'delimiter', '\t');
% % д��gap
% outResults1 = [act, end_gap];
% outFile1=[fpathRoot,num2str(end_schedules),'_sch_de_gap_',setName,'_dt_',dt,'_',num2str(rep),'.txt'];
% dlmwrite(outFile1,outResults1,'-append', 'newline', 'pc',  'delimiter', '\t');
% 
% outResults=[];
% outResults1=[];
% disp(['Instance ',num2str(act),' has been solved.']);
end % ʵ��
end % ��Ŀ��ֹ����
end % ����
end % �ֲ� 
end % �����