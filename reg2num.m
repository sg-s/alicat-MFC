% reg2num.m
% simple function to convert the register readout of Alicat MFCs to a number
% Rob Campbell had this function at some point, but is no longer on his repo
% this is my version to mimic what I think his function does
%
function [n] = reg2num(r)

a = strfind(r,'=');
n = str2double(r(a+1:end));