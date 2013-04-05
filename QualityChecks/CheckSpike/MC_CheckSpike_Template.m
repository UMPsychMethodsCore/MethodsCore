%{
    Options has the following structure:

    struct Options {
            MasterDir - Directory path that contains subject directories
            Subjects  - a cell array of the subject folders
            SubRun    - possible directory below run directory
    };
%}

Options.MasterDir = '/oracle7/Researchers/heffjos/Mock_Data/fMRI/MYDATA/';

Options.Subjects = {
    'subject';
};

Options.SubRun = 'SubRun';

UMBatchDetectSpike(Options);