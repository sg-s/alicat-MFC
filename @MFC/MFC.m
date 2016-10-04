classdef MFC < handle

	properties
		port ='/dev/tty.usbserial-FT02WKAF'; % which USB port to use?
		fid % file ID to port

		% communication parameters
		baud_rate = 19200

		verbosity = 10;

		% name of MFC (this is the alhabetic identifier of the MFC, usually "A". You can change this on the MFC)
		name = 'A';

		% MFC parameters
		P
		I
		D

		temperature 
		pressure

		set_point
		flow_rate

		

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
			cprintf('text','Connecting to Alicats on port %s\n',m.port)

			m.fid = serial(m.port,'TimeOut', 2,'BaudRate', m.baud_rate, 'Terminator','CR');

			try
				fopen(m.fid)
			catch
				cprintf('red','[ERR] ')
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