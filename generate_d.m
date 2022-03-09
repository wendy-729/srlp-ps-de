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
% ���ڵĳͷ��ɱ�
C=300;
% ���۸���ʹ��ƽ������Ϊ1,����Ϊ0
flag =0;
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
for dtime=[1.2,1.4]
% for act=1:20
for act=6:6
% iter_d = [];
rng(rn_seed,'twister');% �������������
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
fp_duration = ['D:\��;\�о�������\SRLP-PS-����-20211220\����\SRLP-PS�������\J',actNumber,'\J',actNumber,'_',actno,'_duration.txt'];
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
%% ���л��ִ�е���Ŀ��ֹ����[cpm] ƽ������-�ؼ�·��
[all_est, all_eft]= forward(projRelation, duration);
lftn=all_eft(actNo);
deadline=floor(dtime*all_eft(actNo));
%% �������һ����/��������ʽ�㷨��ƽ�����ڽ��룬�����Ŀ�����ʱ��

end
end
end
end
end
