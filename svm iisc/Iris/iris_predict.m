function [label] = iris_predict(X, gamm, model)
%This function is a custom predict function tailored to
%   perform as specified in DFG for HyperCell.
%
%

%   Useful constants.
m = size(X, 1);     %   Number of examples to predict.
n = size(X, 2);     %   Number of features.
k = model.nr_class; %   Number of output classes.

%   Initialise variables.
accumulator = zeros(k, k-1);
vote_counter = zeros(k, 1);
label = zeros(m ,1);

%   Organise support vectors based on input model.
SV = model.SVs;
alphas = model.sv_coef;
len = model.totalSV;
num_SV = model.nSV;

%   Make prediction.
for p = 1:m

kernelmatrix = zeros(size(alphas));
accumulator = zeros(k, k-1);
for i = 1:len

    kernelmatrix(i, :) = alphas(i, :) .* gaussianKernel(SV(i, :)', X(p, :)', gamm);
    
end

beg = 1;
en = 1;
for i = 1:k

    en = beg + num_SV(i) - 1;
    accumulator(i, :) = sum(kernelmatrix(beg:en, :));
    beg = en + 1;
    
end    

vote_counter = zeros(k, 1);
for i = 1:k
    for j = (i+1):(k)    
        index = (i * (k - i/2 + 1/2)) + j - i - k;
        decision = accumulator(i, j-1) + accumulator(j, i) + model.rho(index);
        if(decision > 0)
            vote_counter(i)++;
        else
            vote_counter(j)++;
        end        
    end    
end

[~, label(p)] = max(vote_counter);
end
end
