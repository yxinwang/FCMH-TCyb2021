function [outG0,outFCell,outAlpha,outAlpha_r,outObj,outNumIter]...
    =rmkmeans_(XTrain,YTrain,c,maxIter,inG0)

    % parameter settings
    thresh = 1e-3;
    r = 0.5;
    numView = 2;
    n = size(XTrain, 1);
    
    inXCell{1,1} = XTrain';
    inXCell{2,1} = YTrain';
    clear XTrain YTrain
    
    if ~exist('maxIter','var')
        maxIter = 100;
    end
    
    if ~exist('inG0','var')
        inG0 = repmat(randperm(c)',ceil(n/c),1); inG0 = inG0(1:n,:);
    end
    
    % inti alpha
    alpha = ones(numView, 1)/numView;
    % inti common indicator D3
    D4 = cell(1,numView);
    for v = 1: numView
        %D4{v} = sparse(diag(ones(n, 1))* alpha(v)^r);
        
        %D4{v} = spdiags(ones(n,1),0,n,n)* alpha(v)^r;
        D4{v} = ones(n,1)*alpha(v)^r;
    end
    
    G0 = inG0;
    if isvector(G0)
        G0 = sparse(1:length(inG0), double(inG0), 1); G0 = full(G0);
    end
    clear inG0
    
    c = size(G0,2);
    
    tmp = 1/(1-r);
    obj = zeros(maxIter, 1);
    % loop
    for t = 1: maxIter
        %fprintf('clustering iteration %d...\n', t);

        % Fix D3{v}, G0, alpha, update F{v}
        F = cell(1,numView);
        for v = 1: numView
            %M = (G0'*D4{v}*G0);
            %N = inXCell{v}*D4{v}*G0;
            M = repmat(D4{v}',c,1).*G0'*G0;
            N = repmat(D4{v}',size(inXCell{v},1),1).*inXCell{v}*G0;
            F{v} = N/M;
        end
        clear M N

        % Fix D3{v}, F{v}, update G0
        Obj = zeros(n,c);
        for v = 1: numView
            %Obj = Obj + repmat(diag(D4{v}),1,size(F{v},2)).*sqdist(inXCell{v},F{v});
            Obj = Obj + repmat(D4{v},1,size(F{v},2)).*sqdist(inXCell{v},F{v});
        end
        [~, min_idx] = min(Obj,[],2);
        G0 = sparse(1:length(min_idx), double(min_idx), 1); G0 = full(G0);
        clear Obj min_idx

        % Fix F{v}, G0, D4{v}, update alpha
        h = zeros(numView, 1);
        E = cell(1,numView);
        Ei2 = cell(1,numView);
        for v = 1: numView
            E{v} = (inXCell{v} - F{v}*G0')';
            Ei2{v} = sqrt(sum(E{v}.*E{v}, 2));
            h(v) = sum(Ei2{v});
        end
        alpha = ((r*h).^tmp)/(sum(((r*h).^tmp)));

        % Fix F{v}, G0, update D4{v}
        for v = 1: numView
            E{v} = (inXCell{v} - F{v}*G0')';
            Ei2{v} = sqrt(sum(E{v}.*E{v}, 2) + eps);
            %D4{v} = sparse(diag(0.5./Ei2{v}*(alpha(v)^r)));
            
            %D4{v} = spdiags(0.5./Ei2{v},0,n,n)* alpha(v)^r;
            D4{v} = 0.5./Ei2{v}* alpha(v)^r;
        end

        % calculate the obj
        obj(t) = 0;
        for v = 1: numView
            obj(t) = obj(t) + (alpha(v)^r)*sum(Ei2{v});
        end
        if(t > 1)
            diff = obj(t-1) - obj(t);
            if(diff < thresh)
                break;
            end
        end
        
        
        if(t > 1)
            diff = (obj(t-1)-obj(t))/abs(obj(t-1));
            %fprintf('loss is %.4f, residual error is %.5f\n', obj(t), diff);
            if(abs(diff) < thresh)
                break;
            end
        end
    end
    
    % debug
    % figure, plot(1: length(obj), obj);

    outObj = obj;
    outNumIter = t;
    outFCell = F;
    outG0 = G0;
    outAlpha = alpha;
    outAlpha_r = alpha.^r;

    outG0 = mod(find(outG0'==1),c)+1;
end