% function bran(varargin)
% bran
% As requested by Kathleen Keller, Wendy Stein
% 
%
% Author: Ken Hwang
% SLEIC, PSU
%
% See ReadMe.txt

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
    obj = main(ext,d);
    RestrictKeysForKbCheck(obj.exp.keys.spacekey);
    fprintf('bran.m: Object Handling success!.\n')
catch ME
    throw(ME)
end
% 
% try
%     fprintf('bran.m: Window initialization...\n')
%     % Open and format window
%     obj.monitor.w = Screen('OpenWindow',obj.monitor.whichScreen,obj.monitor.white);
%     Screen('BlendFunction',obj.monitor.w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
%     Screen('TextSize',obj.monitor.w,30);
%     fprintf('bran.m: Window initialization success!.\n')
% catch ME
%     throw(ME)
% end
% 
% fprintf('bran.m: Beginning presentation sequence...\n')
% 
% if ~obj.debug
%     ListenChar(2);
%     HideCursor;
%     ShowHideFullWinTaskbarMex(0);
% end
% 
% % Wait for instructions
% obj.disptxt(obj.exp.intro);
% KbStrokeWait;
% 
% % Triggering
% obj.disptxt(obj.exp.wait1);
% if obj.exp.trig % Auto-trigger
%     RestrictKeysForKbCheck(obj.exp.keys.tkey);
%     obj.misc.start_t = GetSecs; % Return timestamp
%     KbStrokeWait; % Waiting for first trigger pulse, return timestamp
% else % Manual trigger
%     RestrictKeysForKbCheck(obj.exp.keys.spacekey);
%     KbStrokeWait; % Waiting for scanner operator
%     obj.disptxt(obj.exp.wait2);
%     obj.misc.start_t = GetSecs; % Return timestamp
%     pause(obj.exp.DisDaq); % Simulating DisDaq
% end
%             
% % Clean up
% RestrictKeysForKbCheck([]);
% if ~obj.debug
%     ListenChar(0);
%     ShowCursor;
%     ShowHideFullWinTaskbarMex(1);
% end
% 
% Screen('Preference','VisualDebugLevel',obj.monitor.oldVisualDebugLevel);
% fclose('all');
% Screen('CloseAll');

% end