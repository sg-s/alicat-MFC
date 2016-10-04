function [] = readFrame(m)
tic
fprintf(m.fid,m.name); 
a = fscanf(m.fid);
disp(a)
t = toc;
disp(t*1000)