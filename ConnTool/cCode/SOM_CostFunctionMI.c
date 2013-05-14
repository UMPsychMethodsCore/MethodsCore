/*-----------------
%
% Copyright Robert C. Welsh, Ann Arbor, MI, 2006
%
% A routine to calculate the Mutual Information Cost Metric
% between U and V, where U are data (nVoxels,nTime) and 
% V is SOM Exemplars (nTime,nVoxels);
%
% results = SOM_CostFunctionMI(theData,SelfOMap);
%
%  Input:
%
%    theData   = theData(nVoxels,nTime)
%    SelfOMap  = SelfOMap(nTime,nSOM);
%
%    This will explicitly calculate the Mutual Information
%    as the cost function.
%
%  Output:
%  
%   results = results(nVoxels,nSOM) -> Cost Function.
%
% To compile do:
%
%    mex [-DSOMDEBUG] [-DSOMDEBUG2] SOM_CostFunctionMI.c
%
%  where -DSOMDEBUG[2] is a debug flag to the compiler.
%
%
%       -Robert Welsh, 2006-12-12.
%
%------------------*/

#include <math.h>
#include "mex.h"


#define EPS 1e-10

/* 
   Results area - make it global so we can access it for multiple calls.
*/

static mxArray *resultsMX=NULL;

static int nPntsSaved=0;

/*static mxArray *theDataTMX=NULL;*/

  /* Dynamically create the histograms: joint, x, and y */

static double *JH=NULL, *HX=NULL, *HY=NULL;

/* 
   Exit routine - need to use "clear SOM_CostFunction" to free up the memory.
*/

static void SOM_ExitCost(void)
{

  mexPrintf("SOM_ExitCost has been called.\n");
  if (resultsMX != NULL)
    {
      mexPrintf("Destroying persistent\n");
      mxDestroyArray(resultsMX);
      resultsMX = NULL;
    }
  /*  
      if (theDataTMX != NULL)
    {
      mexPrintf("Destroying persistent 'theDataTMX'\n");
      mxDestroyArray(theDataTMX);
      theDataTMX = NULL;
      }
*/
  if ( JH != NULL )
    {
      mexPrintf("Destroying persistent 'JH'\n");
      mxFree(JH);
      JH=NULL;
    }
  if ( HX != NULL )
    {
      mexPrintf("Destroying persistent 'HX'\n");
      mxFree(HX);
      HX=NULL;
    }
  if ( HY != NULL )
    {
      mexPrintf("Destroying persistent 'HY'\n");
      mxFree(HY);
      HY=NULL;
    }
}

/*

  Routine to calculate the Mutual Inforation Cost Function.
  Based loosely on some code from Luis Hernandez.

  *** WARNING *** Mutual Information calculation is really slow!!!

*/

double SOM_MutualInformation(double data[], double som[], int npnts)
{

  int iPnt;

  double minx, maxx, deltax, miny, maxy, deltay;

  int nx, nxx;

  int iX, iY;

  double MI;

  double histIncr;

  /* Make sure we have enough data points to histogram */
  
  if (npnts < 2)
    {
      mexPrintf("The number of times points < 2, silly.\n");
      mexErrMsgTxt("Aborting.");
    };

  /* Ok, determine limits of histograms for calculating entropy */

  minx = 1e9;
  miny = 1e9;
  maxx = -1e9;
  maxy = -1e9;
  
  /* Find the limits of the histograms. */

  for (iPnt = 0;iPnt < npnts;iPnt++)
    {
      minx = ( (minx<data[iPnt]) ? minx : data[iPnt] );
      miny = ( (miny<som[iPnt])  ? miny : som[iPnt]  );
      maxx = ( (maxy>data[iPnt]) ? maxx : data[iPnt] );
      maxy = ( (maxx>som[iPnt])  ? maxy : som[iPnt]  );
    }

#if SOMDEBUG3
  mexPrintf("%f %f %f %f\n",minx,maxx,miny,maxy);
#endif

  /* Determine number of elements in each histogram direction */
      
  nx = (int) ( pow( (float)npnts , (float)(1./3.) ) + .5);

  deltax = (maxx-minx)/(nx-1);
  deltay = (maxy-miny)/(nx-1);

  /* now add a bin for underflows and overflows */

  nxx = nx + 2;

  if ( nx < 2 ) 
    {
      mexPrintf("\nSOM_CostFunction.c:\n  Histogram size needs to be at least 2x2\n\n");
      mexErrMsgTxt("Aborting.");
    }


  /* If previously created can be reuse? */

  if ( nPntsSaved != npnts )
    {
      if ( JH != NULL) mxFree(JH);
      if ( HX != NULL) mxFree(HX);
      if ( HY != NULL) mxFree(HY);
      JH = NULL;
      HX = NULL;
      HY = NULL;
    }

  /* Request memory from matlab heap for histograms */
  
  if ( JH == NULL)
    {  
      JH = mxCalloc((nxx*nxx),sizeof(double));
      mexMakeMemoryPersistent(JH);
    }
  if ( HX == NULL )
    {
      HX = mxCalloc(nxx,sizeof(double));
      mexMakeMemoryPersistent(HX);
    }
  if ( HY == NULL )
    {
      HY = mxCalloc(nxx,sizeof(double));
      mexMakeMemoryPersistent(HY);
    }

  /* Accumulate the histograms, use the following
     for the histogram increment, that way it will be 
     unit normalized already */

  histIncr = (double) (1.0/( (double) npnts));

  for (iPnt = 0; iPnt < npnts; iPnt ++)
    {
      /* Calculate index and min and max it.*/

      iX = (int) ((data[iPnt]-minx)/deltax + 1.5);
      iY = (int) ((som[iPnt]-miny)/deltay + 1.5);

#if SOMDEBUG4
      mexPrintf("%+f:%d \t %+f:%d\n",data[iPnt],iX,som[iPnt],iY);
#endif

      iX = (iX < 0) ? 0 :  iX;
      iY = (iY < 0) ? 0 :  iY;

      iX = (iX > nx+1) ? nx+1 : iX;
      iY = (iY > nx+1) ? nx+1 : iY;

      HX[iX]       += histIncr;
      HY[iY]       += histIncr;
      JH[iX*nxx+iY] += histIncr;
    }

#if SOMDEBUG2
  for (iX = 0; iX <= nx+1; iX ++)
    {
      for (iY = 0; iY <= nx+1 ; iY++)
	mexPrintf("%f ",JH[iX*nxx+iY]);
      mexPrintf("\n");
    }
  mexPrintf("\n");
#endif

  /* Now calculate the entropy, include overflow and underflow bins */

  MI = 0;
  
  for (iX = 0; iX < nxx; iX ++)
    for (iY = 0; iY <  nxx ; iY++)
      if ( HX[iX] > 0 && HY[iY] > 0 )
	{
#if SOMDEBUG2
	  mexPrintf("%f %f %f %d %d\n",JH[iX*nxx+iY],HX[iX],HY[iY],iX,iY);
#endif
	  MI += JH[iX*nxx+iY]*log( ( (JH[iX*nxx+iY]+EPS)/HX[iX]/HY[iY] ) );
	}
  
#if SOMDEBUG2
  mexPrintf("min/max : %f %f %f\n",minx,maxx,deltax);
  mexPrintf("min/max : %f %f %f\n",miny,maxy,deltay);
  mexPrintf("\n");
#endif

  /* Free up the memory */

  /*  mxFree(JH);
  mxFree(HX);
  mxFree(HY);
  */
#if SOMDEBUG2
  mexPrintf("MI : %f\n",MI);
#endif

  return MI;

}

void SOM_CostFunctionUsage()
{
  mexPrintf("\nUsage : results = SOM_CostFunctionMI(theData,SelfOMap)\n\n");
  mexPrintf("         theData   -> theData(nVoxels,nTime)\n");
  mexPrintf("         SelfOMap  -> theData(nTime,nSOM)\n");
}

/* 
   This is the main function that is called by MATLAB
   
   The routine will return a matrix of the cost-function evaluation.
   
   All of the cost functions are contained in here, except mutual information
   which is lengthy code-wise and hence is above.

*/

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

  mxArray *theDataTMX;
  mxArray *theDataMX;
  mxArray *SelfOMapMX;
  
  double *results;

  double *theData;
  double *SelfOMap;

  double *theDataT;     /* Needed for mutual information */

  int nTime;
  int nTimeSOM;

  int nSOM;
  int nVoxels;

  int iSOM;
  int iTime;
  int iVoxel;

  int i1;

  int iPnt;
  int COSTFLAG;

  double tmp1;
  double tmp2;
  
  int idx1;
  int idx2;

  /*// Now the function.*/

  /* Register the exit function */
  
  mexAtExit(SOM_ExitCost);

  /*// Did they pass in enough arguements?*/

  if (nrhs != 2)
    {
      SOM_CostFunctionUsage();
      mexErrMsgTxt("Error, wrong number of input parameters.");
    }

  /*// Get the pointers to the data and self-organizing map.*/

  theDataMX  = prhs[0];
  SelfOMapMX = prhs[1];
  
  /*// Now get the dimensions of each.*/

  nVoxels = mxGetM(theDataMX);
  nTime   = mxGetN(theDataMX);

  nTimeSOM = mxGetM(SelfOMapMX);
  nSOM     = mxGetN(SelfOMapMX);

  theData   = mxGetPr(theDataMX);

  SelfOMap = mxGetPr(SelfOMapMX);

  /*// Make sure the dimensions are good.*/
  if (nTime != nTimeSOM)
    {
      SOM_CostFunctionUsage();
      mexPrintf("Error, time points in 'SelfOMap' and time points of 'theData' don't match!\n");
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
      resultsMX  = mxCreateDoubleMatrix(nVoxels,nSOM,mxREAL);
      mexMakeArrayPersistent(resultsMX);
      mexPrintf("Created persistent resultsMX array.\n");
    }
  else
    {
      /* Check it's size */
      if (mxGetM(resultsMX) != nVoxels || mxGetN(resultsMX) != nSOM)
	{
	  mexPrintf("resultsMX is known, %d\n",resultsMX);
	  mexPrintf("but, wrong size and must destroy persistent array and recreate.\n");
	  mxDestroyArray(resultsMX);
	  resultsMX  = mxCreateDoubleMatrix(nVoxels,nSOM,mxREAL);
	  mexMakeArrayPersistent(resultsMX);
	}
    }

  plhs[0] = resultsMX;
  
#if SOMDEBUG
  mexPrintf("Created output array of size %d x %d\n",mxGetM(plhs[0]),mxGetN(plhs[0]));
#endif
  
  /*// get the pointer to the data area of the output array.*/
  
  results = mxGetPr(plhs[0]);
  
  /*// Now run the cost function.*/
  
  /* 
     Mutual Information.
  */
#if SOMDEBUG
  mexPrintf("M.I.\n");
#endif
  /* Transpose the data matrix to be able to index it via c like indexing.*/
  
  /* Does the transpose area already exist, if so the right size. If so just use
     the allocated space. This helps memory management.*/
  
  /*  if (theDataTMX == NULL)
    {
      mexPrintf("theDataTMX is unknown\n");
      theDataTMX = mxCreateDoubleMatrix(nTime,nVoxels,mxREAL);
      mexMakeArrayPersistent(theDataTMX);
      mexPrintf("Created persistent theDataTMX(%d,%d) array.\n",mxGetM(theDataTMX),mxGetN(theDataTMX));
    }
  else
    {
      if ( mxGetM(theDataTMX) != mxGetN(theDataMX) || mxGetN(theDataTMX) != mxGetM(theDataMX) )
	{
	  mexPrintf("theDataTMX (%d,%d) ~= (%d,%d)' is known, but needs redefinition: %d\n",
		    mxGetM(theDataTMX),
		    mxGetN(theDataTMX),
		    mxGetM(theDataMX),
		    mxGetN(theDataMX),
		    theDataTMX);
	  mxDestroyArray(theDataTMX);
	  mexPrintf("Destroyed.\n");
	  theDataTMX = mxCreateDoubleMatrix(nTime,nVoxels,mxREAL);
	  mexPrintf("Created.\n");
	  mexMakeArrayPersistent(theDataTMX);
	  mexPrintf("Made persistent.\n");
	}
    }
  
  */
  /* Now transpose it so we can look up time-series data for calculation of M.I. between
     data and SOM */

  theDataTMX = mxCreateDoubleMatrix(nTime,nVoxels,mxREAL);
  /*mexPrintf("Created theDataTMX(%d,%d) array.\n",mxGetM(theDataTMX),mxGetN(theDataTMX));*/

  mexCallMATLAB(1,&theDataTMX,1,&theDataMX,"'");
  
#if SOMDEBUG
  mexPrintf("Transposed with result of (%d,%d)\n",mxGetM(theDataTMX),mxGetN(theDataTMX));
#endif
  theDataT = mxGetPr(theDataTMX);
  for (iVoxel = 0; iVoxel < nVoxels; iVoxel++)
    {
      for (iSOM = 0; iSOM < nSOM; iSOM++)
	{
	  results[nVoxels*iSOM+iVoxel] = SOM_MutualInformation(&theDataT[iVoxel*nTime],&SelfOMap[iSOM*nTime],nTime);
	  
#if SOMDEBUG2
	  mexPrintf("\n");
#endif
	  
	}
    }
#if SOMDEBUG
  mexPrintf("Finished calculation theDataTMX(%d,%d)\n",mxGetM(theDataTMX),mxGetN(theDataTMX));
#endif
  /*
    mexPrintf("Destroying persistent 'theDataTMX'\n");
    mxDestroyArray(theDataTMX);
  */
  theDataTMX = NULL;

  /*
  if ( JH != NULL )
    {
      mexPrintf("Destroying persistent 'JH'\n");
      mxFree(JH);
      JH=NULL;
    }
  if ( HX != NULL )
    {
      mexPrintf("Destroying persistent 'HX'\n");
      mxFree(HX);
      HX=NULL;
    }
  if ( HY != NULL )
    {
      mexPrintf("Destroying persistent 'HY'\n");
      mxFree(HY);
      HY=NULL;
    }
  */
}


/*// All done.*/

