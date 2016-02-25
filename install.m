if ismac()
    error('not support');
elseif ispc()
    loadlibrary('uc480_64.dll', 'minimaluc480.h', 'mfilename', 'minprototype_matgen.m');
    unloadlibrary('uc480_64');
else
    loadlibrary('/usr/lib/libueye_api.so', 'minimaluc480.h', 'mfilename', 'minprototype_matgen.m');
    unloadlibrary('libueye_api');
end

fin = fopen('minprototype_matgen.m', 'r');
fout = fopen('minprototype.m', 'w');

line = fgetl(fin);
while ischar(line)
    fwrite(fout, strrep(line, '''cstring''', '''int8Ptr'''));
    fprintf(fout, '\n');
    line = fgetl(fin);
end
fclose(fin);
fclose(fout);
