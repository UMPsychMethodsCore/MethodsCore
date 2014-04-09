function [physData physOK] = convertGEPhysio( respFILE, cardFILE, sampRate)
%function physdata = convertEXphysio( rootname, sampRate)
%
% rootname should typically be .... run1_ , run2_ ...etc
% the names of the files will then be expected to be
% run1_trigECG.dat and run1_resp.dat
%
% sampRate is in SECONDS!
%
% the function returns a matrix with four columns:
% [ time_vector resp_vector card_vector ones_vector]
%

physOK = -1;

fprintf('Reading physio data from scanner (GE)');

resp = load(respFILE);
fprintf('.');
card = zeros(size(resp));
cardtimes = load(cardFILE);
fprintf('.');
card(cardtimes(find(cardtimes))) = 1;

if length(card)~=length(resp)
	fprintf('\nWarning: length of card: %d ... length of resp: %d',length(card), length(resp));
	fprintf('\n I Forced it to match !!');
	card = card(1:length(resp));
end
 
fprintf('\n');

time = ([1:length(resp)]-1) * sampRate;
physData = [time' resp card ones(size(resp))];

%save physio.dat physdata -ascii

physOK = 1;
return
