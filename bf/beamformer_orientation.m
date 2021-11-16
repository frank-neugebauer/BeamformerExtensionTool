function [ orientation ] = beamformer_orientation(cfg)

leadfield=cfg.leadfield;
%covariancematrix=cfg.covariancematrix;

numberpos=size(leadfield.pos,1);

orientation=cell(numberpos,1);
covariancematrixI=cfg.covariancematrixI;
covariancematrixI2=covariancematrixI*covariancematrixI;

switch cfg.orimethod
    case 'sam_robinson' %this should give the same orientation as 'unit_noise_gain' below
        for n=1:numberpos
            A=leadfield.leadfield{n}'*covariancematrixI*leadfield.leadfield{n};
            B=leadfield.leadfield{n}'*covariancematrixI2*leadfield.leadfield{n};
            [eigenVector,~] = eig(B\A);
            
            %search for maximizing eigenVector
            numberEigenVectors=size(eigenVector,2);
            vector=eigenVector(:,1);
            value=vector'*A*vector/(vector'*B*vector);
            for k=2:numberEigenVectors
                vector2=eigenVector(:,k);
                value2=vector2'*A*vector2/(vector2'*B*vector2);
                if value2>=value
                    vector=vector2;
                end
            end
            orientation{n}=vector;
        end
        
        
        %The following three methods are implemented as described bySekigahara, 'adaptiv spatial filters for
        %electromagnetic brain imaging', page 45 ff
    case 'unit_gain'
        for n=1:numberpos
            matrix=leadfield.leadfield{n}'*covariancematrixI*leadfield.leadfield{n};
            orientation{n}=minEigenVector(matrix);
        end
        
    case 'unit_array_gain'
        for n=1:numberpos
            matrix1=leadfield.leadfield{n}'*covariancematrixI*leadfield.leadfield{n};
            matrix2=leadfield.leadfield{n}'*leadfield.leadfield{n};
            orientation{n}=minEigenVector2(matrix1,matrix2);
            
              if ~isreal(orientation{n})
               error('orientation is not real. Matrix eigenvector is not real');
              end
            
        end
        
        
    case 'sharp_unit_array_gain'
        
        error('No orientation method avalaible. Use another orientation? :(');
        
        
        
    case 'unit_noise_gain'
        for n=1:numberpos
            matrix1=leadfield.leadfield{n}'*covariancematrixI2*leadfield.leadfield{n};
            matrix2=leadfield.leadfield{n}'*covariancematrixI*leadfield.leadfield{n};
            orientation{n}=minEigenVector2(matrix1,matrix2);
            
            if ~isreal(orientation{n})
                warning('orientation is not real. Matrix eigenvector is not real');
            end
        end
        
        %     case 'unit_noise_gain_rand'
        %         steps=100;
        %         for n=1:numberPos
        %             sigma=1;
        %                point=kugelwinkel(1/4*sigma*randn,sigma*randn); %1/4 richtig?
        %         for k=1:steps
        
        
    case 'lcmv'
        %vector beamformer
        
    case 'bayes'
        %sets a number of orientations to test on a unit sphere
       
        orientation=distr_sphere(cfg.oriNumber);
        
        %orientation=cfg.orientation;
        
     %  index_0=find(subplus(orientation(:,3)));
      % orientation=orientation(index_0,:);
       disp(['Using ', num2str(size(orientation,1)), ' different orientations']);
        
        
    case 'given'
        orientation=cfg.orientation;
        
    otherwise
        
        
        
        
        
end

end


function [vector]=minEigenVector(matrix)

[eigenVector,eigenValue] = eig(matrix);
eigenValue=diag(eigenValue);
[minEigenValue, indexMinEigenValue]=min(eigenValue);
vector=eigenVector(:,indexMinEigenValue);


end


function [vector]=minEigenVector2(matrix1, matrix2)

[eigenVector,eigenValue] = eig(matrix1,matrix2, 'qz');
eigenValue=diag(eigenValue);
[minEigenValue, indexMinEigenValue]=min(eigenValue);
vector=eigenVector(:,indexMinEigenValue);

vector=vector/norm(vector);
end
