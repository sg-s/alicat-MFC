% set MFC parameters from MFC connected to the serial port

function [m] = setMFCParameters(m,param,value)

s = dbstack;

% prevent crazy loops -- only execute when not called by getMFCParameters
if any(strcmp({s.name},'getMFCParameters'))
	return
end

if isnan(value)
	return
end

assert(value<20000,'Value too high: for safety, only values up to 20,000 are allowed')
assert(value>=0,'Value too low: must be positive')


disp('setMFCParameters called')

switch param
	case 'P'
		% P-gain register 21
		fprintf(m.fid,[m.name,'$$W21=',num2str(value)]);
		fscanf(m.fid);
	case 'D'
		% D-gain register 22
		fprintf(m.fid,[m.name,'$$W22=',num2str(value)]);
		fscanf(m.fid);
	case 'I'
		% I-gain register 23
		fprintf(m.fid,[m.name,'$$W23=',num2str(value)]);
		fscanf(m.fid);
end


