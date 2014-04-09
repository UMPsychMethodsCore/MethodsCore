/*-----------------
%
% Copyright Robert C. Welsh, Ann Arbor, MI, 2007
%
% An auxillary routine to speed up the calculation of the 
% correlation coefficient between two matrices.
%
% Rho = SOMPearsonEngin(theData,SelfOMap,mu_theData,mu_SelfOMap,Sigma_theData,sigma_SelfoMap)
%
%   theData        = theData(nSpace,nTime)
%   SelfOMap       = SelfOMap(nTime,nSOM)
%   mu_theData     = mean(theData,2)
%   mu_SelfOMap    = mean(SelfOMap,2)
%   sigma_theData  = std(theData,0,2)
%   sigma_SelfOMap = std(SelfOMap,0,1);
%
% All this does is calculate:
%
%   sum(
%
% To compile do:
%
%    mex [-DSOMDEBUG] [-DSOMDEBUG2] SOM_CostFunction.c
%
%  where -DSOMDEBUG[2] is a debug flag to the compiler.
%
%
%       -Robert Welsh, 2006-12-12.
%
%------------------*/

#include <math.h>
#include "mex.h"

/*// Define a ^2 function to use in Euclidean Distance to avoid using math routine "pow", it's too slow!*/
#define SQR(a) (a*a)

#define EPS 1e-10

/* 
   Results area - make it global so we can access it for multiple calls.
*/

static mxArray *resultsMX=NULL;
static double *timeSeries=NULL;

/* 
   Exit routine - need to use "clear SOM_PearsonEngin" to free up the memory.
*/

static void SOM_ExitPearson(void)
{

  mexPrintf("SOM_ExitPearson has been called.\n");
  if (resultsMX != NULL)
    {
      mexPrintf("Destroying persistent\n");
      mxDestroyArray(resultsMX);
    }
  if (timeSeries != NULL)
    {
      mexPrintf("Removing 'timeSeries'\n");
      mxFree(timeSeries);
      timeSeries = NULL;
    }
}

void SOM_PearsonEnginUsage()
{
  mexPrintf("\nUsage : \n\n");
  mexPrintf(" Rho = SOMPearsonEngin(theData,SelfOMap,mu_theData,mu_SelfOMap,Sigma_theData,sigma_SelfoMap)\n");
  mexPrintf("\n");
  mexPrintf("   theData        = theData(nSpace,nTime)\n");
  mexPrintf("   SelfOMap       = SelfOMap(nTime,nSOM)\n");
  mexPrintf("   mu_theData     = mean(theData,2)\n");
  mexPrintf("   mu_SelfOMap    = mean(SelfOMap,1)\n");
  mexPrintf("   sigma_theData  = std(theData,0,2)\n");
  mexPrintf("   sigma_SelfOMap = std(SelfOMap,0,1)\n\n");
}

/* 
   This is the main function that is called by MATLAB
   
*/

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

  mxArray *theDataMX;
  mxArray *SelfOMapMX;
  
  mxArray *mu_theDataMX;
  mxArray *mu_SelfOMapMX;
  
  mxArray *sigma_theDataMX;
  mxArray *sigma_SelfOMapMX;
  
  double *results;

  double *theData;
  double *SelfOMap;

  double *mu_theData;
  double *mu_SelfOMap;

  double *sigma_theData;
  double *sigma_SelfOMap;


  int nTime;
  int nTimeSOM;

  int nSOM;
  int nVoxels;

  int iSOM;
  int iTime;
  int iVoxel;

  double tmp1;
  
  int idx1;
  int idx2;

  /*// Now the function.*/

  /* Register the exit function */
  
  mexAtExit(SOM_ExitPearson);

  /*// Did they pass in enough arguements?*/  
  
  if (nrhs != 6)
    {
      SOM_PearsonEnginUsage();
      mexErrMsgTxt("Error, wrong number of input parameters.");
    }
  
  /*// Get the pointers to the data and self-organizing map.*/
  
  theDataMX        = prhs[0];
  SelfOMapMX       = prhs[1];
  mu_theDataMX     = prhs[2];
  mu_SelfOMapMX    = prhs[3];
  sigma_theDataMX  = prhs[4];
  sigma_SelfOMapMX = prhs[5];
  
  /*// Now get the dimensions of each.*/

  nVoxels = mxGetM(theDataMX);
  nTime   = mxGetN(theDataMX);

  nTimeSOM = mxGetM(SelfOMapMX);
  nSOM     = mxGetN(SelfOMapMX);

  theData   = mxGetPr(theDataMX);
  SelfOMap  = mxGetPr(SelfOMapMX);

  mu_theData   = mxGetPr(mu_theDataMX);
  mu_SelfOMap  = mxGetPr(mu_SelfOMapMX);

  sigma_theData   = mxGetPr(sigma_theDataMX);
  sigma_SelfOMap  = mxGetPr(sigma_SelfOMapMX);

  /*// Make sure the dimensions are good.*/
  if (nTime != nTimeSOM)
    {
      SOM_PearsonEnginUsage();
      mexPrintf("Error, time points in 'SelfOMap' and time points of 'theData' don't match!\n");
      mexErrMsgTxt("Aborting.");
    };

  if (nVoxels != mxGetM(mu_theDataMX) || mxGetN(mu_theDataMX) != 1)
    {
      SOM_PearsonEnginUsage();
      mexPrintf("Did you pass in mean(theData,2) ?\n");
      mexErrMsgTxt("Aborting.");
    };

  if (nVoxels != mxGetM(sigma_theDataMX) || mxGetN(sigma_theDataMX) != 1)
    {
      SOM_PearsonEnginUsage();
      mexPrintf("Did you pass in std(theData,0,2) ?\n");
      mexErrMsgTxt("Aborting.");
    };

  if (nSOM != mxGetN(mu_SelfOMapMX) || mxGetM(mu_SelfOMapMX) != 1)
    {
      SOM_PearsonEnginUsage();
      mexPrintf("Did you pass in mean(SelfOMap,1) ?\n");
      mexErrMsgTxt("Aborting.");
    };

  if (nSOM != mxGetN(sigma_SelfOMapMX) || mxGetM(sigma_SelfOMapMX) != 1)
    {
      SOM_PearsonEnginUsage();
      mexPrintf("Did you pass in std(SelfOMap,0,1) ?\n");
      mexErrMsgTxt("Aborting.");
    };

#if SOMDEBUG
  mexPrintf("theData(%d,%d), SelfOMap(%d,%d)\n",nVoxels,nTime,nTimeSOM,nSOM);
  mexPrintf("number of returns : %d\n",nlhs);
#endif
  
  /*// Results returned in a new matrix.*/

  if (resultsMX == NULL)
    {  
      mexPrintf("resultsMX is unknown\n");
      resultsMX = mxCreateDoubleMatrix(nVoxels,nSOM,mxREAL);
      mexMakeArrayPersistent(resultsMX);
      timeSeries = mxMalloc(sizeof(double)*nTime);
      mexMakeMemoryPersistent(timeSeries);
    }
  else
    {
      mexPrintf("resultsMX is known, %d\n",resultsMX);
      /* Check it's size */
      if (mxGetM(resultsMX) != nVoxels || mxGetN(resultsMX) != nSOM)
	{
	  mexPrintf("Must destroy persistent array and recreate.\n");
	  mxDestroyArray(resultsMX);
	  resultsMX = mxCreateDoubleMatrix(nVoxels,nSOM,mxREAL);
	  mexMakeArrayPersistent(resultsMX);
	  mxFree(timeSeries);
	  timeSeries = mxMalloc(sizeof(double)*nTime);
	  mexMakeMemoryPersistent(timeSeries);
	  mexPrintf("Recreated 'timeSeries' array\n");
	}
    }

  /*
    plhs[0] = mxCreateDoubleMatrix(nVoxels,nSOM,mxREAL);
  */

  plhs[0] = resultsMX;

#if SOMDEBUG
  mexPrintf("Created output array of size %d x %d\n",mxGetM(plhs[0]),mxGetN(plhs[0]));
#endif
  
  /*// get the pointer to the data area of the output array.*/
  
  results = mxGetPr(plhs[0]);
  
  /*// Now run the calculation.*/
  
  for (iVoxel = 0; iVoxel < nVoxels; iVoxel++)
    {
      /* Pull the time series for this voxel since we keep using it */
      for ( iTime = 0; iTime < nTime; iTime++)
	timeSeries[iTime] = theData[iVoxel+iTime*nVoxels];
      /* */
      for (iSOM = 0; iSOM < nSOM; iSOM++)
	{
	  idx1 = iSOM*nTime;
	  idx2 = nVoxels*iSOM;
	  tmp1 = 0;
	  for ( iTime = 0; iTime < nTime; iTime++)
	    {
#if SOMDEBUG2
	      mexPrintf("|%f - %f|^2\n",theData[iVoxel+iTime*nVoxels],SelfOMap[idx1+iTime]);
#endif
	      tmp1 += ( (timeSeries[iTime]-mu_theData[iVoxel])*
			(SelfOMap[idx1+iTime]-mu_SelfOMap[iSOM]) );
	      /*	      tmp1 += ( (theData[iVoxel+iTime*nVoxels]-mu_theData[iVoxel])*
			      (SelfOMap[idx1+iTime]-mu_SelfOMap[iSOM]) );*/
	    }
	  results[idx2+iVoxel] = tmp1/sigma_theData[iVoxel]/sigma_SelfOMap[iSOM]/(nTime-1);
#if SOMDEBUG2
	  mexPrintf("\n");
#endif
	}
    }
}


/*// All done.*/

