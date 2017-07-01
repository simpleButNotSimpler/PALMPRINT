function [R, T, moving, angle, er] = icp(moving, fixed, ntimes, threshold, scaling)
    n = size(moving, 1);
    eri = 15200;
    Mdl = KDTreeSearcher(fixed);
    er = zeros(ntimes, 1);
    R = [1 0; 0 1];
    T = [0; 0];
    S = [1 0; 0 1];
    
    for t=1:ntimes
        %correspondance
        Idx = knnsearch(Mdl, moving);
        corrFixed = fixed(Idx, :);
        
        %least square transformation
        [Rn, Tn] = getlst(moving, corrFixed);
        
        %get the scale
        if scaling == 1
            S = getScale(corrFixed, moving, Rn);
        end
        
        
        %apply transformation
        moving = (Rn *S* moving' + repmat(Tn, 1, n))';
        %total transfrmation
        R = R*Rn;
        T = R*T + Tn;

        %rsm
        temp = (corrFixed - moving).^2;
        er(t) = sqrt( sum(sum(temp, 2)));
        
        if abs(eri - er(t)) < threshold || er(t) < threshold
            break;
        end
        
        eri = er(t);
    end
    
%     angle = acos(R(1, 1)) * 180/pi;
    angle = acosd(R(1, 1));
end

%function to compute the least square transformation
function [R, T] = getlst(moving, fixed)
%return a rotation R and a translation T matrix
    n = size(moving, 1);
    H = zeros(2 , 2);
    
    % centroids
    cm = sum(moving) / n;
    cf = sum(fixed) / n;
    
    %rotation matrix
    for i=1:n
        H = H + (moving(i, :) - cm)' * (fixed(i, :) - cf); 
    end
  
    %svd decomposition
    [U,~,V] = svd(H);
    
    %rotation matrix and translation vector
    R = V*U';
    T = cf'- R*cm';
end

%get the scaling between the two data sets
function s = getScale(Q, P, R)
    n = size(P, 1);
    s = zeros(2);
    
    for j=1:2
        den = 0;
        num = 0;
        
        T =  R * E(j);
        for i=1:n
           num = num +  Q(i, :) * T * transpose(P(i, :));
           den = den + P(i, :) * E(j) * transpose(P(i, :));
        end
        
        if den == 0
            den = 1;
        end
        
        s(j, j) = num/den;        
    end

end


function mat = E(i)
    switch(i)
        case 1
            mat = [1 0 ; 0 0 ];
        case 2
            mat = [0 0; 0 1;];      
    end
end