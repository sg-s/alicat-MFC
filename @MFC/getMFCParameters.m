% get MFC parameters from MFC connected to the serial port

function [m] = getMFCParameters(m)


% P-gain register 21

registers = [21 22 23];
parameters = {'P','D','I'};

for i = length(registers):-1:1
	probe = [m.name, '$$R' mat2str(registers(i))];
	fprintf(m.fid,probe);
	raw_m = fscanf(m.fid);
	m.(parameters{i}) = reg2num(raw_m);
end
