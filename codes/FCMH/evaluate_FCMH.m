function evaluation_info=evaluate_FCMH(XTrain,YTrain,LTrain,XTest,YTest,LTest,param)

    % ----------------- Normalize -----------------
    % XTrain = (XTrain-repmat(mean(XTrain,2),1,size(XTrain,2))); % row zero-mean
    % YTrain = (YTrain-repmat(mean(YTrain,2),1,size(YTrain,2)));
    % XTest = (XTest-repmat(mean(XTest,2),1,size(XTest,2)));
    % YTest = (YTest-repmat(mean(YTest,2),1,size(YTest,2)));
    
    % XTrain = double(XTrain);
    % XTrain = NormalizeFea(XTrain,1); % row L2-normalized
    % YTrain = NormalizeFea(YTrain,1);
    % XTest = double(XTest);
    % XTest = NormalizeFea(XTest,1);
    % YTest = NormalizeFea(YTest,1);
    
    
    GTrain = NormalizeFea(LTrain,1); %L2-norm row normalized label matrix

    % ----------------- clustering ----------------------
    disp('pca');
    if size(LTrain,1) > param.n_map
        [mappedX,~] = pca(XTrain,param.d_map);
        [mappedY,~] = pca(YTrain,param.d_map);
    else
        mappedX = XTrain; mappedY = YTrain;
    end
    disp('clustering');
    [class,~,~,~,~,~] = rmkmeans_(mappedX,mappedY,param.p); %multi-view kmeans
    clear mappedX mappedY
    
    % ----------------- hash learning ----------------------
    tic;
    B = train_FCMH(LTrain,GTrain,class,param);

    XW = (XTrain'*XTrain+param.xi*eye(size(XTrain,2)))    \    XTrain'*B;
    YW = (YTrain'*YTrain+param.xi*eye(size(YTrain,2)))    \    YTrain'*B;
    evaluation_info.trainT=toc;

    % ----------------- codes for query ----------------- 
    tic;
    BxTrain = compactbit(B>=0);
    ByTrain = BxTrain;
    BxTest = compactbit(XTest*XW>0);
    ByTest = compactbit(YTest*YW>0);
    evaluation_info.compressT = toc;
    
    % ----------------- evaluate ----------------- 
    tic;
    DHamm = hammingDist(BxTest, ByTrain);
    [~, orderH] = sort(DHamm, 2);
	evaluation_info.Image_VS_Text_MAP = mAP(orderH', LTrain, LTest);
    [evaluation_info.Image_VS_Text_precision, evaluation_info.Image_VS_Text_recall] = precision_recall(orderH', LTrain, LTest);
    evaluation_info.Image_To_Text_Precision = precision_at_k(orderH', LTrain, LTest,param.top_K);
    evaluation_info.Image_VS_Text_NDCG = ndcg2_k(orderH,LTrain, LTest);
    
    DHamm = hammingDist(ByTest, BxTrain);
    [~, orderH] = sort(DHamm, 2);
    evaluation_info.Text_VS_Image_MAP = mAP(orderH', LTrain, LTest);
    [evaluation_info.Text_VS_Image_precision,evaluation_info.Text_VS_Image_recall] = precision_recall(orderH', LTrain, LTest);
    evaluation_info.Text_To_Image_Precision = precision_at_k(orderH', LTrain, LTest,param.top_K);
    evaluation_info.Text_VS_Image_NDCG = ndcg2_k(orderH,LTrain, LTest);
    
    evaluation_info.testT = toc;
    
end
