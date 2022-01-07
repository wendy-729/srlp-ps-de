function[feasible]=resourceFeasible(u_kt,res)
% disp(u_kt)
% 判断生成的进度计划是否可行
feasible=0;
% 计算每一行的最大资源占用量
max_req=max(u_kt,[],2);
res_feasible=sum(max_req<=res');
if res_feasible==length(res)
    feasible=1;
end
end
    