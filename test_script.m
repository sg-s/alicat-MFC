% test script, used for development

cd('c:\')
try
	rmdir('c:\code\alicat-mfc\','s')
catch
end
copyfile('\\tsclient\alicat-mfc\','c:\code\alicat-mfc\')
cd('c:\code\alicat-mfc\')

clear all
close all
rehash

m = MFC;