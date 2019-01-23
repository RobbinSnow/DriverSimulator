function blkStruct = slblocks  
 
%SLBLOCKS Defines a block library.  
 
% Library's name. The name appears in the Library Browser's  
% contents pane.  
 
blkStruct.Name = 'DS S-Function';  
 
% The function that will be called when the user double-clicks on  
% the library's name. ;  
 
blkStruct.OpenFcn = 'Solver_DS_SF';  
 
% blkStruct.MaskDisplay = '';  

% End of blocks
