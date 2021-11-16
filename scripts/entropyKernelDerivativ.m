function [ entropyDev ] = entropyKernelDerivativ(cfg, data, W)
%% see 
%Lecture Notes on Nonparametrics
%Bruce E. Hansen


kernel=ft_getopt(cfg, 'kernel', 'Gauss');
width=ft_getopt(cfg, 'width', 'silverman');

switch kernel
    
    case {'Gauss', 'gauss'}      
        dK=@(x) 1/sqrt(2*pi)*exp(-x^2/2)*(-x);
        K=@(x) 1/sqrt(2*pi)*exp(-x^2/2);
        const=1.06;
        
    case {'biweight', 'quartic'}
        K=@(x) 15/16*(1-x^2)^2*(abs(x)<=1);   
        dK=@(x) -15/4*(1-x^2)*x;
        const=2.78;
end


switch width

    case 'silverman'
        n=length(data);
        h=std(W'*data)*const*n^(-1/5);
        dh=const*1/n*sum((2*W'*data).*data, 2)-const*2*(1/n*sum(W'*data, 2)*sum(1/n*data, 2));

end



%K2=@(x, y) K((x-y)/h); 

p=@(x) 1/n*1/h*sum(arrayfun(K, (W'*data-x)/h), 2);
dp=@(x) -1/(2*h^2)*1/n*dh.*sum(arrayfun(K, (data-x)/h), 2)+1/(n*h)*sum((-data/h-(x-W'*data)).*dh*1/h^2.*arrayfun(dK, (data-x)/h), 2);
       % this is almost surely somehow false :) 


       
       
de=@(x) NanOrNumber(dp(x).*log(p(x))+dp(x), 0);

%de1=@(x) xArg(NanOrNumber(dp(x).*log(p(x))+dp(x), 0), 1);
       
       
                entropyDev=-integral(de, -Inf, Inf, 'ArrayValued', 1);













end

