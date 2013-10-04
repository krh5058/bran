function bran(varargin)
% bran
% As requested by Kathleen Keller, Wendy Stein
%
% Author: Ken Hwang
% SLEIC, PSU
%
% See ReadMe.txt

s = false;

if nargin > 0
    switch varargin{1}
        case 'scramble'
            s = true; % Scramble
    end
end

if ~ispc
    error('bran.m: PC support only.')
end

% Directory initialization
try
    fprintf('bran.m: Directory initialization...\n')
    
    mainpath = which('main.m');
    if ~isempty(mainpath)
        [mainext,~,~] = fileparts(mainpath);
        rmpath(mainext);
    end
    
    javauipath = which('javaui.m');
    if ~isempty(javauipath)
        [javauiext,~,~] = fileparts(javauipath);
        rmpath(javauiext);
    end
    
    p = mfilename('fullpath');
    [ext,~,~] = fileparts(p);
    [~,d] = system(['dir /ad-h/b ' ext]);
    d = regexp(strtrim(d),'\n','split');
    cellfun(@(y)(addpath([ext filesep y])),d);
    fprintf('bran.m: Directory initialization success!.\n')
catch ME
    throw(ME)
end

try
    fprintf('bran.m: Object Handling...\n')
    % Object construction and initial key restriction
    obj = main(ext,d,s);
    fprintf('bran.m: Object Handling success!.\n')
catch ME
    throw(ME)
end

if s
    result = obj.scrambleCall;
    disp(result);
else
    
    try
        fprintf('bran.m: Window initialization...\n')
        % Open and format window
        obj.monitor.w = Screen('OpenWindow',obj.monitor.whichScreen,obj.monitor.white);
        Screen('BlendFunction',obj.monitor.w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        Screen('TextSize',obj.monitor.w,30);
        fprintf('bran.m: Window initialization success!.\n')
    catch ME
        throw(ME)
    end
    
    fprintf('bran.m: Beginning presentation sequence...\n')
    
    
    % Prepare experimental conditions
    obj.loadImages;
    %     order = obj.shuffleOrder;
    obj.exp.presmat = obj.presCalc;
    tobj = tclass(obj.exp.keys.esckey);
    
    if ~obj.debug
        ListenChar(2);
        HideCursor;
        ShowHideFullWinTaskbarMex(0);
    end
    
    for i = 1:obj.exp.order_n
        
        % Prepare intra-order parameters
        ii = 1;
        iii = 1;
        picflag = 1;
        prepflag = 1;
        dispflag = 1;
        data.order = obj.exp.order(i);
        order_i = data.order;
        %         data.order = order(i);
        pres_order = obj.shuffleSection;
    
        obj.dispimg(); % Clear screen
        
        % Wait for instructions
        RestrictKeysForKbCheck([obj.exp.keys.spacekey obj.exp.keys.esckey]);
        obj.disptxt(obj.exp.intro);
        [~,keyCode] = KbStrokeWait;
        
        % Abort if escape pressed during instructions screen
        if find(keyCode)==obj.exp.keys.esckey
           break; 
        end
        
        % Triggering
        obj.disptxt(obj.exp.intro1);
        if obj.exp.trig % Auto-trigger
            RestrictKeysForKbCheck(obj.exp.keys.tkey);
            KbStrokeWait; % Waiting for first trigger pulse, return timestamp
        else % Manual trigger
            RestrictKeysForKbCheck(obj.exp.keys.spacekey);
            KbStrokeWait; % Waiting for scanner operator
            obj.disptxt(obj.exp.intro2);
            pause(obj.exp.DisDaq); % Simulating DisDaq
        end
        
        RestrictKeysForKbCheck(obj.exp.keys.esckey);
        
        start(tobj.tmr);
        t0 = GetSecs;
        
        while (GetSecs - t0) < obj.exp.presmat(end,end,order_i) % Continue until last time point
            
            % Draw & prepare
            if prepflag
                prepflag = 0;
                %         for ii = 1:length(pres_order)
                data.section = pres_order{ii};
                
                %             for iii = 1:obj.exp.pres_n*2
                t = obj.getT(iii,ii,order_i);
                if picflag % Picture or fixation
                    if obj.debug
                        disp(['bran.m (Debug): Expected image: ' data.section int2str(data.order) '_' int2str(ceil(iii/2))]);
                    end
                    
                    data.pres = [data.section int2str(data.order) '_' int2str(ceil(iii/2))];
                    
                    img = obj.img{order_i,strcmp(obj.exp.section,pres_order{ii}),ceil(iii/2)};
                    tex = obj.drwimg(img);
                    picflag = 0;
                else
                    if obj.debug
                        disp('bran.m (Debug): Expecting Fixation.');
                    end
                    
                    data.pres = 'Fixation';
                    
                    obj.drwfix;
                    picflag = 1;
                end
            end
            
            % Display & record
            if dispflag
                if (GetSecs - t0) > t % If time surpasses current onset
                    prepflag = 1; % Prep next
                    try
                        obj.dispimg();
                        
                        data.t = num2str(GetSecs-t0);
                        
                        if obj.debug
                            disp(['bran.m (Debug): Scheduled time: ' num2str(t)]);
                            disp(['bran.m (Debug): VBL timestamp: ' num2str(data.t)]);
                            disp(['bran.m (Debug): Order value: ' int2str(data.order)]);
                            disp(['bran.m (Debug): Section ID: ' data.pres]);
                            disp(['bran.m (Debug): Presentation order value: ' int2str(ceil(iii/2))]);
                        end
                        
                        notify(obj,'record',evt(data));
                        
                    catch ME
                        disp(ME)
                    end
                    
                    if picflag
                        obj.closetex(tex);
                    end
                    
                    % Increase indices
                    if iii == obj.exp.pres_n*2 % Increase if not final presentation index
                        iii = 1; % Reset to 1 if final index
                        if ii == length(pres_order) % Increase if not final section index
                            prepflag = 0; % Cancel last prep
                            dispflag = 0; % Stop displays
                        else
                            ii = ii + 1;
                        end
                    else
                        iii = iii + 1;
                    end
                    
                end
            end
            
            ud = get(tobj.tmr,'UserData');
            if ud.keyIsDown
                break;
            end
            
        end
        
        stop(tobj.tmr);
        
        if ud.keyIsDown
            break;
        end
        
    end
    
    obj.outWrite;
    
    % Clean up
    RestrictKeysForKbCheck([]);
    tobj.delete;
    
    if ~obj.debug
        ListenChar(0);
        ShowCursor;
        ShowHideFullWinTaskbarMex(1);
    end
    
%     Screen('Preference','Verbosity',obj.monitor.oldVerbosityDebugLevel);
%     Screen('Preference','VisualDebugLevel',obj.monitor.oldVisualDebugLevel);
    fclose('all');
    Screen('CloseAll');
end
end