function [ output_args ] = beamformer_bayes( cfg, data, lead )




%estimate cov-matrix

C=1/size(data,2)*(data*data');
CI=inv(C);


%for every point q



%for every direction d
    %D=size(

        %estimate the standard filter
        leadfieldO=leadfield.leadfield{q}*orientation{d};
        sigma2(d)=1/(leadfieldO'*covariancematrixI*leadfieldO);
        w{d}=covariancematrixI*leadfieldO*sigma2(d);


        %estimate the constant y and the probability
        [N T]=size(data); %N sensors K samples


        y(d)=N*(N*sigma2)/(1+N*sigma2); %assuming sigma_noise =1
        p(d)=1/D; %uniformly distributed

        pData(d)=p(d)*exp(K*y*sigma2(d));
    %estimate constant so pData*c is a probability 
    c=0;
    for d=
    c=c+pData(d);
    end

    pData=c*pData;

    filter{n}=pData(1)*w(1);
    for d=2:
    filter{n}=filter{n}+pData(d)*w(d);
    end



















































end