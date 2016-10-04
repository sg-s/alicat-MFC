classdef MFC < handle

	properties
		port ='/dev/tty.usbserial-FT02WKAF'; % which USB port to use?
		fid % file ID to port

		verbosity = 10;

		% name of MFC (this is the alhabetic identifier of the MFC, usually "A")
		name = 'A';

		% MFC parameters
		P
		I
		D

		temperature 
		pressure

	end % end properties 

	methods

		function m = MFC()
			
			cprintf('green','[INFO] ')
			cprintf('text','Connecting to Alicats on port %s\n',m.port)

			m.fid = serial(m.port,'TimeOut', 2,'BaudRate', 19200, 'Terminator','CR');

			try
				fopen(m.fid)
			catch
				cprintf('red','[ERR] ')
                cprintf('text','Could not open the port you specified. Probably the wrong port.\n')
                return
			end

			m.getMFCParameters;

			if ~nargout
                cprintf('red','[WARN] ')
                cprintf('text','MFC called without assigning to a object. MFC will create an object called "m" in the workspace\n')
                assignin('base','m',m);
            end

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