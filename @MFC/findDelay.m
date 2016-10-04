function [] = findDelay(m)

cprintf('red','[INFO] ')
cprintf('text','Determining delay between moving setpoint and actual flow rate \n')



set_points = [linspace(0,100,25) linspace(100,0,25)];

figure, hold on
set(gca,'YLim',[0 100])

t = NaN*set_points;
y = NaN*set_points;

tic

for i = 1:length(set_points)
	m.set_point = set_points(i);
	f = m.flow_rate;
	t(i) = toc;
	y(i) = f;

	plot(t(i),set_points(i),'k+')
	plot(t(i),y(i),'r+')
	drawnow
end

tt = linspace(min(t),max(t),length(t));
y = interp1(t,y,tt);
set_points =  interp1(t,set_points,tt);

cla
plot(tt,set_points,'k')
plot(tt,y,'r')

d = finddelay(set_points,y);
d = mean(diff(tt))*d;

cprintf('red','[INFO] ')
cprintf('text','Delay in ms between control signal and real flow is: \n')
disp(round(1000*d))
