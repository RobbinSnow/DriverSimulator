function ArrayOut=String2Number(StringIn)
    testcaseString=StringIn;
    testcaseString=regexp(testcaseString,'{','split');%split{
    testcaseString= testcaseString{2};
    testcaseString=regexp(testcaseString,'}','split');%split}
    testcaseString= testcaseString{1};
    testcaseString= regexp(testcaseString,',','split');%split ,
    for j=1:length(testcaseString)
        subString=regexp(testcaseString(j),'-','split');
        CCC(2*j-1)=str2double(subString{1}{1});
        CCC(2*j)=str2double(subString{1}{2});
    end
    ArrayOut=CCC;
end
