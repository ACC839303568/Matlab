function simpleGuiNormalized
% simpleGuiNormalized creates a GUI with just a static text box
% Format: simpleGuiNormalized or simpleGuiNormalized()
 
% Create the GUI but make it invisible for now while 
%  it is being initialized
f = figure('Visible', 'off','color','white','Units',...
  'Normalized', 'Position', [.25, .5, .35, .3]);
htext = uicontrol('Style','text','Units', 'Normalized', ...
  'Position', [.45, .2, .2, .1], ...
  'String','My First GUI string');
 
% Put a name on it and move to the center of the screen
set(f,'Name','Simple GUI Normalized')
movegui(f,'center')
 
% Now the GUI is made visible
set(f,'Visible','on');
end
