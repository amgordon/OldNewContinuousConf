d = dir('f*');

for i=1:length(d)
    thisFile = d(i).name;
    
    ixSuffix = strfind(thisFile, '.wav');
    ix_ = strfind(thisFile, '_');
    
    ixNum = (ix_+1):(ixSuffix-1);
    
    thisNum = thisFile(ixNum);
    
    newFile = ['f_' prepend(thisNum,3), '.wav'];
    
    if ~strcmp(thisFile, newFile)
        movefile(thisFile, newFile);
    end
end

missing = [164 220 232];