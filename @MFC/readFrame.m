function [pressure,temperature,flow_rate] = readFrame(m)

pressure = NaN;
temperature = NaN;
flow_rate = NaN;

fprintf(m.fid,m.name); 
a = fscanf(m.fid);

a = strsplit(a,' ');
try
	pressure = str2double(a{2});
	temperature = str2double(a{3});
	flow_rate = str2double(a{5});
catch
	disp(a)
end