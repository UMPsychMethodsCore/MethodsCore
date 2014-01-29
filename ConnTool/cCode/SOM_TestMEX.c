/*-----------------
%
% Copyright Robert C. Welsh, Ann Arbor, MI, 2006
%
% A routine to calculate the cost metrix
% between U and V where U are data (nVoxels,nTime) and 
% V is SOM Exemplars (nTime,nVoxels);
%
% results = SOM_CostFunction(theData,SelfOMap,[whichCOST]);
%
%  Input:
%
%    theData   = theData(nVoxels,nTime)
%    SelfOMap  = SelfOMap(nTime,nSOM);
%
%  Optional: 
%
%    whichCOST = 0 -  U.V  (opening angle) (default)
%                1 - |U-V| (normalized euclidean distance).
%                2 - |U-V|^2 
%                3 - Mutual Information
%  Output:
%  
%   results = results(nVoxels,nSOM) -> Cost Function.
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
   Exit routine to be called with the routine is cleared.
*/

static void SOM_ExitCost(void)
{
  mexPrintf("Called exit routine : 'SOM_ExitCost'\n");
}

/*

  Routine to calculate the Mutual Inforation Cost Function.
  Based loosely on some code from Luis Hernandez.

  *** WARNING *** Mutual Information calculation is really slow!!!

*/

float SOM_MutualInformation(double data[], double som[], int npnts)
{

  int iPnt;

  double minx, maxx, deltax, miny, maxy, deltay;

  int nx, nxx;

  int iX, iY;

  double MI;

  /* Dynamically create the histograms: joint, x, and y */

  double *JH, *HX, *HY;

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

  /* Request memory from matlab heap for histograms */
  
  JH = mxCalloc((nxx*nxx),sizeof(double));
  HX = mxCalloc(nxx,sizeof(double));
  HY = mxCalloc(nxx,sizeof(double));

  /* Accumulate the histograms, use the following
     for the histogram increment, that way it will be 
     unit normalized already */

  histIncr = (double) (1.0/( (double) npnts));

  for (iPnt = 0; iPnt < npnts; iPnt ++)
    {
      /* Calculate index and min and max it.*/

      iX = (int) ((data[iPnt]-minx)/deltax + 1.5);
      iY = (int) ((som[iPnt]-miny)/deltay + 1.5);

#if SOMDEBUG2
      mexPrintf("%d %d\n",iX,iY);
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
  
#if SOMDEBUG
  mexPrintf("min/max : %f %f %f\n",minx,maxx,deltax);
  mexPrintf("min/max : %f %f %f\n",miny,maxy,deltay);
  mexPrintf("\n");
#endif

  /* Free up the memory */

  mxFree(JH);
  mxFree(HX);
  mxFree(HY);

#if SOMDEBUG
  mexPrintf("MI : %f\n",MI);
#endif

  return MI;

}

void SOM_CostFunctionUsage()
{
  mexPrintf("\nUsage : results = SOM_CostFunction(theData,SelfOMap,whichCOST)\n\n");
  mexPrintf("         theData   -> theData(nVoxels,nTime)\n");
  mexPrintf("         SelfOMap  -> theData(nTime,nSOM)\n");
  mexPrintf("         whichCOST -> 0=U.V, 1=|U-V|, 2=|U-V|^2, 3=Mutual Information\n\n");
}

/* 
   This is the main function that is called by MATLAB
   
   The routine will return a matrix of the cost-function evaluation.
   
   All of the cost functions are contained in here, except mutual information
   which is lengthy code-wise and hence is above.

*/

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{

  mxArray *theDataMX;
  mxArray *SelfOMapMX;
  
  mxArray *theDataTMX;   /* Needed for mutual information calculation.*/

  mxArray *tmpMX[2];
  
  mxArray *whichCOSTMX;

  mxArray *resultstMX;
  double *resultst;

  double *whichCOST;

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

  /*// Did they pass in enough arguements?*/

  COSTFLAG = 1;
  
  mexAtExit(SOM_ExitCost);

  if (nrhs < 2 | nrhs > 3)
    {
      SOM_CostFunctionUsage();
      mexErrMsgTxt("Error, wrong number of input parameters.");
    }

  /*// get the cost function option. 0 = U.V, 1 = |U-V|*/
  
  if (nrhs == 3)
    {
      whichCOSTMX = prhs[2];
      if (mxGetM(whichCOSTMX) != 1 | mxGetN(whichCOSTMX) != 1)
	{
	  SOM_CostFunctionUsage();
	  mexErrMsgTxt("Error, 'whichCOST' must be a scaler.");
	}
      whichCOST = mxGetPr(whichCOSTMX);
      switch ((int) whichCOST[0])
	{
	case 3:
	  {
#if SOMDEBUG
	    mexPrintf("Using mutual information cost function.\n");
#endif
	    COSTFLAG=3;
	  }
	  break;
	case 2:
	  {
#if SOMDEBUG
	    mexPrintf("Using |U-V|^2 cost function.\n");
#endif
	    COSTFLAG=2;
	  }
	  break;
	case 1:
	  {
#if SOMDEBUG
	    mexPrintf("Using |U-V| cost function.\n");
#endif
	    COSTFLAG=1;
	  }
	  break;
	default:
	  {
#if SOMDEBUG
	    mexPrintf("Using U.V cost function.\n");	
#endif
	    COSTFLAG=0;
	  }
	  break;
	}
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

  /*
  plhs[0] = mxCreateDoubleMatrix(nVoxels,nSOM,mxREAL);
  */
#if SOMDEBUG
  /*  mexPrintf("Created output array of size %d x %d\n",mxGetM(plhs[0]),mxGetN(plhs[0]));
*/
#endif
  
  /*// get the pointer to the data area of the output array.*/
  
  /*  results = mxGetPr(plhs[0]);
   */
  /*// Now run the cost function.*/

#if SOMDEBUG
  mexPrintf("COSTFLAG:%d\n",COSTFLAG);
#endif
}


/*// All done.*/

