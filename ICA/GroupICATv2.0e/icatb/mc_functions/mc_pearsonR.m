function r = mc_pearsonR(x, y)
% This function calculates the pearson r value of 2 given 1d vector x and y. 
% x and y are both 1xn or nx1 vectors
% The output is a single value r

r = sum((x-mean(x)).*(y-mean(y)))/sqrt(sum((x-mean(x)).^2)*sum((y-mean(y)).^2));