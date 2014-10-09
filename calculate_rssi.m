% Calculate RSSI
% 
% Author: Sanjib Sur
% Institute: University of Wisconsin - Madison
% Version: 0.0.1
% Last modified: 06/29/2014
% 
% Comments: Calculate RSSI value for the 802.11b samples. This file is
% derived from BBN implementation of 802.11b
% 

function [rssi] = calculate_rssi(d_e_squared)

%% Read global variables
adsssGlobalVars;


%% Find RSSI
rssi_linear = round(d_e_squared / (RSSI_AVE_COUNT * 10.0));
d_rssi = RSSI_MAX;

for j = 0:15
    if bitand(rssi_linear,  hex2dec('c0000000'), 'uint32')
        break;
    end
    rssi_linear = bitshift(rssi_linear, 2, 'uint32');
    d_rssi = d_rssi - 6;
end

rssi_linear = bitshift(rssi_linear, -(32 - 6), 'uint32');
rssi_linear = bitand(rssi_linear, hex2dec('3f'), 'uint32');
d_rssi = d_rssi + LOG_TABLE(rssi_linear + 1);

% if d_rssi < 0
%    d_rssi = -bitshift(-d_rssi, 8, 'uint16'); 
% else
%     d_rssi = bitshift(d_rssi, 8, 'uint16');
% end

rssi = d_rssi;
end