% 只有DE
% 编码AL-PR-AL
% 有gap，仿真100次，得到的gap，用于精确算法计算
% 加解码方式
% 改了交叉的方式
% 执行列表转化为连续向量
% 添加了存储
% 改变了截止日期的计算时间


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
% 及时完成的概率
Pr=0.9;
count_lftn = 0;
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
for dtime=[1.4]
% for act=1:20
for act=6:10:480
% iter_d = [];
rng(rn_seed,'twister');% 设置随机数种子
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

% DE最好的解
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
% 存储
memory_vl = zeros(1,actNo+2);
memory_vl(actNo+1)=Inf;
memory_vl(actNo+2)=-Inf;
memory_al = zeros(1,actNo);
memory_dl = zeros(1,actNo);
% 惩罚成本【都为1】
cost=ones(1,resNo);
%% 所有活动都执行的项目截止日期[cpm] 平均工期
[all_est, all_eft]= forward(projRelation, duration);
lftn=all_eft(actNo);
deadline=floor(all_eft(actNo)*dtime);
% disp(deadline)
% % 新的截止日期
% % 随机生成调度策略
% implement=zeros(1,actNo+2);
% implement(:,actNo+1)=Inf;
% implement(:,actNo+2)=Inf;
% % 所有实施活动置为1
% for j=mandatory
%     implement(j)=1;
% end
% 
% [r,c]=size(choice);
% % 确定可选和依赖活动
% choice_depend=depend(:,1);
% for j=1:r
%     if implement(choice(j,1))==1
%         index = randi([2 c],1,1);  % 在可选集合中随机选择一个活动
%         a = choice(j,index);
%         implement(a)=1;
%         if any(a==choice_depend)==1
%             index=find(choice_depend==a);
%            for d=depend(index,2:end)     % 更新依赖活动
%                 implement(d)=1;
%            end 
%         end
%     end
% end   
% %% 初始的解码方式【0 串行，1 并行】
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

% 所有活动的最长完成时间
% max_duration = max(stochatic_d,[],1);
% [all_est, all_eft]= forward(projRelation, max_duration);
% max_lftn = all_eft(actNo);
max_lftn = sum(duration);
% disp(max_lftn)
% 平均工期的总和
% disp(max_lftn)
% disp('------------')
if max_lftn<deadline
    count_lftn = count_lftn+1;
end
end %实例
end % 截止日期
end %组数
end % 分布
disp(count_lftn)
end % 活动数量