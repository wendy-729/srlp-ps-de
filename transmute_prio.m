% 将活动列表转化为权重
function al_prio = transmute_prio(al,actNo)
al_prio = zeros(1,actNo);
prio = actNo;
for i = al
    al_prio(i) = prio/(actNo+1);
    prio = prio-1;
end