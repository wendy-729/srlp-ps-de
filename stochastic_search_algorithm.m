% 依赖于情景，最后不仿真
clc
clear
% profile on 
global rn_seed; % 随机数种子
rn_seed = 13776;
% 随机搜索算法
% 种群大小
popsize=1;
% 仿真次数
rep = 100;
% 按时完成概率
Pr = 0.9;
% 活动数量
actN=30;
actNumber=num2str(actN);
% 测试哪一组数据   
for gd=[1,8]
groupdata = num2str(gd);
for dtime=[1.5,1.8]
% for act = 3:3
for act=6:30:480
rng(rn_seed,'twister');% 设置随机数种子
actno=num2str(act);
%% 初始化数据
if actN==30
    fpath=['D:\研究生资料\RLP-PS汇总\实验数据集\PSPLIB\j',actNumber,'\J'];
    filename=[fpath,actNumber,'_',actno,'.RCP'];
elseif actN==5||actN ==10
    filename =['C:\Users\ASUS\Desktop\SRLP_PS数据\J',actNumber,'\项目网络数据','\J',actNumber,'_',actno,'.txt'];
end
% 获取项目网络结构
[projRelation,actNo,resNo,resNumber,duration,nrsu,nrpr,pred,su,req] = initData(filename);

% 获得柔性结构数据
if actN==30
    fp_choice=['D:\研究生资料\SRLP-PS汇总\数据和代码_final\SRLP-PS实验数据\J',actNumber,'\'];
elseif actN==5||actN ==10
    fp_choice = ['C:\Users\ASUS\Desktop\SRLP_PS数据\J',actNumber,'\',];
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
fpathRoot=['C:\Users\ASUS\Desktop\测试实验20211102\RSA\J',actNumber,'\'];
setName = ['srlp_',num2str(actNo)];
dt=num2str(dtime);
% disp(dt)
%% 随机工期
fp_duration = ['C:\Users\ASUS\Desktop\SRLP-PS随机工期\J',actNumber,'\J',actNumber,'_',actno,'_duration.txt'];
stochatic_d = initfile(fp_duration);

% EDA最好的解
best_AL_EDA=zeros(1,actNo);
best_implement_EDA=zeros(1,actNo+2);
best_implement_EDA(1,actNo+1)=Inf;
best_implement_EDA(1,actNo+2)=Inf;
best_code = zeros(1,actNo+2);
best_nrpr_EDA=nrpr;
best_nrsu_EDA=nrsu;
best_pred_EDA=pred;
best_projRelation_EDA=projRelation;
best_su_EDA=su;
% 惩罚成本【都为1】
cost=ones(1,resNo);
%% 所有活动都执行的项目截止日期[cpm] 平均工期
[all_est, all_eft]= forward(projRelation, duration);
lftn=all_eft(actNo);
deadline=floor(dtime*all_eft(actNo));
%% 迭代
tstart = tic;
implementList=zeros(popsize,actNo+2);
implementList(:,actNo+1)=Inf;
implementList(:,actNo+2)=Inf;
% 所有实施活动置为1
for i=1:popsize
    for j=mandatory
        implementList(i,j)=1;
    end
end
[r,c]=size(choice);
% 确定可选和依赖活动
choice_depend=depend(:,1);
for i=1:popsize
    for j=1:r
        if implementList(i,choice(j,1))==1
            index = randi([2 c],1,1);  % 在可选集合中随机选择一个活动
            a = choice(j,index);
            implementList(i,a)=1;
            if any(a==choice_depend)==1
                index=find(choice_depend==a);
               for d=depend(index,2:end)     % 更新依赖活动
                    implementList(i,d)=1;
               end 
            end
        end
    end
end    
%% 初始活动列表AL【根据VL和随机生成AL】
EDA_AL=zeros(popsize,actNo);
EDA_AL(:,1)=1;
EDA_AL(:,actNo)=actNo;
% 计算合格活动集合（所有执行的紧前活动都已经执行）中活动的最晚开始时间，概率(lst)高的话就放进活动列表,未执行的活动随机放。
for i=1:popsize
    implement=implementList(i,:);
    [projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,implement,actNo);
    % 没有执行的活动
    no_index=find(implement(1:actNo)==0);
    len=length(no_index);
    % 随机生成len个位置
    loc_index=randperm(actNo-2,len)+1;
    % 位置排序
    % loc_index=sort(loc_index);
    AL=EDA_AL(i,:);
    % 将未执行的活动放在随机生成的位置上
    AL(loc_index)=no_index;
    % 已经放在活动列表中的活动
    inList=[1 actNo];
    inList=[inList no_index];
    %   生成活动列表
    for j=2:actNo-1
        % 如果该位置上没有放置活动
        if AL(j)==0
            % 合格活动【不包含未执行活动】
            eligSet=feasibleact(inList,nrpr_i,pred_i,actNo);
    %                 eligSet=feasibleact_rsa(inList,nrpr_i,pred_i,actNo);
            % 随机选择一个合格活动
            index = randi([1,length(eligSet)],1);
            AL(j)=eligSet(index);
            inList = [inList eligSet(index)];
        end
    end
    EDA_AL(i,:)=AL;
end
%% 初始化解码方式
decodeList=zeros(popsize,actNo);
for i=1:popsize
    temp = rand(1,actNo);
    decodeList(i,:) = (temp>0.5==1) ;
end
% 评价个体
for i=1:popsize
    implement=implementList(i,1:actNo);
    % 判断项目结构是否可行
    if projectFeasible(implement,choice,depend)==1
         al=EDA_AL (i,:);
         decode = decodeList(i,:);
        % 更新优先关系
         [projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,implement,actNo);         
         % 对活动列表进行仿真rep次  
        [expected_obj,time_pro,gap_d]=evaluate_abs_consider_gap_code(al,rep,implement,req,resNumber,nrpr_i,pred_i,nrsu_i,su_i,deadline,resNo,actNo,stochatic_d,decode);
         implementList(i,actNo+1)=expected_obj;
         implementList(i,actNo+2)=time_pro;
         % 记录最好的个体【保证服务水平】
         if implementList(i,actNo+1)<best_implement_EDA(actNo+1)
             best_implement_EDA = implementList(i,:);
             best_AL_EDA=al;
             best_decode = decode;
             best_projRelation_EDA=projRelation_i;
             best_nrpr_EDA=nrpr_i;
             best_nrsu_EDA=nrsu_i;
             best_pred_EDA=pred_i;
             best_su_EDA=su_i;
         end
    end
end
tused =  toc(tstart);
% 迭代
end_time = 30;
while tused<end_time
    %% 随机生成执行列表【初始活动列表】
    implementList=zeros(popsize,actNo+2);
    implementList(:,actNo+1)=Inf;
    implementList(:,actNo+2)=Inf;
    % 所有实施活动置为1
    for i=1:popsize
        for j=mandatory
            implementList(i,j)=1;
        end
    end
    [r,c]=size(choice);
    % 确定可选和依赖活动
    choice_depend=depend(:,1);
    for i=1:popsize
        for j=1:r
            if implementList(i,choice(j,1))==1
                index = randi([2 c],1,1);  % 在可选集合中随机选择一个活动
                a = choice(j,index);
                implementList(i,a)=1;
                if any(a==choice_depend)==1
                    index=find(choice_depend==a);
                   for d=depend(index,2:end)     % 更新依赖活动
                        implementList(i,d)=1;
                   end 
                end
            end
        end
    end    
    %% 初始活动列表AL【根据VL和随机生成AL】
    EDA_AL=zeros(popsize,actNo);
    EDA_AL(:,1)=1;
    EDA_AL(:,actNo)=actNo;
    % 计算合格活动集合（所有执行的紧前活动都已经执行）中活动的最晚开始时间，概率(lst)高的话就放进活动列表,未执行的活动随机放。
    for i=1:popsize
        implement=implementList(i,:);
        [projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,implement,actNo);
        % 没有执行的活动
        no_index=find(implement(1:actNo)==0);
        len=length(no_index);
        % 随机生成len个位置
        loc_index=randperm(actNo-2,len)+1;
        % 位置排序
        % loc_index=sort(loc_index);
        AL=EDA_AL(i,:);
        % 将未执行的活动放在随机生成的位置上
        AL(loc_index)=no_index;
        % 已经放在活动列表中的活动
        inList=[1 actNo];
        inList=[inList no_index];
    %   生成活动列表
        for j=2:actNo-1
            % 如果该位置上没有放置活动
            if AL(j)==0
                % 合格活动【不包含未执行活动】
                eligSet=feasibleact(inList,nrpr_i,pred_i,actNo);
%                 eligSet=feasibleact_rsa(inList,nrpr_i,pred_i,actNo);
                % 随机选择一个合格活动
                index = randi([1,length(eligSet)],1);
                AL(j)=eligSet(index);
                inList = [inList eligSet(index)];
            end
        end
        EDA_AL(i,:)=AL;
    end
    %% 初始化解码方式
    decodeList=zeros(popsize,actNo);
    for i=1:popsize
        temp = rand(1,actNo);
        decodeList(i,:) = (temp>0.5==1) ;
    end
    % 评价个体
    for i=1:popsize
        implement=implementList(i,1:actNo);
        % 判断项目结构是否可行
        if projectFeasible(implement,choice,depend)==1
             al=EDA_AL (i,:);
             decode = decodeList(i,:);
            % 更新优先关系
             [projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,implement,actNo);         
             % 对活动列表进行仿真rep次
             [expected_obj,time_pro,gap_d]=evaluate_abs_consider_gap_code(al,rep,implement,req,resNumber,nrpr_i,pred_i,nrsu_i,su_i,deadline,resNo,actNo,stochatic_d,decode);
             implementList(i,actNo+1)=expected_obj;
             implementList(i,actNo+2)=time_pro;
             % 记录最好的个体【保证服务水平】
             if implementList(i,actNo+1)<best_implement_EDA(actNo+1)
                 best_decode = decode;
                 best_implement_EDA = implementList(i,:);
                 best_AL_EDA=al;
                 best_projRelation_EDA=projRelation_i;
                 best_nrpr_EDA=nrpr_i;
                 best_nrsu_EDA=nrsu_i;
                 best_pred_EDA=pred_i;
                 best_su_EDA=su_i;
             end
        else
            disp('项目结构不可行')
        end
    end  % 评价个体结束
    tused = toc(tstart);
end % 迭代结束 
cputime = tused;
[expected_obj,time_pro,gap]=evaluate_abs_nopenalty_code(best_AL_EDA,rep,best_implement_EDA,req,resNumber,best_nrpr_EDA,best_pred_EDA,best_nrsu_EDA,best_su_EDA,deadline,resNo,actNo,stochatic_d,best_decode);
%% 写入文件（目标函数均值，及时完工的概率,AL...）
outResults=[act,best_implement_EDA(actNo+1),best_implement_EDA(actNo+2),cputime,best_AL_EDA,best_implement_EDA];
outFile=[fpathRoot,num2str(end_time),'s_sch_rsa_',setName,'_dt_',dt,'_',num2str(rep),'.txt'];
dlmwrite(outFile,outResults,'-append', 'newline', 'pc',  'delimiter', '\t');
outResults=[];

disp(['Instance ',num2str(act),' has been solved.']);
end % 实例
end % 项目截止日期
end %组数