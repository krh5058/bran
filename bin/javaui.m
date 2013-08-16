function [frame] = javaui()
% javaui.m
% 8/16/13
% Author: Ken Hwang

% Import
import javax.swing.*
import javax.swing.table.*
import java.awt.*

% Set-up JFrame
frame = JFrame('Experiment Info');
callback4 = @(obj,evt)onClose(obj,evt); % Callback for close button
set(frame,'WindowClosingCallback',callback4);
frame.setSize(100,165);
toolkit = Toolkit.getDefaultToolkit();
screenSize = toolkit.getScreenSize();
x = (screenSize.width - frame.getWidth()) / 2;
y = (screenSize.height - frame.getHeight()) / 2;
frame.setLocation(x, y);

% Set-up trigger radio buttons
rb1Panel = JPanel();
r1 = BorderFactory.createTitledBorder('Trigger:');
rb1Panel.setBorder(r1);
yes1 = JRadioButton('Yes');
yes1.setActionCommand('Yes');
yes1.setSelected(true);
no1 = JRadioButton('No');
no1.setActionCommand('No');

group1 = ButtonGroup();
group1.add(yes1);
group1.add(no1);

rb1Panel.add(yes1);
rb1Panel.add(no1);

% Set-up entire right pane
top = JPanel();
top.setMinimumSize(Dimension(75,90));
top.setPreferredSize(Dimension(75,90));
top.add(rb1Panel);

% Set-up confirm button
confirm = JButton('Confirm');
cbh = handle(confirm,'CallbackProperties');
callback1 = @(obj,evt)onConfirm(obj,evt);
set(cbh,'MouseClickedCallback', callback1);

% Set-up bottom pane
bot = JPanel();
bot.setMinimumSize(Dimension(75,75));
bot.setPreferredSize(Dimension(75,75));
bot.add(confirm);

% Split top and bottom
splitpane = JSplitPane(JSplitPane.VERTICAL_SPLIT,top,bot);
splitpane.setEnabled(false);

frame.add(splitpane);

frame.setResizable(0);
frame.setVisible(1);

    function onConfirm(obj,evt) % When confirm button is pressed
        
        selectedModel1 = group1.getSelection();
        trig = selectedModel1.getActionCommand();
        
            % Parameter confirmation
            infostring = sprintf(['Trigger: ' char(trig) ...
                '\n\nIs this correct?']);
            result = javax.swing.JOptionPane.showConfirmDialog(frame,infostring,'Confirm parameters',javax.swing.JOptionPane.YES_NO_OPTION);
            
            % Record data and close
            if result==javax.swing.JOptionPane.YES_OPTION 
                switch char(trig)
                    case 'Yes'
                        trig = 1;
                    case 'No'
                        trig = 0;
                end
                setappdata(frame,'UserData',{trig});
                frame.dispose();
            else
            end
    end

    function onClose(obj,evt) % When close button on frame is pressed
        setappdata(frame,'UserData',[]);
        frame.setVisible(0);
        frame.dispose();
    end
end