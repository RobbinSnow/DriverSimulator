function [BitDef]=mydoublebit(BitDef, PortName, io)

mydisplay='';
if io==0
  for i=1:length(PortName)
    mydisplay=[mydisplay,'port_label(''input'',',num2str(i),','' ',char(PortName(i)),''');'];
  end         
end
if io==1
  for i=1:length(PortName)
    mydisplay=[mydisplay,'port_label(''output'',',num2str(i),',''',char(PortName(i)),' '');'];
  end         
end
set_param(gcb,'MaskDisplay',mydisplay);

if ~isa(BitDef,'cell')
  error('Bit Pattern parameter must be a cell array');
end
if size(BitDef,1)>1
  error('Bit Pattern parameter must be a row-vector cell array');
end

index=1;
if io==0
  used=zeros(1,64);
end
for i=1:length(BitDef)
  bitpattern=round(BitDef{i});
  tmp=bitpattern;
  tmp(find(tmp==-1))=[];
  if sum(tmp<0) | sum(tmp>63)
    error('Bit specifiers must be in the range 0..63');
  end
  if io==0
    if sum(used(tmp+1))
      error('Bits already assigned');
    else
      used(tmp+1)=ones(1,length(tmp));
    end
  end  
  output(index) = length(bitpattern);
  output(index+1:index+1+length(bitpattern)-1) = bitpattern;
  index = index+2+length(bitpattern)-1;
end
BitDef=output;

  


  

    
    
  
  
  

      

         

            
               
      
   
      
   

         
         
         

         
   



