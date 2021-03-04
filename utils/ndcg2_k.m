function res=ndcg2_k(I, Lbase, Lquery, n_k)

% I is the predicted oeder, an n by m matrix
% n_k is the top number
% Lbase is the ground-truth label matrix of database
% Lquery is the ground-truth label matrix of query set

% y is the ground truth relevance, an n by m matrix
% n is the size of query set
% m is the size of retrieval set

% I = full(I);
% y = full(y);

if ~exist('n_k','var') || n_k==0
    n_k = size(Lbase,1); % Configurable
end

% y = Lquery*Lbase'; % base vesiion
% y = NormalizeFea(Lquery,1)*NormalizeFea(Lbase,1)'; % base version+

% y: specialized for FCMH
Gbase_ = NormalizeFea(Lbase')'; % column normalization
Cg = Gbase_'*Gbase_; % hlobal class correlation
y = NormalizeFea(Lquery,1)*Cg*NormalizeFea(Lbase,1)';
clear Lbase Lquery

% return the averaged ndcg for retrieving items for the users
[n,m]=size(I);

%% compute the ranks of the items for each user

[~, ideal_I] = sort(y, 2, 'descend');

% res = zeros(1, n_k);
res = 0;
cnt = 0;
for i=1:n
    nominator = (2.^y(i, I(i,1:n_k))-1)./log2([1:n_k]+1);
    denominator = (2.^y(i, ideal_I(i,1:n_k))-1) ./ log2([1:n_k]+1);
    
    tmp = sum(nominator)./ sum(denominator);
    cnt = cnt + 1;
    %tmp = full(tmp);
    %tmp = padarray(tmp, [0, length(k_vals) - size(tmp, 2)], 0, 'post');
	res = res + tmp;
end
res = res / cnt;
