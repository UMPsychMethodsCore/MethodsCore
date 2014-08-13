function out = mc_svmCV(Opt,trainPrune,trainlabels,testPrune,testlabels);
if Opt.advancedkernel==1
    error('Advanced kernel mode is not currently supported in the MC release');
    if Opt.kernelsearchmode==1
        searchgrid=mc_svm_define_searchgrid(Opt.gridstruct);
    end
    
    out.result=mc_svm_gridsearch(train,trainlabels,test,testlabels,kernel,searchgrid,svmlib);
    out.models_test=vertcat(searchgrid,result);
    
end

if advancedkernel==0
    switch  svmlib

      case 1

        out.modelTrain=svmlearn(train,trainlabels,'-o 100 -x 0');

        out.modelTest=svmclassify(test,testlabels,models_train{iL,iContrast});


      case 2
        svm_light_c = 1/mean(sum(train.*train,2),1);

        out.modelTrain=svmtrain(trainlabels,train,['-s 0 -t 0 -c ' num2str(svm_light_c)]);

        [model.pred_lab, model.acc, model.dec_val] = svmpredict(testlabels,test,models_train{iL});

        out.modelTest=1-model.acc(1)/100;
        
    end
end



