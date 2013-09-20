classdef main < handle
    %MAIN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        debug = 1; % Debug on/off
        s = false; % Scramble flag
        monitor
        path
        exp
        misc
        img
        out
    end
    
    events
        record
    end
    
    methods (Static)
        function [monitor] = disp()
            % Find out screen number.
            debug = 1;
            if debug
                %                 whichScreen = max(Screen('Screens'));
                whichScreen = 2;
                oldVerbosityDebugLevel = Screen('Preference', 'Verbosity', 5);
            else
                whichScreen = 0;
            end
%             oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel',0);
            %             oldOverrideMultimediaEngine = Screen('Preference', 'OverrideMultimediaEngine', 1);
            %             Screen('Preference', 'ConserveVRAM',4096);
            %             Screen('Preference', 'VBLTimestampingMode', 1);
            
            % Opens a graphics window on the main monitor (screen 0).  If you have
            % multiple monitors connected to your computer, then you can specify
            % a different monitor by supplying a different number in the second
            % argument to OpenWindow, e.g. Screen('OpenWindow', 2).
            [window,rect] = Screen('OpenWindow', whichScreen);
            
            % Screen center calculations
            center_W = rect(3)/2;
            center_H = rect(4)/2;
            
            % ---------- Color Setup ----------
            % Gets color values.
            
            % Retrieves color codes for black and white and gray.
            black = BlackIndex(window);  % Retrieves the CLUT color code for black.
            white = WhiteIndex(window);  % Retrieves the CLUT color code for white.
            
            gray = (black + white) / 2;  % Computes the CLUT color code for gray.
            if round(gray)==white
                gray=black;
            end
            
            gray2 = gray*1.5;  % Lighter gray
            
            % Taking the absolute value of the difference between white and gray will
            % help keep the grating consistent regardless of whether the CLUT color
            % code for white is less or greater than the CLUT color code for black.
            absoluteDifferenceBetweenWhiteAndGray = abs(white - gray);
            
            % Data structure for monitor info
            monitor.whichScreen = whichScreen;
            monitor.rect = rect;
            monitor.center_W = center_W;
            monitor.center_H = center_H;
            monitor.black = black;
            monitor.white = white;
            monitor.gray = gray;
            monitor.gray2 = gray2;
            monitor.absoluteDifferenceBetweenWhiteAndGray = absoluteDifferenceBetweenWhiteAndGray;
            monitor.oldVisualDebugLevel = oldVisualDebugLevel;
            monitor.oldVerbosityDebugLevel = oldVerbosityDebugLevel;
            %             monitor.oldOverrideMultimediaEngine = oldOverrideMultimediaEngine;
            
            Screen('CloseAll');
        end
    end
    
    methods
        function obj = main(varargin)
            ext = [];
            d = [];
            s = [];
            
            % Argument evaluation
            for i = 1:nargin
                if ischar(varargin{i}) % Assume main directory path string
                    ext = varargin{i};
                elseif iscell(varargin{i}) % Assume associated directories
                    d = varargin{i};
                elseif islogical(varargin{i})
                    s = varargin{i};
                    obj.s = s;
                else
                    fprintf(['main.m (main): Other handles required for argument value: ' int2str(i) '\n']);
                end
            end
            
            % Path property set-up
            if isempty(ext) || isempty(d)
                error('main.m (main): Empty path string or subdirectory list.');
            else
                try
                    fprintf('main.m (main): Executing path directory construction...\n');
                    obj.pathset(d,ext);
                    fprintf('main.m (main): obj.pathset() success!\n');
                catch ME
                    throw(ME);
                end
            end
            
            if ~s
                % Display properties set-up
                try
                    fprintf('main.m (main): Gathering screen display details (Static)...\n');
                    monitor = obj.disp; % Static method
                    fprintf('main.m (disp): Storing monitor property.\n');
                    obj.monitor = monitor;
                    fprintf('main.m (main): obj.disp success!\n');
                catch ME
                    throw(ME);
                end
            end
            
            % Experimental properties set-up
            try
                fprintf('main.m (main): Gathering experimental details...\n');
                obj.expset();
                fprintf('main.m (main): obj.expset() success!\n');
            catch ME
                throw(ME);
            end
            
        end
        
        function [path] = pathset(obj,d,ext)
            if all(cellfun(@(y)(ischar(y)),d))
                for i = 1:length(d)
                    path.(d{i}) = [ext filesep d{i}];
                    [~,d2] = system(['dir /ad-h/b ' ext filesep d{i}]);
                    if ~isempty(d2)
                        d2 = regexp(strtrim(d2),'\n','split');
                        for j = 1:length(d2)
                            path.(d2{j}) = [ext filesep d{i} filesep d2{j}];
                        end
                    end
                end
                fprintf('main.m (pathset): Storing path property.\n');
                obj.path = path;
            else
                error('main.m (pathset): Check subdirectory argument.')
            end
        end
        
        function [exp] = expset(obj)
            
            % Experimental parameters
            exp.section = {'A','B','C'}; % Sections
            exp.order_n = 12; % Number of orders
            exp.pres_n = 5; % Number of presentations
            exp.scrambleID = 'C';
            exp.scrambleSize = 16; % Pixel sizes of scramble square sub-section
            exp.TR = 2;
            exp.iPAT = false;
            
            TRadd = 0;
            
            while TRadd < 4
                TRadd = TRadd + exp.TR;
            end
            
            exp.DisDaq = TRadd + exp.iPAT*exp.TR + .75; % (s)
            
            if obj.s
            else
                fprintf('main.m (expset): UI query for experimental parameters.\n');
                frame = javaui(cellfun(@int2str,num2cell(1:exp.order_n),'UniformOutput',false));
                waitfor(frame,'Visible','off'); % Wait for visibility to be off
                s = getappdata(frame,'UserData'); % Get frame data
                java.lang.System.gc();
                
                if isempty(s)
                    error('scan.m (scan): User Cancelled.')
                end
                
                exp.sid = s{1};
                exp.trig = s{2};
                exp.order = cellfun(@str2double,s{3})';
            end
            
            exp.presdur = 2; % s
            exp.fixdur = .5; % s
            exp.ISIdur = 5:.5:20; % s 
            exp.intro = 'Press Spacebar to continue.';
            exp.intro1 = 'Get Ready';
            exp.intro2 = 'Get Ready.';
            exp.presmat = []; % Timing matrix
            exp.lh.lh1 = obj.recordLh;
            
            % Keys
            KbName('UnifyKeyNames');
            keys.tkey = KbName('t');
            keys.esckey = KbName('Escape');
            keys.spacekey = KbName('SPACE');
            
            fprintf('pres.m (pres): Defining key press identifiers...\n');
            exp.keys = keys;
            
            fprintf('main.m (expset): Storing experimental properties.\n');
            obj.exp = exp;
            
            out.f_out = [exp.sid '_out'];
            out.head1 = {'Onset(s)','Order','Section','Picture'};
            out.out1 = cell([1 length(out.head1)]);
            out.out1(1,:) = out.head1;
            
            fprintf('main.m (expset): Initializing output.\n');
            obj.out = out;
            
            % Misc
            misc.fix1 = @(monitor)(Screen('DrawLine',monitor.w,monitor.black,monitor.center_W-20,monitor.center_H,monitor.center_W+20,monitor.center_H,7));
            misc.fix2 = @(monitor)(Screen('DrawLine',monitor.w,monitor.black,monitor.center_W,monitor.center_H-20,monitor.center_W,monitor.center_H+20,7));
            misc.text = @(monitor,txt,color)(DrawFormattedText(monitor.w,txt,'center','center',color));
            misc.mktex = @(monitor,img)(Screen('MakeTexture', monitor.w,img));
            misc.drwtex = @(monitor,tex)(Screen('DrawTexture',monitor.w,tex));
            
            fprintf('main.m (expset): Storing miscellaneous properties.\n');
            obj.misc = misc;
        end
        
        function [result] = scrambleCall(obj)
            result = scramble(obj);
        end
        
        function loadImages(obj)
%             [~,d] = system(['dir /b ' obj.path.images]);
%             d = regexp(strtrim(d),'\n','split');
            obj.img = cell([obj.exp.order_n length(obj.exp.section) obj.exp.pres_n]);
            
            for i = 1:obj.exp.order_n
               for ii = 1:length(obj.exp.section)
                   for iii = 1:obj.exp.pres_n
                       try
                           obj.img{i,ii,iii} = imread([obj.path.images filesep obj.exp.section{ii} int2str(i) '_0' int2str(iii) '.jpg']);
                       catch ME
                           disp(ME)
                       end
                   end
               end
            end
            
        end
        
        function [lh] = recordLh(obj)
            fprintf('main.m (recordLh): Adding "record" listener handle...\n');
            lh = addlistener(obj,'record',@(src,evt)outFormat(obj,src,evt));
        end
        
        function drwfix(obj) % Corresponding to lh1
            obj.misc.fix1(obj.monitor);
            obj.misc.fix2(obj.monitor);
        end
        
        function [t] = disptxt(obj,txt) % Corresponding to lh3
            obj.misc.text(obj.monitor,txt,obj.monitor.black);
            t = Screen('Flip',obj.monitor.w);
        end
        
        function result = drwimg(obj,img)
            try
                tex = obj.misc.mktex(obj.monitor,img);
                obj.misc.drwtex(obj.monitor,tex);
                result = tex;
            catch ME
                result = ME;
            end
        end
        
        function closetex(obj,tex)
           try
               Screen('Close',tex);
           catch ME
               disp(ME);
           end
        end
        
        function dispimg(obj)
            Screen('Flip',obj.monitor.w);
        end
        
        function t = getT(obj,iii,ii,i)
            t = obj.exp.presmat(iii,ii,i);
        end
        
%         function order = shuffleOrder(obj)
%             order = Shuffle(1:obj.exp.order_n);
%         end
        
        function order = shuffleSection(obj)
            order = obj.exp.section(Shuffle(1:length(obj.exp.section)));
        end
        
        function t = presCalc(obj)
            t = zeros([obj.exp.pres_n*2 length(obj.exp.section) obj.exp.order_n]); % Rows include picture and fixation presentation (i.e. x2) 
            picflag = 1; % Default
            ISIflag = 1; % Default
            
            for i = 1:obj.exp.order_n
                t0 = 0;
                for ii = 1:length(obj.exp.section)
                    for iii = 1:obj.exp.pres_n*2 
                        if picflag % Picture
                            t(iii,ii,i) = t0;
                            t0 = t0 + obj.exp.presdur;
                            picflag = 0;
                        else % Fixation
                            t(iii,ii,i) = t0;
                            
                            if ISIflag < obj.exp.pres_n % Inter-picture fixation
                                t0 = t0 + obj.exp.fixdur;
                                ISIflag = ISIflag + 1;
                            else % Inter-trial fixation
                                t0 = t0 + randsample(obj.exp.ISIdur,1);
                                ISIflag = 1;
                            end
                            
                            picflag = 1;
                        end
                    end
                end
            end
        end
        
        function outFormat(obj,src,evt)
            obj.out.out1(end+1,:) = {evt.t,evt.order,evt.section,evt.pres};
        end
        
        function outWrite(obj)
            fprintf('main.m (outWrite): Storing presentation data.\n');
            cell2csv([obj.path.out filesep obj.out.f_out '1.csv'],obj.out.out1)
        end
        
    end
    
end

