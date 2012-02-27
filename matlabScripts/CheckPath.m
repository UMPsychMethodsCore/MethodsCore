function CheckPath(InputPath, HelpMessage)

if exist (InputPath)
    return
else
    display (sprintf('Sorry friend, I was looking for this: %s. Turns out it was not there.',InputPath))
    if exist('HelpMessage')
    display (sprintf('I recommend trying this: %s',HelpMessage))
    end
    display('Terminating the script now.')
    error('');
end
    