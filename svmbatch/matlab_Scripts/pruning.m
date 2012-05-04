%% Simple feature pruning and testing

ts=ttest(superflatmat(1:2:end,:),superflatmat(2:2:end,:),.01);
ts(isnan(ts))=0;
minimat=superflatmat(:,logical(ts));
model=svmlearn(minimat,superlabel,' -c 0 -m 2000 -x 1 -o 100')

%This works kick-ass. We get 100% LOOCV.

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

% This does not work quite as well. We get 100% LOOCV on the first half,
% but only 60% on the second half.

%% Paired SVM

ts=ttest(superflatmat(1:2:end,:),superflatmat(2:2:end,:),.01);
ts(isnan(ts))=0;

superflatmat_pbompd=superflatmat(1:2:end,:)-superflatmat(2:2:end,:);
superflatmat_mpdpbo=superflatmat(2:2:end,:)-superflatmat(1:2:end,:);

superflatmat_paired=[superflatmat_pbompd;superflatmat_mpdpbo];

superlabels_paired=[repmat(1,32,1);repmat(-1,32,1)];



minimat_paired=superflatmat_paired(:,logical(ts));

model=svmlearn(minimat_paired,superlabels_paired,' -c 0 -m 2000 -x 1 -o 10000')


%% Paired Halves


superflatmat_pbompd=superflatmat(1:2:end,:)-superflatmat(2:2:end,:);
superflatmat_mpdpbo=superflatmat(2:2:end,:)-superflatmat(1:2:end,:);

superflatmat_paired(1:2:60,:)=superflatmat_pbompd;
superflatmat_paired(2:2:60,:)=superflatmat_mpdpbo;

superflatmat_paired_1=superflatmat_paired(1:30,:);
superflatmat_paired_2=superflatmat_paired(31:60,:);

superlabels_paired_1=repmat([1; -1],15,1);
superlabels_paired_2=repmat([1; -1],15,1);

[ts tp]=ttest(superflatmat_paired_1(1:2:end,:),0,.001);
ts(isnan(ts))=0;

minimat_1=superflatmat_paired_1(:,logical(ts));
minimat_2=superflatmat_paired_2(:,logical(ts));

model_train=svmlearn(minimat_1,superlabels_paired_1,'-o 100 -x 1')

model_test=svmclassify(minimat_2,superlabels_paired_2,model_train)

%% Think about doing this with randomly labeled cases
% Paired Halves, with random labels
superflatmat_pbompd=superflatmat(1:2:end,:)-superflatmat(2:2:end,:);
superflatmat_mpdpbo=superflatmat(2:2:end,:)-superflatmat(1:2:end,:);

superflatmat_paired(1:2:60,:)=superflatmat_pbompd;
superflatmat_paired(2:2:60,:)=superflatmat_mpdpbo;

superflatmat_paired_1=superflatmat_paired(1:30,:);
superflatmat_paired_2=superflatmat_paired(31:60,:);

superlabels_paired_1=repmat([1; -1],15,1);
superlabels_paired_2=repmat([1; -1],15,1);

switchers_1=sort(randsample(1:15,8));
switchers_2=sort(randsample(1:15,8));

superlabels_paired_1(switchers_1*2-1)=-1;
superlabels_paired_1(switchers_1*2)=+1;

superlabels_paired_2(switchers_2*2-1)=-1;
superlabels_paired_2(switchers_2*2)=+1;



[ts tp]=ttest(superflatmat_paired_1(switchers_1*2,:),0,.001);
ts(isnan(ts))=0;

minimat_1=superflatmat_paired_1(:,logical(ts));
minimat_2=superflatmat_paired_2(:,logical(ts));

model_train=svmlearn(minimat_1,superlabels_paired_1,'-o 100 -x 1')

model_test=svmclassify(minimat_2,superlabels_paired_2,model_train)

%% Iterative LOOCV with iterative pruning?

superflatmat_pbompd=superflatmat(1:2:end,:)-superflatmat(2:2:end,:);
superflatmat_mpdpbo=superflatmat(2:2:end,:)-superflatmat(1:2:end,:);

superflatmat_paired(1:2:60,:)=superflatmat_pbompd;
superflatmat_paired(2:2:60,:)=superflatmat_mpdpbo;

pruneLOO=zeros(30,size(superflatmat,2));

models_train={};
models_test={};

for iL=1:30
    subjects=[1:(iL-1) (iL+1):30];
    indices=sort([subjects*2 subjects*2-1]);
    
    
    
    train=superflatmat_paired(indices,:);
    trainlabels=repmat([1; -1],size(train,1)/2,1);
    
    prune=ttest(train(1:2:end,:),0,.001);
    prune(isnan(prune))=0;
    pruneLOO(iL,:)=prune;
    
    train=train(:,logical(prune));
    test=superflatmat_paired([iL*2-1 iL*2],logical(prune));
    
    models_train{iL}=svmlearn(train,trainlabels,'-o 100 -x 0');
    
    models_test{iL}=svmclassify(test,[1 ; -1],models_train{iL})

end

pruneIntersect=sum(pruneLOO,1);
pruneIntersect(pruneIntersect~=30)=0;
pruneIntersect(pruneIntersect==30)=1;

supertrain = superflatmat_paired(:,logical(pruneIntersect));
superlabels=repmat([1; -1],30,1);

supermodel = svmlearn(supertrain,superlabel,'-o 100 -x 1')