%% Simple feature pruning and testing

ts=ttest(superflatmat(1:2:end,:),superflatmat(2:2:end,:),.25);
ts(isnan(ts))=0;
minimat=superflatmat(:,logical(ts));
model=svmlearn(minimat,superlabel,' -c 0 -m 2000 -x 1 -o 100')

%% Split halves

superflatmat_1=superflatmat(1:32,:);
superflatmat_2=superflatmat(33:64,:);

superlabel_1=superlabel(1:32);
superlabel_2=superlabel(33:64);

[ts tp]=ttest(superflatmat_1(1:2:end,:),superflatmat_1(2:2:end,:),.001);
ts(isnan(ts))=0;
minimat_1=superflatmat_1(:,logical(ts));
minimat_2=superflatmat_2(:,logical(ts));

model_train=svmlearn(minimat_1,superlabel_1,'-o 100 -x 1')

model_test=svmclassify(minimat_2,superlabel_2,model_train)

% This does not work very well. It all hinges on which set the pruning
% occurs.