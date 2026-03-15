function motor_app

clc
close all

%% CREATE GUI

fig = uifigure('Name','Motor Calculator','Position',[100 100 900 600]);

%% INPUT PANEL

panel = uipanel(fig,'Title','Input Data','Position',[20 200 250 350]);

labels = {'HP',...
'Voltage (V)',...
'Efficiency',...
'Power Factor',...
'Frequency (Hz)',...
'Poles',...
'Speed (rpm)',...
'Correction K',...
'Cable Length (m)',...
'Cable R (ohm/km)',...
'Cable X (ohm/km)',...
'Target PF',...
'Allowed Voltage Drop (%)'};

for i = 1:length(labels)

    uilabel(panel,'Position',[10 320-25*i 130 22],'Text',labels{i});

    edit(i) = uieditfield(panel,'numeric','Position',[140 320-25*i 90 22]);

end

%% BUTTONS

uibutton(fig,'Text','Calculate',...
'Position',[40 150 90 30],...
'ButtonPushedFcn',@(btn,event) calculate());

uibutton(fig,'Text','Load Example',...
'Position',[150 150 90 30],...
'ButtonPushedFcn',@(btn,event) example());

uibutton(fig,'Text','Export Excel',...
'Position',[95 110 90 30],...
'ButtonPushedFcn',@(btn,event) exportExcel());

%% RESULT TABLE

tableUI = uitable(fig);

tableUI.Position = [300 320 550 220];

tableUI.ColumnName = {'Parameter','Value','Unit'};

%% VOLTAGE LAMP

uilabel(fig,'Position',[300 290 150 22],'Text','Voltage Drop Status');

lamp = uilamp(fig,'Position',[460 290 20 20]);

%% TORQUE GRAPH

ax = uiaxes(fig);

ax.Position = [300 40 550 220];

title(ax,'Torque - Slip Characteristic')

%% FUNCTION LOAD EXAMPLE

function example()

vals = [40 380 0.86 0.82 50 4 1450 0.8 50 0.884 0.082 0.9 5];

for k = 1:length(vals)

edit(k).Value = vals(k);

end

end

%% FUNCTION CALCULATE

function calculate()

HP = edit(1).Value;
VL = edit(2).Value;
Eff = edit(3).Value;
PF = edit(4).Value;
f = edit(5).Value;
P = edit(6).Value;
N = edit(7).Value;

K = edit(8).Value;

L = edit(9).Value;
R = edit(10).Value;
X = edit(11).Value;

PF_target = edit(12).Value;

Drop_allow = edit(13).Value;

%% INPUT VALIDATION

if HP <= 0
uialert(fig,'HP must be greater than 0','Input Error')
return
end

if VL <= 0
uialert(fig,'Voltage must be greater than 0','Input Error')
return
end

if Eff <= 0 || Eff > 1
uialert(fig,'Efficiency must be between 0 and 1','Input Error')
return
end

if PF <= 0 || PF > 1
uialert(fig,'Power factor must be between 0 and 1','Input Error')
return
end

if P <= 0 || mod(P,2) ~= 0
uialert(fig,'Poles must be positive even number','Input Error')
return
end

%% CALL CALCULATION FUNCTION

result = motor_calc(HP,VL,Eff,PF,f,P,N,K,L,R,X,PF_target);

%% SHOW RESULT TABLE

data = {
'Rated Power', result.Pdm,'kW'
'Rated Current',result.Idm,'A'
'Phase Current',result.IP,'A'
'Synchronous Speed',result.Ns,'rpm'
'Slip',result.slip,'-'
'Slip (%)',result.slip_percent,'%'
'Input Power',result.Pin,'kW'
'Power Loss',result.Ploss,'kW'
'Corrected Current',result.Idm_corr,'A'
'Torque Sync',result.T_sync,'N.m'
'Torque Load',result.T_load,'N.m'
'Voltage Drop',result.VoltageDrop,'V'
'Voltage Drop (%)',result.VoltageDrop_percent,'%'
'Reactive Power',result.Qc,'kVar'
};

tableUI.Data = data;

%% VOLTAGE DROP CHECK

if result.VoltageDrop_percent < Drop_allow

lamp.Color = 'green';

else

lamp.Color = 'red';

end

%% SLIP WARNING

if result.slip_percent > 5

uialert(fig,'Warning: Slip > 5%. Motor may be overloaded.','Slip Warning')

end

%% TORQUE SLIP GRAPH

s = linspace(0.001,1,200);

T = result.T_load./s.*(1-s);

plot(ax,s,T,'LineWidth',2)

xlabel(ax,'Slip')

ylabel(ax,'Torque (N.m)')

grid(ax,'on')

end

%% EXPORT EXCEL

function exportExcel()

data = tableUI.Data;

Parameter = data(:,1);
Value = data(:,2);
Unit = data(:,3);

T = table(Parameter,Value,Unit);

writetable(T,'motor_result.xlsx')

uialert(fig,'File motor_result.xlsx saved','Export Complete')

end

end