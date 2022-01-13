max_iter= 10;
iter_count = 1:max_iter;
r_min = 0.1;
r_max = 1;
r_m1 = r_min*exp(-(iter_count.*log(r_min/r_max)/max_iter)); % 指数增长
r_m2 = exp(-(iter_count*2)./max_iter);
r_m3 = [];
for i=1:max_iter
    r_m = 1/(1+exp(1-(max_iter/i)^2));
    r_m3 = [r_m3 r_m];
end
plot(iter_count,r_m1)
hold on;
plot(iter_count,r_m2)
plot(iter_count,r_m3)
legend('r_m1','r_m2','r_m3')