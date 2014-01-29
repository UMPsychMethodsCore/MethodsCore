function out = mc_svmbatchCheckHost()
goodlist={
    'psyche.psych.med.umich.edu';'freewill';
         };

[d,curhost]=system('hostname');

if ~any(strcmpi(strtrim(curhost),goodlist));
    error('You are not running svm on an approved host!');
end
