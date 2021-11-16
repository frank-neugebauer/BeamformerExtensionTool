function [p] = prob(data, steps)
%data=vertcat(x1, x2, ... xn) Matrix von Zufallsvariablen

nMin=min(min(data));
nMax=max(max(data));

a=(nMax-nMin)/(steps-1);
grid=nMin:a:nMax;
b=-a*1+grid(1);

dataRounded=interp1(grid, grid, data, 'nearest');
p=zeros(steps, size(data,1));

for n=1:size(data, 1)
    
    tab = tabulate(dataRounded(n,:));
    pmf = tab(:, 3) ./ 100;
    
    for m=1:size(pmf)
        p(round((tab(m,1)-b)/a),n)=tab(m,3)/100;       
    end
   
end







































end

