iRun = 1;

GreyPath = mc_GenPath(GreyMatterTemplate);
WhitePath = mc_GenPath(WhiteMatterTemplate);
CSFPath = mc_GenPath(CSFTemplate);
BrainPath = mc_GenPath(BrainMaskTemplate);

output.Template = OutputTemplate;
output.type = 1;
output.mode = 'makedir';

OutputPath = mc_GenPath(output);
ImagePath = mc_GenPath(ImageTemplate);
ImageFiles = spm_select('FPList',ImagePath, ['^' Pswra basefile '.*.' imagetype]);
SOM_Mask = fullfile(ImagePath,'som_mask.img');
RealignmentParametersFile = mc_GenPath(RealignmentParametersTemplate);

parameters.grey.File = GreyPath;
parameters.grey.MaskFLAG = MaskGrey;
parameters.grey.ImgThreshold = GreyThreshold;

parameters.white.File = WhitePath;
parameters.white.MaskFLAG = RegressWhite;

parameters.csf.File = CSFPath;
parameters.csf.MaskFLAG = RegressCSF;

parameters.epi.File = BrainPath;
if (isempty(BrainMaskTemplate))
    parameters.epi.MaskFLAG = 0;
else
    paramters.epi.MaskFLAG = 1;
end


parameters.data.run(iRun).P = ImageFiles;

RealignmentParameters = load(RealignmentParametersFile);
RealignmentParametersDeriv = diff(RealignmentParameters);
RealignmentParametersDerivR = resample(RealignmentParametersDeriv,size(RealignmentParameters,1),size(RealignmentParametersDeriv,1));

parameters.data.run(iRun).MotionParameters = [RealignmentParameters RealignmentParametersDerivR];
parameters.data.run(iRun).nTIME = NumScan(iRun);
parameters.data.MaskFLAG = MaskBrain;

parameters.RegressFLAGS.prinComp = PrincipalComponents;
parameters.RegressFLAGS.global = RegressGlobal;
parameters.RegressFLAGS.csf = RegressCSF;
parameters.RegressFLAGS.white = RegressWhite;
parameters.RegressFLAGS.motion = RegressMotion;
parameters.RegressFLAGS.order = ProcessOrder;

parameters.TIME.run(iRun).TR = TR;
parameters.TIME.run(iRun).BandFLAG = DoBandpassFilter;
parameters.TIME.run(iRun).TrendFLAG = DoLinearDetrend;
parameters.TIME.run(iRun).LowF = LowFrequency;
parameters.TIME.run(iRun).HiF = HighFrequency;
parameters.TIME.run(iRun).gentle = Gentle;
parameters.TIME.run(iRun).padding = Padding;
parameters.TIME.run(iRun).whichFilter = BandpassFilter;
parameters.TIME.run(iRun).fraction = Fraction;

parameters.rois.files = '';

%-OR-

parameters.rois.mni.coordinates = [0 0 0;20 20 20];
XYZ = SOM_MakeSphereROI(ROISize);
parameters.rois.mni.size.XROI = XYZ(1,:);
parameters.rois.mni.size.YROI = XYZ(2,:);
parameters.rois.mni.size.ZROI = XYZ(3,:);



if (isempty(BrainMaskTemplate))
    parameters.rois.mask.File = SOM_Mask;
else
    parameters.rois.mask.File = BrainPath;
end
parameters.rois.mask.MaskFLAG = MaskBrain;

parameters.Output.correlation = 'images'; %or maps
parameters.Output.correlation = 'maps';
parameters.Output.description = 'description of output';
parameters.Output.directory = OutputPath;
parameters.Output.name = 'result file name';



global SOM;
SOM.silent = 1;
SOM_LOG('STATUS : 01');






[D0 parameters] = SOM_PreProcessData(parameters);
%if D0 == -1
%    SOM_LOG('FATAL ERROR : No data returned');
%else
%    results = SOM_CalculateCorrelations(D0,parameters);
%    if isnumeric(results)
%        SOM_LOG('FATAL ERROR : ');
%    end
%end

