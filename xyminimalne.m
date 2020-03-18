function [X,Y] = xyminimalne(m)
[x,y]=size(m);
w=min(min(m));
for i=1:x
    for j=1:y
        if m(i,j)==w
            X=i;
            Y=j;
        end
    end
end
end