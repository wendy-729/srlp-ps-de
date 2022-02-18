% CPLEX
clc
clear
% 仿真次数
rep = 10;
% 超期惩罚成本
C = 3;
for actN=[5]
actNumber=num2str(actN);
%分布类型
distribution=cell(1,1);
distribution{1,1}='U1';
for disT=distribution
disT=char(disT);
% 测试哪一组数据 J10是第三组数据
gdset = [1];
for gd=gdset
groupdata = num2str(gd);
for dtime=[1.2]
% for act=1:20
for act=4:4
actno=num2str(act);
%% 初始化数据
if actN==30
    fpath=['D:\研究生资料\RLP-PS汇总\实验数据集\PSPLIB\j',actNumber,'\J'];
    filename=[fpath,actNumber,'_',actno,'.RCP'];
elseif actN==5||actN ==10
    filename =['D:\研究生资料\SRLP-PS-汇总-20211220\数据\SRLP_PS数据\J',actNumber,'\项目网络数据','\J',actNumber,'_',actno,'.txt'];
end
% 获取项目网络结构
[projRelation,actNo,resNo,resNumber,duration,nrsu,nrpr,pred,su,req] = initData(filename);
%% 随机工期
fp_duration = ['D:\研究生资料\SRLP-PS-汇总-20211220\数据\SRLP-PS随机工期\J',actNumber,'\J',actNumber,'_',actno,'_duration.txt'];
stochatic_d = initfile(fp_duration);

% 获得柔性结构数据
if actN==30
    fp_choice=['D:\研究生资料\SRLP-PS汇总\数据和代码_final\SRLP-PS实验数据\J',actNumber,'\'];
elseif actN==5||actN ==10
    fp_choice = ['D:\研究生资料\SRLP-PS-汇总-20211220\数据\SRLP_PS数据\J',actNumber,'\',];
end

choicename=[fp_choice,groupdata,'\choice\J',actNumber,'_',actno,'.txt'];
dependname=[fp_choice,groupdata,'\dependent\J',actNumber,'_',actno,'.txt'];
choice = initfile(choicename);
depend = initfile(dependname);
mandatoryname=[fp_choice,groupdata,'\mandatory\J',actNumber,'_',actno,'.txt'];
mandatory = initfile(mandatoryname);
choiceListname=[fp_choice,groupdata,'\choiceList\J',actNumber,'_',actno,'.txt'];
choiceList = initfile(choiceListname);


% 写入文件路径
% fpathRoot=['C:\Users\ASUS\Desktop\srlp-ps测试实验1\DE\J',actNumber,'\'];
fpathRoot=['C:\Users\ASUS\Desktop\测试实验-srlp-ps\DE\J',actNumber,'\'];
setName = ['srlp_',num2str(actNo)];
dt=num2str(dtime);
%% 所有活动都执行的项目截止日期[cpm] 平均工期
[all_est, all_eft]= forward(projRelation, duration);
lftn=all_eft(actNo);
deadline=floor(dtime*all_eft(actNo));

best_implement = [1	0	1	1	0	1	1];
best_schedule = [0	0	0	3	0	10	19];
% 将进度计划转化为活动列表
[~,best_al]= sort(best_schedule);

[projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,best_implement(1:actNo),actNo);
expected_obj=evaluate_abs_consider_penalty_new_objective(best_al,rep,best_implement,req,resNumber,nrpr_i,pred_i,nrsu_i,su_i,deadline,resNo,actNo,stochatic_d,C);
disp(expected_obj)
end % 实例
end %截止日期
end %组数
end % 分布
end % 活动数量