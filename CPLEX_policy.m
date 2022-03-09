% CPLEX
clc
clear
% �������
rep = 100;
% ���ڳͷ��ɱ�
C = 300;
cplex_path= 'D:\��;\�о�������\SRLP-PS-����-20211220\new_model_results\CPLEX\';


for actN=[5]   
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
% CPLEX�������
fp_cplex=[cplex_path,'J',actNumber,'\','srlp_ps_dt_',num2str(dtime),'_100.txt'];
cplex_data = dlmread(fp_cplex);
% ���ʵ��
instanceSet = cplex_data(:,1);
% for act=1:20
for in = 1:length(instanceSet)
act=instanceSet(in);
actno=num2str(act);
%% ��ʼ������
if actN==30
    fpath=['D:\��;\�о�������\RLP-PS����\ʵ�����ݼ�\PSPLIB\j',actNumber,'\J'];
    filename=[fpath,actNumber,'_',actno,'.RCP'];
elseif actN==5||actN ==10
    filename =['D:\��;\�о�������\SRLP-PS-����-20211220\����\SRLP_PS����\J',actNumber,'\��Ŀ��������','\J',actNumber,'_',actno,'.txt'];
end
% ��ȡ��Ŀ����ṹ
[projRelation,actNo,resNo,resNumber,duration,nrsu,nrpr,pred,su,req] = initData(filename);
%% �������
% 1000�η���
fp_duration = ['D:\��;\�о�������\SRLP-PS-����-20211220\����\1000�η���\J',actNumber,'\J',actNumber,'_',actno,'_duration.txt'];
% fp_duration = ['D:\��;\�о�������\SRLP-PS-����-20211220\����\SRLP-PS�������\J',actNumber,'\J',actNumber,'_',actno,'_duration.txt'];
stochatic_d = initfile(fp_duration);

% ������Խṹ����
if actN==30
    fp_choice=['D:\��;\�о�������\SRLP-PS����\���ݺʹ���_final\SRLP-PSʵ������\J',actNumber,'\'];
elseif actN==5||actN ==10
    fp_choice = ['D:\��;\�о�������\SRLP-PS-����-20211220\����\SRLP_PS����\J',actNumber,'\',];
end

choicename=[fp_choice,groupdata,'\choice\J',actNumber,'_',actno,'.txt'];
dependname=[fp_choice,groupdata,'\dependent\J',actNumber,'_',actno,'.txt'];
choice = initfile(choicename);
depend = initfile(dependname);
mandatoryname=[fp_choice,groupdata,'\mandatory\J',actNumber,'_',actno,'.txt'];
mandatory = initfile(mandatoryname);
choiceListname=[fp_choice,groupdata,'\choiceList\J',actNumber,'_',actno,'.txt'];
choiceList = initfile(choiceListname);
%% ���л��ִ�е���Ŀ��ֹ����[cpm] ƽ������
[all_est, all_eft]= forward(projRelation, duration);
lftn=all_eft(actNo);
deadline=floor(dtime*all_eft(actNo));

tic
% ִ���б�
implement = cplex_data(in,9:9+actN+1);
schedule = cplex_data(in,16:end);
% disp(implement)
% �����ȼƻ�ת��Ϊ��б�
[~,al]= sort(schedule);

[projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,implement(1:actNo),actNo);
expected_obj=evaluate_abs_consider_penalty_new_objective(al,rep,implement,req,resNumber,nrpr_i,pred_i,nrsu_i,su_i,deadline,resNo,actNo,stochatic_d,C);
implement(actNo+1)=expected_obj;
cputime = toc;
REP= 1000;
rep_best_implement = implement;
fp_duration1 = ['D:\��;\�о�������\SRLP-PS-����-20211220\����\1000�η���\J',actNumber,'\J',actNumber,'_',actno,'_duration.txt'];
stochatic_d1 = initfile(fp_duration1);
expected_obj=evaluate_abs_consider_penalty_new_objective(al,REP,implement,req,resNumber,nrpr_i,pred_i,nrsu_i,su_i,deadline,resNo,actNo,stochatic_d1,C);
rep_best_implement(actNo+1) = expected_obj;
% д���ļ�·��
fpathRoot=['D:\��;\�о�������\SRLP-PS-����-20211220\new_model_results\CPLEX_policy_sim\J',actNumber,'\'];
setName = ['srlp_cplex_',num2str(actNo)];
dt = num2str(dtime);
outFile=[fpathRoot,setName,'_dt_',dt,'_',num2str(rep),'.txt'];
outResults=[act,implement(actNo+1),rep_best_implement(actNo+1),cputime,al,implement];
dlmwrite(outFile,outResults,'-append', 'newline', 'pc',  'delimiter', '\t');
end % ʵ��
end %��ֹ����
end %����
end % �ֲ�
end % �����