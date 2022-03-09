% 只有DE
% 编码AL-PR-AL
% 目标函数加惩罚,资源波动计算到实际的完成时间
% 改解码

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
for act=6:30:480
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


% 写入文件路径
% fpathRoot=['C:\Users\ASUS\Desktop\srlp-ps测试实验1\DE\J',actNumber,'\'];
fpathRoot=['D:\研途\研究生资料\SRLP-PS-汇总-20211220\new_model_results\DE\J',actNumber,'\'];
setName = ['srlp_',num2str(actNo)];
dt=num2str(dtime);

% DE最好的解
best_al=zeros(1,actNo);
best_implement=zeros(1,actNo+2);
best_implement(1,actNo+1)=Inf;
best_implement(1,actNo+2)=Inf;

best_nrpr=nrpr;
best_nrsu=nrsu;
best_pred=pred;
best_projRelation=projRelation;
best_su=su;
% 惩罚成本【都为1】
cost=ones(1,resNo);
%% 所有活动都执行的项目截止日期[cpm] 平均工期-关键路径
[all_est, all_eft]= forward(projRelation, duration);
lftn=all_eft(actNo);
deadline=floor(dtime*all_eft(actNo));

%% 初始个体
% 计时
tic;
% 记录初始种群的时间
% tstart = tic;
%% 随机生成执行列表【初始活动列表】
% 所有实施活动置为1
implementList=zeros(popsize,actNo+1);
implementList(:,actNo+1)=Inf;
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
%% 初始活动列表AL【根据VL和最晚开始时间生成，满足优先关系排列】
alList=zeros(popsize,actNo);
alList(:,1)=1;
alList(:,actNo)=actNo;
% 计算合格活动集合（所有执行的紧前活动都已经执行）中活动的最晚开始时间，概率(lst)高的话就放进活动列表,未执行的活动随机放。
for i=1:popsize
    implement=implementList(i,:);
    [projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,implement,actNo);
    % 计算最早开始时间和最晚开始时间【平均项目】
    [est, ef]= forwardPass( projRelation_i, duration ,implement);
    [lst, lf]= backwardPass(projRelation_i, duration, deadline,implement);    
    %% 最晚开始时间优先生成初始AL
    ss=lst;
    % 没有执行的活动
    no_index=find(implement(1:actNo)==0);
    len=length(no_index);
    % 随机生成len个位置
    loc_index=randperm(actNo-2,len)+1;
    AL=alList(i,:);
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
            % 选择概率最高的活动
            if ~isempty(eligSet)
                pro=(1/ss(eligSet(1)));
                % 合格活动集中的第一个活动
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
%% 评价初始种群
for i=1:popsize
    implement=implementList(i,1:actNo);
    % 判断项目结构是否可行
    if projectFeasible(implement,choice,depend)==1
         al=alList(i,:);
         % 更新优先关系
         [projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,implement,actNo);
         % 不仿真，用平均工期，算法的终止条件是最多评估多少个个体
         if flag==1
            expected_obj=evaluate_objective_penalty(al,rep,implement,req,resNumber,nrpr_i,pred_i,nrsu_i,su_i,deadline,resNo,actNo,C,duration);
         else 
              % 仿真
             expected_obj=evaluate_abs_consider_penalty_new_objective(al,rep,implement,req,resNumber,nrpr_i,pred_i,nrsu_i,su_i,deadline,resNo,actNo,stochatic_d,C);      
         end
         implementList(i,actNo+1)=expected_obj;
 
         % 记录最好的个体【不考虑服务水平】
         if implementList(i,actNo+1)<best_implement(actNo+1)
             best_implement=implementList(i,:);
             best_al=al;
             best_projRelation=projRelation_i;
             best_nrpr=nrpr_i;
             best_nrsu=nrsu_i;
             best_pred=pred_i;
             best_su=su_i;
         end
    else
        implementList(i,actNo+1)=Inf;
    end
end 
%% 迭代
% 终止条件
end_time = 15;
end_schedules=5000;
nr_schedules=popsize;
% 最大迭代次数
% 如果终止条件是时间限制，最大的迭代次数怎么计算？
% max_iter = ceil(end_time/tused);
max_iter = ceil(end_schedules/(popsize+elit_p));
% 迭代中的种群
new_implementList=implementList;
new_alList = alList;
% 初始参数范围设置
% 控制参数的范围
A_min = 0.3;
A_max = 1.5;
r_min = 0.1;
r_max = 1;
% 交叉概率
%VL
c_i_min = 0.5;
c_i_max = 0.9;
% AL
c_a_min = 0.3;
c_a_max = 0.9;
% 调整DE参数
iter_count = 0;
% while tused<end_time
while nr_schedules<end_schedules
    iter_count = iter_count+1;
    % 生成新的种群，按照概率通过概率矩阵生成或者差分进化
    for pop = 1:popsize 
       %% 变异
        % 新的变异个体
        mutation_implement = zeros(1,actNo+2);
        mutation_implement(actNo+1)=Inf;
        mutation_al = zeros(1,actNo);
        % 控制种群的进化速率【由大变小】，指数减小
        A = A_max*exp(iter_count*log(A_min/A_max)/max_iter);
        if A <A_min
            A = A_min;
        end
        % 两种变异策略的控制概率
        r_m = exp(-(iter_count)/max_iter); % r_m逐渐减小
        % r要逐渐增大
%         r_m = r_min*exp(-(iter_count*log(r_min/r_max)/max_iter)); % 指数增长
%         if r_m>r_max
%             r_m = r_max;
%         end
        %当前个体转换
        current_implement = new_implementList(pop,1:actNo)+rand(1,actNo);
        current_prio = transmute_prio(new_alList(pop,:),actNo);
        for i = 1:actNo 
%             if rand>r_m
            if rand<r_m
                % 随机选择三个个体
                r_list = randperm(popsize,3);
                temp_value = [new_implementList(r_list(1),actNo+1) new_implementList(r_list(2),actNo+1) new_implementList(r_list(3),actNo+1)];
                % 按目标函数值排序，升序
                [~,b]=sort(temp_value);
                r_list = r_list(b);
                r1 = r_list(1);
                r2 = r_list(2);
                r3 = r_list(3);
                % 转化为实值
                al_prio_r1 = transmute_prio(new_alList(r1,:),actNo);
                al_prio_r2 = transmute_prio(new_alList(r2,:),actNo);
                al_prio_r3 = transmute_prio(new_alList(r3,:),actNo);
                implement_r1 = new_implementList(r1,1:actNo)+rand(1,actNo);
                implement_r2 = new_implementList(r2,1:actNo)+rand(1,actNo);
                implement_r3 = new_implementList(r3,1:actNo)+rand(1,actNo);
                % 变异
                mutation_implement(i) = implement_r1(i)+A*(implement_r2(i)-implement_r3(i));
                mutation_al(i) = al_prio_r1(i)+A*(al_prio_r2(i)- al_prio_r3(i));
            else
%                 disp('j')
                % 转换best_al
                best_prio = transmute_prio(best_al,actNo);
                best_implement_pro = best_implement(1:actNo)+rand(1,actNo);
                % 从种群中最好的10%的解中随机选择一个
                % 选择最好的10%个解
                [~,best_part ]= sort(new_implementList(:,actNo+1));
                best_part = best_part(1:popsize*0.1);
                randi_index = randi([1,popsize*0.1],1,1);      
                
                % 另一个精英解
                index1 = best_part(randi_index);
                al_prio_r1 = transmute_prio(new_alList(index1,:),actNo);
                implement_r1 = new_implementList(index1,1:actNo)+rand(1,actNo);

                % 从剩下个体中随机选择一个
                all_index = 1:popsize;
                all_index(best_part)=[];
                % 随机选择一个索引
                randi_index2 = randi([1,length(all_index)],1,1);
                index2 = all_index(randi_index2);
                al_prio_r2 = transmute_prio(new_alList(index1,:),actNo);
                implement_r2 = new_implementList(index1,1:actNo)+rand(1,actNo);
                % 变异
                mutation_implement(i) = current_implement(i)+A*(best_implement_pro(i)-current_implement(i))+A*(implement_r1(i)-implement_r2(i));
                mutation_al(i) = current_prio(i)+A*(best_prio(i)-current_prio(i))+A*(al_prio_r1(i)- al_prio_r2(i));
            end
        end
       %% 交叉
        target_implement = current_implement;
        target_al = current_prio;
        % 试验个体
        trial_implement = zeros(1,actNo);
        trial_al = zeros(1,actNo);
        % 交叉概率【CR由小变大】，指数增加
%         disp(iter_count)
        c_i = c_i_min*exp(iter_count*(-log(c_i_min/c_i_max)/max_iter));
        c_a = c_a_min*exp(iter_count*(-log(c_a_min/c_a_max)/max_iter));
%         
%         % 线性递增，求解效果不好
%         c_i = c_i_min+iter_count*(c_i_max-c_i_min)/max_iter;
%         c_a = c_a_min+iter_count*(c_a_max-c_a_min)/max_iter;
        if c_i<c_i_min
            c_i=c_i_min;
        end
        if c_a<c_a_min
            c_a=c_a_min;
        end
        if c_i>c_i_max
            c_i=c_i_max;
        end
        if c_a>c_a_max
            c_a=c_a_max;
        end

        % 用于交叉的随机数向量
        rand_i = rand(1,actNo);
        rand_a = rand(1,actNo);
        for i=1:actNo
            if rand_i(i)<=c_i
                trial_implement(i) = mutation_implement(i);
            else
                trial_implement(i) = target_implement(i);
            end
            if rand_a(i)<=c_a
                trial_al(i) = mutation_al(i);
            else
                trial_al(i) = target_al(i);
            end 
        end
        
       %% 生成新个体 将试验向量转化执行列表、活动列表和编码列表
        new_implement = transmute_implement(mandatory,depend,choice,trial_implement,actNo);
        new_implement = new_implement(1:actNo+1);
        [projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,new_implement(1:actNo),actNo);
        new_al = transmute_al(new_implement,nrpr_i,pred_i,actNo,trial_al);
%         disp(new_al)
%         disp(trial_implement)
%         disp(new_implement)
        % 评估个体
        % 不仿真，用平均工期，算法的终止条件是最多评估多少个个体
        if flag ==1
            expected_obj=evaluate_objective_penalty(new_al,rep,new_implement,req,resNumber,nrpr_i,pred_i,nrsu_i,su_i,deadline,resNo,actNo,C,duration);
        else
            % 仿真
            expected_obj=evaluate_abs_consider_penalty_new_objective(new_al,rep,new_implement,req,resNumber,nrpr_i,pred_i,nrsu_i,su_i,deadline,resNo,actNo,stochatic_d,C);
        end
        new_implement(actNo+1)=expected_obj;
        if expected_obj<new_implementList(pop,actNo+1)
            new_implementList(pop,:) = new_implement;
            new_alList(pop,:) = new_al;     
        end
        if  expected_obj<best_implement(actNo+1)
            best_implement = new_implement;
%             disp(expected_obj)
%             disp(best_implement)
%             disp(best_implement(actNo+1))
            best_al = new_al;  
            best_nrpr=nrpr_i;
            best_nrsu=nrsu_i;
            best_pred=pred_i;
            best_projRelation=projRelation_i;
            best_su=su_i;
        end
%         disp(best_implement(actNo+1))
    end % 生成新个体结束 一次迭代结束
    nr_schedules=nr_schedules+popsize;
   %% 选择B个最好的个体进行局部改进，剩下的个体直接进入下一代
    p=new_implementList;
    %  选择最好的pop个体作为父代，按照目标函数值升序排（最小的在前面）
    [~,fitIndex]=sort(new_implementList(:,actNo+1));
    fitIndex=fitIndex(1:elit_p);
    %% 局部搜索【在固定项目结构下，进一步探索最优活动列表和解码方式,如果局部搜索得到的个体好于原来的个体，则替换】
    for i=fitIndex'
        temp_VL=new_implementList(i,:);
        temp_AL=new_alList(i,:);
        new_implement=temp_VL;       
        [projRelation_i,nrpr_i,nrsu_i,su_i,pred_i]=updateRelation(projRelation,nrpr,nrsu,su,pred,choiceList,new_implement(1:actNo),actNo);
        % 与相邻的活动移动
        new_AL=AL_mutation(temp_AL,new_implement,nrsu_i,su_i,actNo,p_mutation);
        % 不仿真，用平均工期，算法的终止条件是最多评估多少个个体
        if flag==1 
            expected_obj=evaluate_objective_penalty(new_AL,rep,new_implement,req,resNumber,nrpr_i,pred_i,nrsu_i,su_i,deadline,resNo,actNo,C,duration);
        else
            % 仿真
            expected_obj=evaluate_abs_consider_penalty_new_objective(new_AL,rep,new_implement,req,resNumber,nrpr_i,pred_i,nrsu_i,su_i,deadline,resNo,actNo,stochatic_d,C);
        end
        new_implement(actNo+1)=expected_obj;

        if expected_obj<new_implementList(i,actNo+1)
            new_implementList(i,:) = new_implement;
            new_alList(i,:) = new_AL;     
        end
        if expected_obj<best_implement(actNo+1)
            best_implement=new_implement;
            best_al=new_AL;
            best_nrpr=nrpr_i;
            best_nrsu=nrsu_i;
            best_pred=pred_i;
            best_projRelation=projRelation_i;
            best_su=su_i;
        end
    end 
    nr_schedules=nr_schedules+elit_p; 
%     tused = toc(tstart);
end % 迭代结束
%% 计算真正的目标函数
if flag== 1
    % 评估个体用平均工期，最后需要仿真
    expected_obj=evaluate_abs_consider_penalty_new_objective(best_al,rep,best_implement,req,resNumber,best_nrpr,best_pred,best_nrsu,best_su,deadline,resNo,actNo,stochatic_d,C);
    best_implement(actNo+1) = expected_obj;
end

cputime = toc;
disp(best_implement(actNo+1))

% disp(cputime)
% profile  viewer
%% 写入文件
outResults=[act,best_implement(actNo+1),cputime,best_al,best_implement,end_schedules];
if flag==1
    outFile=[fpathRoot,num2str(end_schedules),'_sch_de_mean_',setName,'_dt_',dt,'_',num2str(rep),'.txt'];
else
    outFile=[fpathRoot,num2str(end_schedules),'_sch_de_new_',setName,'_dt_',dt,'_',num2str(rep),'.txt'];
end
% % 时间
% outResults=[act,best_implement(actNo+1),best_implement(actNo+2),cputime,best_al,best_implement];
% outFile=[fpathRoot,num2str(end_time),'s_sch_de_target_ssgs1_',setName,'_dt_',dt,'_',num2str(rep),'.txt'];
dlmwrite(outFile,outResults,'-append', 'newline', 'pc',  'delimiter', '\t');
outResults=[];
disp(['Instance ',num2str(act),' has been solved.']);
end % 实例
end % 项目截止日期
end % 组数
end % 分布 
end % 活动数量