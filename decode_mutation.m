function new_decode = decode_mutation(decode,actNo,p_mutation)
new_decode = decode;
for i= 1:actNo
    %±‰“Ï
    if rand<=p_mutation
        r = rand;
        if r<0.5
            new_decode(i)=0;
        else
            new_decode(i)=1;
        end
    end
end
        