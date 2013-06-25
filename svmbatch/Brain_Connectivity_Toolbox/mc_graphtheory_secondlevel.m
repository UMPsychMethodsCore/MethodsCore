%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File path
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Exp = '/net/data4/ADHD/GraphTheory/';
SubFolder = '0624';
Network = '7';
Metric = 'degree';

plevel = 0.05;
permlevel = 0.05;
nRep = 10000;



%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load files
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FLTemplate = '[Exp]/[SubFolder]/FirstLevel/network[Network]/[Metric].mat';
FLPath     = mc_GenPath(struct('Template',FLTemplate,...
    'suffix','.mat',...
    'mode','check'));
Flfile     = load(FLPath);
Fldata     = Flfile.SaveData;

nROI = size(Fldata,2);
nSub = size(Fldata,1);

TypeTemplate = '[Exp]/[SubFolder]/FirstLevel/type.mat';
TypePath     = mc_GenPath(struct('Template',TypeTemplate,...
    'suffix','.mat',...
    'mode','check'));
Typefile     = load(TypePath);
Type         = Typefile.types;

unitype = unique(Type);
covtype = 1;
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% t-test for each ROI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tmark = zeros(1,nROI);
meandiff = zeros(1,nROI);
for iCol = 1:nROI
    testmetric = Fldata(:,iCol);
    if covtype % like 'A' and 'H'
        testhc = testmetric(Type==unitype(2));
        testds = testmetric(Type==unitype(1));
    else
        testhc = testmetric(Type==unitype(1));
        testds = testmetric(Type==unitype(2));
    end 
    meanhc = mean(testhc);
    meands = mean(testds);
    meandiff(iCol) = meanhc - meands;
    [~,p,~,tval]=ttest2(testhc,testds);
    if p<plevel
        tmark(iCol)=1;
    end
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% permutation test for each ROI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
perm = zeros(nRep,nROI);
permmark = zeros(1,nROI);

for n = 1:nRep
    fprintf(1,'%g\n',n);
    ind = randperm(length(Type));
    permLabel = Type(ind);
    for iCol = 1:nROI
        testmetric = Fldata(:,iCol);
        if covtype % like 'A' and 'H'
            testhc = testmetric(permLabel==unitype(2));
            testds = testmetric(permLabel==unitype(1));
        else
            testhc = testmetric(permLabel==unitype(1));
            testds = testmetric(permLabel==unitype(2));
        end
        meanhc = mean(testhc);
        meands = mean(testds);
        perm(n,iCol) = meanhc - meands;
        
    end
end

for iCol = 1:nROI
    vector = sort(perm(:,iCol),'descend');
    N      = length(vector);
    pos    = floor(permlevel*N)+1;
    if abs(meandiff(iCol))>abs(vector(pos))
        permmark(iCol)=1;
    end
end


    