function[feasible]=resourceFeasible(u_kt,res)
% disp(u_kt)
% �ж����ɵĽ��ȼƻ��Ƿ����
feasible=0;
% ����ÿһ�е������Դռ����
max_req=max(u_kt,[],2);
res_feasible=sum(max_req<=res');
if res_feasible==length(res)
    feasible=1;
end
end
    