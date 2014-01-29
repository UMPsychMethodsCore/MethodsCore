
2013-04-01

This is the validation data set for testing spm8Batch. To test you should

You will need to unpack the validation dataset

1) Copy the file MethodsCore/spm8Batch/Validation/999994xx_validation.tar.gz to a working directory

2) cd into that directory and gunzip the file with

   gunzip 999994xx_validation.tar.gz

3) Then untar the file with:

   tar -xvf 999994xx_validation.tar

4) Then copy the stream job with

   cp ...../MethodsCore/spm8Batch/Validation/stream_999994xx_validation.sh ./

5) Finally execute the job with:

   nohup ./stream_999994xx_validation.sh &> stream_999994xx_validation.log &

It will take 15-20 minutes, or longer if you have a slower machine, to finish.
After it finished examine the log files for error.
