function options = wfu_set_function_options(options, defaultOptions )
% PURPOSE: Sets the options of a function from a subset of options and the 
%          default options. The function may contain nested option
%          structures.
%
% CATEGORY:Utility
%
% INPUTS:
%
%    subsetOptions - Structure of options for the function but only a subset is defined.
%
%    defaultOptions - Complete list of function options with defaults.
%
%
% OUTPUTS: 
%
%    options - Complete structure of function options
%
% EXAMPLE:
%
%
%
%==========================================================================
% C H A N G E   L O G
% 
%--------------------------------------------------------------------------

%
% All options known ...
%

defaultOptionsFieldNames = fieldnames(defaultOptions);

if isstruct(options)
    optionsFieldNames  = fieldnames(options);
else
    optionsFieldNames = [];
end

for ii=1:length(defaultOptionsFieldNames),

    if eval(sprintf( 'isstruct(defaultOptions.%s)', defaultOptionsFieldNames{ii})) & ...
            length(optionsFieldNames ) > 0
    
        for jj = 1:length(optionsFieldNames)
            
            %
            % Check to see if Substructure in Option is contained in Default Option. 
            %
            
            if strcmp(optionsFieldNames{jj}, defaultOptionsFieldNames{ii})

                %
                % Call recursively to handle options with sub structures
                %

                eval( sprintf('options.%s = wfu_set_function_options( options.%s, defaultOptions.%s);', ...
                optionsFieldNames{jj}, optionsFieldNames{jj},defaultOptionsFieldNames{ii} ));
            else
           
                %
                % Check to see if options is missing a field contained in
                % Default Options. If option is missing a default option
                % add default option to option stucture by copy 
                %
                
                if ~isfield(options,defaultOptionsFieldNames{ii}),
                   options = setfield(options,defaultOptionsFieldNames{ii}, ...
                      getfield(defaultOptions,defaultOptionsFieldNames{ii}));
            	end;
            end        
        end
        
    else    
    	if ~isfield(options,defaultOptionsFieldNames{ii}),
               options = setfield(options,defaultOptionsFieldNames{ii}, ...
                  getfield(defaultOptions,defaultOptionsFieldNames{ii}));
    	end;
    end;
end;
    
