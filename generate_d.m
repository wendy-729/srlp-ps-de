clc
clear
% profile on 
global rn_seed; % 随机数种子
rn_seed = 13776;
% EDA参数设置
para=[100,0.1,0.3,100];
% 种群大小
popsize=para(1);
% 局部搜索的个体数
elit_p=popsize*para(2);
% AL局部搜索的概率
p_mutation=para(3);
% 情景的个数
rep=para(4);
% 超期的惩罚成本
C=300;
% 评价个体使用平均工期为1,仿真为0
flag =0;
% 活动数量
for actN=[30]
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
for dtime=[1.2,1.4]
% for act=1:20
for act=6:6
% iter_d = [];
rng(rn_seed,'twister');% 设置随机数种子
actno=num2str(act);
%% 初始化数据
if actN==30
    fpath=['D:\研途\研究生资料\RLP-PS汇总\实验数据集\PSPLIB\j',actNumber,'\J'];
    filename=[fpath,actNumber,'_',actno,'.RCP'];
elseif actN==5||actN ==10
    filename =['D:\研途\研究生资料\SRLP-PS-汇总-20211220\数据\SRLP_PS数据\J',actNumber,'\项目网络数据','\J',actNumber,'_',actno,'.txt'];
end
% 获取项目网络结构
[projRelation,actNo,resNo,resNumber,duration,nrsu,nrpr,pred,su,req] = initData(filename);
%% 随机工期
fp_duration = ['D:\研途\研究生资料\SRLP-PS-汇总-20211220\数据\SRLP-PS随机工期\J',actNumber,'\J',actNumber,'_',actno,'_duration.txt'];
stochatic_d = initfile(fp_duration);

% 获得柔性结构数据
if actN==30
    fp_choice=['D:\研途\研究生资料\SRLP-PS汇总\数据和代码_final\SRLP-PS实验数据\J',actNumber,'\'];
elseif actN==5||actN ==10
    fp_choice = ['D:\研途\研究生资料\SRLP-PS-汇总-20211220\数据\SRLP_PS数据\J',actNumber,'\',];
end

choicename=[fp_choice,groupdata,'\choice\J',actNumber,'_',actno,'.txt'];
dependname=[fp_choice,groupdata,'\dependent\J',actNumber,'_',actno,'.txt'];
choice = initfile(choicename);
depend = initfile(dependname);
mandatoryname=[fp_choice,groupdata,'\mandatory\J',actNumber,'_',actno,'.txt'];
mandatory = initfile(mandatoryname);
choiceListname=[fp_choice,groupdata,'\choiceList\J',actNumber,'_',actno,'.txt'];
choiceList = initfile(choiceListname);
%% 所有活动都执行的项目截止日期[cpm] 平均工期-关键路径
[all_est, all_eft]= forward(projRelation, duration);
lftn=all_eft(actNo);
deadline=floor(dtime*all_eft(actNo));
%% 随机生成一个解/考虑启发式算法，平均工期解码，获得项目的完成时间

end
end
end
end
end
