function [XKTrain,XKTest]=Kernel_Feature(XTrain,XTest,Anchors,Xsigma)
    
    
    [nX,Xdim]=size(XTrain);
    [nXT,XTdim]=size(XTest);

    XKTrain = sqdist(XTrain',Anchors');
    if ~exist('Xsigma','var') || Xsigma == -1000
        Xsigma = mean(mean(XKTrain,2));
    end
    XKTrain = exp(-XKTrain/(2*Xsigma^2));
    Xmvec = mean(XKTrain);
    XKTrain = XKTrain-repmat(Xmvec,nX,1);
    
    XKTest = sqdist(XTest',Anchors');
    XKTest = exp(-XKTest/(2*Xsigma^2));
    XKTest = XKTest-repmat(Xmvec,nXT,1);
end