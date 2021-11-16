function [ output] = beamformer_kurtosis(cfg, data, leadfield)
tic;
regparameter=ft_getopt(cfg,'regparameter', 0);


numberpos=size(leadfield.pos,1);
filter=cell(numberpos,2);
orientation=cell(numberpos,2);
valueHigh=zeros(numberpos,1);
valueLow=valueHigh;
kurtMat=kurtosisMatrix(data, regparameter);

for k=1:numberpos
    if leadfield.inside(k)

sigma=1;
        point=kugelwinkel(1/4*sigma*randn,sigma*randn); %1/4 richtig?
        point=sphereToKart(1,point(1), point(2));
        leadfieldO=leadfield.leadfield{k}*point;
        orientation{k,1}=point;
        orientation{k,2}=point;
        kurtTrans=KurtosisTransferS(leadfieldO,regparameter);
        kurtTransI=inv(kurtTrans+regparameter*eye(81));
        filter{k,1}=kurtTransI*kurtMat;
        vHigh=mean(trace(filter{k,1}));
        filter{k,2}=filter{k,1};
        vLow=vHigh;
        steps=10;
        for j=2:steps
            snew=kugelwinkel(1/4*sigma*randn,sigma*randn);
            snew=kugelwinkel(snew(1),snew(2));
            snew=point+sphereToKart(1,snew(1), snew(2));
            leadfieldO=leadfield.leadfield{k}*snew;
            kurtTransNew=KurtosisTransferS(leadfieldO,regparameter);
            kurtTransINew=inv(kurtTransNew+regparameter*eye(81));
            filterNew=kurtTransINew*kurtMat;
            vnew=mean(trace(filterNew));
            
            if vHigh<vnew
                point=snew;
                orientation{k,1}=point;
                vHigh=vnew;
                filter{k,1}=filterNew;
            end
             if vLow>vnew
                point=snew;
                vLow=vnew;
                orientation{k,2}=point;
                filter{k,2}=filterNew;
            end
            sigma=1-j/steps;
        end
        
        orientation{k}=point;
        valueHigh(k)=vHigh;
        valueLow(k)=vLow;
    end
end



output=[];
output.pos=leadfield.pos;
output.inside=leadfield.inside;
output.value=valueLow;
output.valueHigh=valueHigh;
output.valueLow=valueLow;
output.orientation=orientation;

Time=toc;
display(strcat({'Computing time was '}, num2str(Time)));









end

