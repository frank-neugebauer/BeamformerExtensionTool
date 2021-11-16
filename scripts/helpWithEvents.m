
j=1;
for i=1:4308
if event(i,2)~=71
    event2(j,:)=event(i,:);
    j=j+1;
end
end

%%

timeDiff=event2(2:end,1)-event2(1:end-1,1);

%%
j=1;
for i=1:4308
if event(i,2)==0
    event0(j,:)=event(i,:);
    j=j+1;
end
end

size(event0)
%%

