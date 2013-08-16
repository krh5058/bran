classdef tclass < handle
  properties
      tmr
  end
  methods
      function this = tclass()
          warning('OFF','MATLAB:TIMER:RATEPRECISION');
          this.tmr = timer('TimerFcn', @tclass.timer_callback, 'Period', 1/30, 'ExecutionMode', 'fixedSpacing');
          set(this.tmr,'UserData',0); % Default
      end
      function delete(this)
          stop(this.tmr);
          delete(this.tmr);
          warning('ON','MATLAB:TIMER:RATEPRECISION');
      end
  end
  methods (Static)
      function timer_callback(h,e)
          [ud.keyIsDown,ud.secs,ud.keyCode]=KbCheck; % Re-occuring check
          
          if ud.keyIsDown
              disp(['tclass.m (timer_callback): Key pressed -- ' KbName(find(ud.keyCode))]);
              set(h,'UserData',ud.keyIsDown);
          end
          
      end
  end
end