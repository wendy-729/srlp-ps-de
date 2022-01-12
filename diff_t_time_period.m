duration = [2,2,2,1,3,3];
schedule = [0,2,4,6,7,7];
req = [3;2;3;2;2;1];
resNo = 1;
deadline = 10;
u_kt = zeros(1,10);
for act=1:6
    ss = schedule(act);
    for k=1:resNo 
       for t=(ss+1):(ss+duration(act))
%            disp(req(act,k))
          u_kt(k,t)=u_kt(k,t)+req(act,k);
       end
    end
end
disp(u_kt)
scen_obj = 0;
for k=1:resNo
    for t=2:deadline
        if u_kt(k,t)-u_kt(k,t-1)<0
            temp = u_kt(k,t-1)-u_kt(k,t);
        else
            temp = u_kt(k,t)-u_kt(k,t-1);
        end
        scen_obj=scen_obj+temp;
    end                
    scen_obj = scen_obj+u_kt(k,1);
end  
disp(scen_obj)