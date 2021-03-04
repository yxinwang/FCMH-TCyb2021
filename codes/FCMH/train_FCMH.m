function B = train_FCMH(LTrain,GTrain,class,param)

    % parameters  
    max_iter = param.max_iter;
    p = param.p;
    alpha1 = param.alpha1; alpha2 = param.alpha2;
    beta1 = param.beta1; beta2 = param.beta2;
    gamma = param.gamma;
    nbits = param.nbits;
    
    n = size(LTrain,1);
    dimL = size(LTrain,2);
    
    % rerange samples
    idx = cell(1,p); idx2 = cell(1,p);
    begin = 0;
    for gi = 1:p
        idx{1,gi} = find(class == gi)';
        idx2{1,gi} = begin+1:begin+length(idx{1,gi});
        begin = begin+length(idx{1,gi});
    end
    idx_all = cell2mat(idx(1,1:p));
    clear class idx begin
    LTrain = LTrain(idx_all,:);
    GTrain = GTrain(idx_all,:);
    
    % class correlation
    GTrain_ = NormalizeFea(LTrain')'; % global: l2-norm column normalized label matrix
    Cg = GTrain_'*GTrain_; % global class correlation
    Dg = diag(sum(Cg)); % global degree matrix
    Cl = cell(1,p); Dl = cell(1,p);
    for gi = 1:p
        GTrain_m_ = NormalizeFea(LTrain(idx2{1,gi},:)')'; % local: l2-norm column normalized label matrix
        Cl{1,gi} = GTrain_m_'*GTrain_m_; % local class correlation
        Dl{1,gi} = diag(sum(Cl{1,gi})); % local degree matrix
    end

    clear GTrain_ GTrain_m_ LTrain_m

    %initization
    G = randn(n, nbits);
    B = sign(randn(n, nbits));
    R = randn(nbits, nbits);
    [U11, ~, ~] = svd(R);
    R = U11(:, 1:nbits);
    
    for i = 1:max_iter
        fprintf('hash learning iter %3d\n', i);
        
        % update P
        tempA = zeros(nbits,dimL);
        tempB = zeros(dimL,dimL);
        for gi = 1:p
            n_m = length(idx2{1,gi});
            Gm = G(idx2{1,gi},:);
            tempA = tempA + Gm'*LTrain(idx2{1,gi},:)*(beta1*Cg+beta2*Cl{1,gi});
            tempB = tempB + n_m*(beta1*Dg+beta2*Dl{1,gi});
        end
        P = tempA / (tempB+gamma*eye(dimL));
        clear n_m Gm tempA tempB
        
        % update G, by groups
        for gi = 1:p
            n_m = length(idx2{1,gi});
            Bm = B(idx2{1,gi},:);
            GTrain_m = GTrain(idx2{1,gi},:);
            Z = Bm*R'+...
                alpha1*nbits*(2*GTrain_m*(GTrain'*B)-ones(n_m,1)*(ones(1,n)*B))+...
                alpha2*nbits*(2*GTrain_m*(GTrain_m'*Bm)-ones(n_m,1)*(ones(1,n_m)*Bm))+...
                LTrain(idx2{1,gi},:)*(beta1*Cg+beta2*Cl{1,gi})*P';

            Temp = Z'*Z-1/n_m*(Z'*ones(n_m,1)*(ones(1,n_m)*Z));
            [~,Lmd,VV] = svd(Temp); clear Temp
            index = (diag(Lmd)>1e-6);
            V = VV(:,index); V_ = orth(VV(:,~index));
            U = (Z-1/n_m*ones(n_m,1)*(ones(1,n_m)*Z)) *  (V / (sqrt(Lmd(index,index))));
            U_ = orth(randn(n_m,nbits-length(find(index==1))));
            Gm = sqrt(n_m)*[U U_]*[V V_]';

            G(idx2{1,gi},:) = Gm;
        end
        clear n_m Bm GTrain_m Z Lmd VV index V V_ U U_ Gm

        % update B, by groups
        for gi = 1:p
            n_m = length(idx2{1,gi});
            Gm = G(idx2{1,gi},:);
            GTrain_m = GTrain(idx2{1,gi},:);
            Bm = sign(Gm*R+alpha1*nbits*(2*GTrain_m*(GTrain'*G)-ones(n_m,1)*(ones(1,n)*G))+...
                alpha2*nbits*(2*GTrain_m*(GTrain_m'*Gm)-ones(n_m,1)*(ones(1,n_m)*Gm)));
            
            B(idx2{1,gi},:) = Bm;
        end
        clear n_m Gm GTrain_m Bm
        
        % update R
        [A1, ~, A2] = svd(B'*G);
        R = A2 * A1';
        clear A1 A2
        
    end
    
    B(B==0) = -1;
    B(idx_all,:) = B; %back to original index of instance
    
end