% get MFC parameters from MFC connected to the serial port

function [] = getMFCParameters(m)


% P-gain register 21
fprintf(m.fid,sprintf('%s$$R21',m.name));
m.P = reg2num(fscanf(m.fid));

% D-gain register 22
fprintf(m.fid,sprintf('%s$$R22',m.name));
m.D = reg2num(fscanf(m.fid));

% I-gain register 22
fprintf(m.fid,sprintf('%s$$R23',m.name));
m.I = reg2num(fscanf(m.fid));
