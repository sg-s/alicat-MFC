classdef MFC < handle

	properties
		port ='/dev/tty.usbserial-FT02WKAF'; % which USB port to use? this works on macOS
		%port ='COM3'
		fid % file ID to port

		% communication parameters
		baud_rate = 19200

		verbosity = 0

		% name of MFC (this is the alphabetic identifier of the MFC, usually "A". You can change this on the MFC)
		name = 'A';

		% MFC parameters
		P
		I
		D

		temperature 
		pressure
		flow_rate

		set_point
		
		% PID tuning parameters
		acceptable_error = 3 % in units of mL/min 
		P_range = [400 3000];
		D_range = [5e3 1e4];
		nsteps_P = 9;
		nsteps_D = 10; 

		

	end % end properties 

	properties (SetAccess = immutable)
		% machine info
		model_number
		serial_number
		max_flow_rate
	end

	methods

		function m = MFC()
			
			cprintf('green','[INFO] ')
			cprintf('text','Connecting to Alicat MFC on port %s\n',m.port)

			m.fid = serial(m.port,'TimeOut', 2,'BaudRate', m.baud_rate, 'Terminator','CR');

			try
				fopen(m.fid)
			catch
				cprintf('red','[FATAL] ')
                cprintf('text','Could not open the port you specified. Probably the wrong port.\n')
                return
			end

			pause(1)
			m = getMFCParameters(m);

			
			% get manufacturer info
			fprintf(m.fid,[m.name '??M*']);
			for i = 1:10
				t = fscanf(m.fid);
				a = strfind(t,'Model Number');
				if any(a)
					m.model_number = strtrim(t(a+12:end));
				end

				a = strfind(t,'Serial Number');
				if any(a)
					m.serial_number = str2double(t(a+14:end));
				end
			end

			% get the data frame bounds to determine max setpoint
			% get manufacturer info
			fprintf(m.fid,[m.name, '??D*']);
			for i = 1:15
				t = fscanf(m.fid);
				if any(strfind(t,'SetPoint'))
					a = strfind(t,'+');
					a = a(end);
					z = strfind(t,'SCCM');
					m.max_flow_rate = str2double(t(a+1:z-1));
				end
			end

			if ~nargout
                cprintf('red','[WARN] ')
                cprintf('text','MFC called without assigning to a object. MFC will create an object called "m" in the workspace\n')
                assignin('base','m',m);
            end

		end

		function v = get.flow_rate(m)
			[~,~,v] = readFrame(m);
		end

		function m = set.set_point(m,value)
			assert(isscalar(value),'Setpoint must be a single value')
			assert(~isnan(value),'Setpoint must be a number')
			assert(~isinf(value),'Setpoint must be finite')
			assert(value>=0,'Setpoint must be positive')
			assert(value<=m.max_flow_rate,'Setpoint exceeds maximum flow rate')
			a = 64000*(value/m.max_flow_rate);
			fprintf(m.fid,[m.name,num2str(a)]);
			m.set_point = value;
		end

		function m = set.P(m,value)
			setMFCParameters(m,'P',value);
			m.P = value;
        end 

        function m = set.D(m,value)
			setMFCParameters(m,'D',value);
			m.D = value;
        end 

        function m = set.I(m,value)
			setMFCParameters(m,'I',value);
			m.I = value;
        end 

        function [flow_rate] = run(m,time,setpoints)
        	% measures flow from MFC while applying setpoints defined by time and setpoint vector
        	real_time = NaN(max(time)*1e3,1);
        	flow_rate = NaN(max(time)*1e3,1);
        	c = 0;
        	tic;
        	t = toc;
        	while t < max(time)
        		m.set_point = setpoints(find(time>t,1,'first'));
        		c = c + 1;
        		real_time(c) = t;
        		flow_rate(c) = m.flow_rate;
        		t = toc;
        	end
        	flow_rate = interp1(real_time(1:c),flow_rate(1:c),time);
        end

        function [] = tunePID(m)
        	% make the ranges of PID values
        	all_P = round(logspace(log10(m.P_range(1)),log10(m.P_range(2)),m.nsteps_P));
        	all_D = round(logspace(log10(m.D_range(1)),log10(m.D_range(2)),m.nsteps_D));
        	tau_on = NaN(m.nsteps_P,m.nsteps_D);
        	tau_off = NaN(m.nsteps_P,m.nsteps_D);

        	tolerance = m.acceptable_error;

        	figure('outerposition',[0 0 800 500],'PaperUnits','points','PaperSize',[1000 500]); hold on
        	p1 = plot(NaN,NaN,'k');
        	p2 = plot(NaN,NaN,'r');
        	p3 = plot(NaN,NaN,'b--');
        	p4 = plot(NaN,NaN,'b--');

        	for i = 1:length(all_P)
        		m.P = all_P(i);
        		for j = 1:length(all_D)
        			m.D = all_D(j);

        			% estimate response time
        			time = linspace(0,3,3e3);
        			setpoints = 5/2+0*time;
        			setpoints(1e3:2e3) = 250;

        			[flow_rate] = run(m,time,setpoints);
        			err = abs(setpoints-flow_rate);
        			temp = find(err(1e3+1:2e3) > tolerance,1,'last');
        			if ~isempty(temp)
        				tau_on(i,j) = temp;
        			end
        			temp = find(err(2e3+1:end) > tolerance,1,'last');
        			if ~isempty(temp)
        				tau_off(i,j) = temp;
        			end

        			p1.XData = time;
        			p2.XData = time;
        			p1.YData = setpoints;
        			p2.YData = flow_rate;

        			p3.XData = 1+1e-3*[tau_on(i,j) tau_on(i,j)];
        			p3.YData = [0 500];

        			p4.XData = 2+1e-3*[tau_off(i,j) tau_off(i,j)];
        			p4.YData = [0 500];

        			title(['P = ' oval(all_P(i)) ' D = ' oval(all_D(j))])

        			drawnow


        		end
        	end

        	figure('outerposition',[0 0 500 500],'PaperUnits','points','PaperSize',[1000 500]);
        	tau = max(cat(3,tau_on,tau_off),[],3);
        	h = heatmap(all_D, all_P,tau);
        	h.Colormap = parula;
        	
        	title('Worst-case response times (ms)')
        	xlabel('D')
        	ylabel('P')

        	prettyFig;
        	
        	% find best values
        	[r,c]=find(tau == min(min(tau)));
        	
        	disp('The best P/D values are:')
        	disp(['P = ' oval(all_P(r))])
        	disp(['D = ' oval(all_D(c))])

        	m.P = all_P(r);
        	m.D = all_D(c);

        	% update P_ and D_range
        	m.P_range = [all_P(r)/2 all_P(r)*2];
        	m.D_range = [all_D(c)/2 all_D(c)*2];

        end % end tunePID

		function delete(m)
            if m.verbosity > 5
                cprintf('green','[INFO] ')
                cprintf('text','mfc -> delete called \n')
            end

            if ~isempty(m.fid)
                delete(m.fid);
            end


            delete(m)
        end

	end % end methods

end % end classdef