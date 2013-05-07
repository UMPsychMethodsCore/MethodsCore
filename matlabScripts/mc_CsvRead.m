function M = mc_CsvRead(fileName, delimiter)
% MC_CSVREAD Read a file in MethodsCore format.
%   M = MC_CSVREAD('FILENAME') reads the MethodCore formatted file FILNAME.
%   In a MethodsCore formmated file, lines beginning with '#' are ignored
%   throught the whole file.  Any other lines are assumed to be a comma 
%   separated file which conatains only numeric values.
%
%   M = MC_CSVREAD('FILENAME', 'DELIMITER') does the same as above except
%   uses the non-numeric delimter to delimit between numeric values instead 
%   of assuming a comma as a delimiter.
%
%
    assumedDelimiters = sprintf(' \t\b');
    if exist('delimiter','var') == 1
        if ischar(delimiter) == 0
            mc_Error(['MC_CSVREAD ERROR\n'...
                      'Expected type ''char'' for variable delimiter.\n%s'], '');
        end

        delimiter = sprintf(delimiter);
        if validDelimiter(delimiter) == 0
            mc_Error(['MC_CSVREAD ERROR\n'...
                      'Invalid delimiter: expected a nonnumeric value of length 1.\n%s'], '');
        end
        delimiter = strcat(assumedDelimiters,delimiter);
    else
        delimiter = strcat(assumedDelimiters,',');
    end

    fid = fopen(fileName, 'r');
    if fid == -1
        mc_Error(['MC_CSVREAD ERROR\n'...
                  'Invalid file: %s\n'], fileName);
    end

    M = [];
    line = fgetl(fid);
    lineNum = 1;
    while ischar(line) == 1
        line = strtrim(line);
        if length(line) > 0 && line(1) ~= '#'
            tmpRow = parseLine(line, delimiter);
            if isempty(tmpRow)
                mc_Error(['MC_CSVREAD ERROR\n'...
                          'Invalid line: %d'], lineNum);
            end

            if isempty(M) == 0 && length(tmpRow) ~= size(M, 2)
                mc_Error(['MC_CSVREAD ERROR\n'...
                          'Error line: %d. All rows must have equal number of values.\n'], lineNum);
            end
 
            M = [M; tmpRow];
        end
        
        line = fgetl(fid);
        lineNum = lineNum + 1;
    end
end

function isValid = validDelimiter(delimiter)
    isValid = 0;

    s = regexp(delimiter,'[0-9]\n');
    if length(delimiter) == 1 && isempty(s) == 1
        isValid = 1;
    end
end

function values = parseLine(line, delimiter)
    values = [];
    line = lower(line);
    
    while isempty(line) == 0
        [substr line] = strtok(line, delimiter);
        substrValue = str2double(substr);
        if isnan(substrValue) && strcmp(substrValue, 'nan') == 0
            values = [];
            return;
        end
        values = [values substrValue];
    end
end

