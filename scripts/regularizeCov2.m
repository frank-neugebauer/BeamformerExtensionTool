function [CovReg, delta] = regularizeCov2(Cov,maxcond, KeepTrace)
%RegularizeCovariance takes a matrix C and adds a scaled identity matrix,
%such that the resulting matrix has a condition number smaller than
%maxcond and the same trace as Cov.
% The scaling is as small as possible for with a minimum stepsize of 1.007

if nargin==2
    KeepTrace=1;
end

% descale
m = size(Cov,1);

if KeepTrace
traceCov = trace(Cov);
Cov = m/traceCov  * Cov;
end

CovReg = Cov;

upfac = [50 10 5 2 1.25 1.1 1.05 1.015 1.007]; %1.1 was originally the lowest
delta = eps*upfac(1);


%For each scaling factor, increase the regularisation until the condition
%is met, then go back to the last strongest reg before
% Refine stepsize to get closer to the minimum necessary
% Last, make the last step again to meet the condition

% 
% for i_up = 1:length(upfac)
%     
%     while (cond(CovReg) > maxcond)  %scale until condition is met
%         delta = delta*upfac(i_up); %increase delta
%            CovReg =Cov + delta * eye(size(Cov))*norm(Cov); %1-delta or 1/delta ?
% 
%     end
%     delta = delta/upfac(i_up);
%         CovReg =Cov + delta * eye(size(Cov))*norm(Cov);
% 
% end
% 
% delta = delta*upfac(i_up);   %Added by me,
% CovReg = Cov + delta * eye(size(Cov))*norm(Cov); %
% 

for i_up = 1:length(upfac)
    
    while (cond(CovReg) > maxcond)  %scale until condition is met
        delta = delta*upfac(i_up); %increase delta
           CovReg =Cov + delta * eye(size(Cov))*trace(Cov)/size(Cov,1); %1-delta or 1/delta ?

    end
    delta = delta/upfac(i_up);
        CovReg =Cov + delta * eye(size(Cov))*trace(Cov)/size(Cov,1);

end

delta = delta*upfac(i_up);   %Added by me,
CovReg = Cov + delta * eye(size(Cov))*trace(Cov)/size(Cov,1); %


%scale
if KeepTrace
CovReg = CovReg * traceCov/m;
end


end