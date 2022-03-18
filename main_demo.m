close all; clear; clc;
addpath(genpath('./utils/'));
addpath(genpath('./codes/'));

result_URL = './results/';
if ~isdir(result_URL)
    mkdir(result_URL);
end

db = {'MIRFLICKR','IAPRTC-12','NUSWIDE10'};
hashmethods = {'FCMH'};
loopnbits = [8 16 32 64 128];

param.top_R = 0;
param.top_K = 2000;
param.pr_ind = [1:50:1000,1001];
param.pn_pos = [1:100:2000,2000];

for dbi = 1      :length(db)
    db_name = db{dbi}; param.db_name = db_name;
    
    % load dataset
    load(['./datasets/',db_name,'.mat']);
    result_name = [result_URL 'final_' db_name '_result' '.mat'];
    
    if strcmp(db_name, 'IAPRTC-12')
        clear V_tr V_te
        X = [I_tr; I_te]; Y = [T_tr; T_te]; L = [L_tr; L_te];
        R = randperm(size(L,1));
        queryInds = R(1:2000);
        sampleInds = R(2001:end);
        XTrain = X(sampleInds, :); YTrain = Y(sampleInds, :); LTrain = L(sampleInds, :);
        XTest = X(queryInds, :); YTest = Y(queryInds, :); LTest = L(queryInds, :);
        clear X Y L
            
    elseif strcmp(db_name, 'MIRFLICKR')
        X = [I_tr; I_te]; Y = [T_tr; T_te]; L = [L_tr; L_te];
        R = randperm(size(L,1));
        queryInds = R(1:2000);
        sampleInds = R(2001:end);
        XTrain = X(sampleInds, :); YTrain = Y(sampleInds, :); LTrain = L(sampleInds, :);
        XTest = X(queryInds, :); YTest = Y(queryInds, :); LTest = L(queryInds, :);
        clear X Y L
        
    elseif strcmp(db_name, 'NUSWIDE10')
        X = [I_tr; I_te]; Y = [T_tr; T_te]; L = [L_tr; L_te];
        R = randperm(size(L,1));
        queryInds = R(1:2000);
        sampleInds = R(2001:end);
        XTrain = X(sampleInds, :); YTrain = Y(sampleInds, :); LTrain = L(sampleInds, :);
        XTest = X(queryInds, :); YTest = Y(queryInds, :); LTest = L(queryInds, :);
        clear X Y L I_tr I_te T_tr T_te L_tr L_te    
    end
    
    
    %% Label Format
    if isvector(LTrain)
        LTrain = sparse(1:length(LTrain), double(LTrain), 1); LTrain = full(LTrain);
        LTest = sparse(1:length(LTest), double(LTest), 1); LTest = full(LTest);
    end

    
    %% Methods
    eva_info = cell(length(hashmethods),length(loopnbits));
    
    for ii =1:length(loopnbits)
        fprintf('======%s: start %d bits encoding======\n\n',db_name,loopnbits(ii));
        param.nbits = loopnbits(ii);
        for jj = 1:length(hashmethods)
            
            switch(hashmethods{jj})
                case 'FCMH'
                    fprintf('......%s start...... \n\n', 'FCMH');
                    OURparam = param;
                    OURparam.n_map = 5000;
                    OURparam.d_map = 200; %if n > n_map, do pca
                    OURparam.p = min(size(LTrain,2),25); %cluster number
                    OURparam.alpha1 = 100; OURparam.alpha2 = 10;
                    OURparam.beta1 = 10; OURparam.beta2 = 10;
                    OURparam.max_iter = 5; OURparam.gamma = 0.1;  OURparam.xi = 1;
                    eva_info_ = evaluate_FCMH(XTrain,YTrain,LTrain,XTest,YTest,LTest,OURparam);
                end
            eva_info{jj,ii} = eva_info_;
            clear eva_info_
        end
    end

    
    %% MAP
    for ii = 1:length(loopnbits)
        for jj = 1:length(hashmethods)
            % MAP
            Image_VS_Text_MAP{jj,ii} = eva_info{jj,ii}.Image_VS_Text_MAP;
            Text_VS_Image_MAP{jj,ii} = eva_info{jj,ii}.Text_VS_Image_MAP;
            
            % NDCG
            Image_VS_Text_NDCG{jj,ii} = eva_info{jj,ii}.Image_VS_Text_NDCG;
            Text_VS_Image_NDCG{jj,ii} = eva_info{jj,ii}.Text_VS_Image_NDCG;

            % Precision VS Recall
            Image_VS_Text_recall{jj,ii} = eva_info{jj,ii}.Image_VS_Text_recall(param.pr_ind)';
            Image_VS_Text_precision{jj,ii} = eva_info{jj,ii}.Image_VS_Text_precision(param.pr_ind)';
            Text_VS_Image_recall{jj,ii} = eva_info{jj,ii}.Text_VS_Image_recall(param.pr_ind)';
            Text_VS_Image_precision{jj,ii} = eva_info{jj,ii}.Text_VS_Image_precision(param.pr_ind)';

            % Top number Precision
            Image_To_Text_Precision{jj,ii} = eva_info{jj,ii}.Image_To_Text_Precision(param.pn_pos)';
            Text_To_Image_Precision{jj,ii,:} = eva_info{jj,ii}.Text_To_Image_Precision(param.pn_pos)';
            
            % time
            trainT{jj,ii} = eva_info{jj,ii}.trainT;
            compressT{jj,ii} = eva_info{jj,ii}.compressT;
            testT{jj,ii} = eva_info{jj,ii}.testT;
        end
    end

    
    %% Save
    save(result_name,'eva_info','loopnbits','hashmethods','OURparam',...
        'XTrain','XTest','YTrain','YTest','LTrain','LTest',...
        'Image_VS_Text_MAP','Text_VS_Image_MAP','Image_VS_Text_NDCG','Text_VS_Image_NDCG',...
        'trainT','compressT','testT','Image_To_Text_Precision','Text_To_Image_Precision',...
        'Image_VS_Text_recall','Image_VS_Text_precision','Text_VS_Image_recall','Text_VS_Image_precision','-v7.3');
end
