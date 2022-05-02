function [rf, gz] = makefatsat(flip, tbw, dur, freq, sys, varargin)
%
% Inputs:
%  flip    [1 1]     deg
%  tbw     [1 1]     time-bandwidth product
%  dur     [1 1]     RF pulse duration (ms)
%  freq    [1 1]     frequency offset (Hz)
%  sys     struct    hardware info, see toppe.systemspecs()
%

% parameters for designing spoiler gradient
arg.nSpoilCycles = 2;  % cycles of spoiling across arg.slThick
arg.slThick = 0.1;     % 'slice' thickness (cm), for deter

arg = vararg_pair(arg, varargin);

% RF pulse
% tmpslthick is dummy value. Determines slice-select gradient, but we won't use it; 
% just needs to be large to reduce dead time before+after rf pulse.
tmpslthick = 1000;       
rf = toppe.utils.rf.makeslr(flip, tmpslthick, tbw, dur, 1e-6, sys, ...
    'type', 'ex', ...    % fatsat pulse is a 90 so is of type 'ex', not 'st' (small-tip)
    'writeModFile', false);

% spoiler
gSpoil = toppe.utils.makecrusher(arg.nSpoilCycles, arg.slThick, sys, 0, sys.maxSlew);

% combine
rf = [rf(:); 0*gSpoil];
gSpoil = [rf(:); 0*gSpoil];

% write mod file
% put crusher on all axes -- can turn off as desired in scanloop.txt
rf = toppe.makeGElength(rf); 
gSpoil = toppe.makeGElength(gSpoil);
toppe.writemod(sys, 'rf', rf, ...
    'gx', gSpoil, 'gy', gSpoil, 'gz', gSpoil, ...
    'ofname', 'fatsat.mod', 'desc', 'fat sat pulse and gradient crusher');


