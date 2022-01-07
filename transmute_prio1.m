% 将活动列表转化为权重
function al_prio = transmute_prio1(al,actNo)
al_prio = zeros(1,actNo);
count =0;
for i = al
    count = count+1;
    al_prio(i) = count+rand;
end