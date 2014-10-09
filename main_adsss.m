% Implementation of adaptive DSSS code for TVWS vehicular network
% 
% Author: Sanjib Sur
% Institute: University of Wisconsin - Madison
% Version: 0.0.1
% Last modified: 06/26/2014
% 
% Comments: This file contains the adaptive DSSS code for TVWS vehicular
% network to solve the range asymmetry problem in TVWS uplink. This file is
% derived from the 802.11b GNURadio implementation.
% 
% 
% Version: 0.0.2
% Last modified: 06/30/2014
% 
% Comments: Added frequency offset in simulation. Adding Doppler shift to
% simulate Car speed. How to calculate the SNR. One approach to use RSSI,
% and estimate the noise floor by calculating the variation of the raw
% signals in the repeated patterns we can find out the noise floor. Using
% MSE?
% 

clc;
close all;
clear all;


%% Read global variables
adsssGlobalVars;


%% Read configuration file
adsss_config;


%% Construct packets & samples
fg = fopen('databits.dat', 'w');
for k = 1:Txparams.numBitsTotal
	if (rand < 0.5)
        fprintf(fg, '1 ');
    else
        fprintf(fg, '0 ');
    end
    fprintf(fg, '\n');
end
fclose(fg);

% Input data bits
inbits = load('databits.dat').';


%% Generate time domain preambles
Preamble = generate_preamble();
% Preamble = [];


%% Generate time domain data signals
% Right now sending nothing in the payload
% Payload = [];
Payload = generate_payload();


%% Generate packet
Packet = [Preamble Payload];


%% Transmitting samples

TxData_board = modulate_packet(Packet);
new_TxData_board = interp(TxData_board, osamp);

% if USESIM
%     TxData_board = [Padding new_TxData_board];
% else
%     TxData_board = new_TxData_board;
% end
TxData_board = [Padding new_TxData_board];


%% Visualize data
if DEBUG_ON
    % Raw samples
	length_tx = length(TxData_board);
	figure(100);
	plot(1:length_tx, real(TxData_board), 'b-', ...
        1:length_tx, imag(TxData_board), 'r-');
	xlabel('Sample count');
	ylabel('Tx samples');
    title('Transmitted samples');
    
    % PSD
    sigdft = fft(TxData_board);
    figure(101);
    plot(10*log10(abs(fftshift(sigdft)).^2)); 
    title('PSD for transmitted samples');
    
end


%% ================= Start transmission rounds =====================

accBER = 0.0;
BER = 0.0;
correctDataPacket = 0;
header_lost = 0;
numDataPkt = 0;
accSNR = [];

while numDataPkt < Txparams.totalDataPkts
   
% Initialize the performance counters    
RAW_ENERGY = [];
PKT_SNR = 0;    
RSSI = [];


new_TxData_board = [];
fprintf(1, '==== Transmission start for %d-th DATA packet ====\n',...
                                                    numDataPkt+1);

%% Transmit through channel 
RxData_board = adsss_channel(TxData_board);


%% Receiver side
preambleFound = 0;
[preambleFound BER] = adsss_rx(RxData_board);

% Check whether the packet has correct preamble, otherwise discard the BER
% calculation
if preambleFound
    % Calculate the SNR
    accSNR = [accSNR PKT_SNR];
%     if BER < 0.05 % Consider packets which has BER less than 5%, otherwise,
        accBER = accBER + BER;
        correctDataPacket = correctDataPacket + 1;
%     end
else
    header_lost = header_lost + 1;
end

numDataPkt = numDataPkt + 1;

fprintf('\n\n');

                                                
end

disp(accSNR.');
csvwrite('11len_barker_1000pkt.dat', accSNR.');

%% Performance metrics

if correctDataPacket > 0
    
    if DEBUG_ON
        figure(102);
        plot(1:length(accSNR), accSNR, 'r-o');
        axis([0 length(accSNR) 0 max(accSNR)+1]);
        xlabel('Packet number');
        ylabel('SNR (dB)');
        title('SNR variantion over packets');
    end
    
    avg_SNR = mean(accSNR);
    fprintf('Average SNR: %f dB\n', avg_SNR);
    estimated_BER = qfunc(sqrt(10^(avg_SNR/10)));
    fprintf('Average estimated BER: %e\n', estimated_BER);
    
    fprintf ('Average measured BER = %0.6g%%\n', (accBER/correctDataPacket)*100);
    fprintf('Packet loss rate = %0.6g%%\n', ...
        ((numDataPkt-correctDataPacket)/numDataPkt)*100);
    fprintf('Packet header loss rate = %0.6g%%\n', (header_lost/numDataPkt)*100);
    fprintf('Packet loss due to BER = %0.6g%%\n', ...
        ((numDataPkt-correctDataPacket-header_lost)/numDataPkt)*100);
else
    fprintf('Nothing has been decoded!\n');
end


%% Reset and disable the WARP board

if ~USESIM
    
    if WURC % WURC board disable
        wl_basebandCmd(WURC_nodes,'RF_ALL','tx_rx_buff_dis');
        wl_wsdCmd(WURC_nodes,'tx_rx_dis', WURC_RAD_WSDA);
    else % WARP board disable
        wl_basebandCmd(WARP_nodes,sum(WARPLab_RF_vector),'tx_rx_buff_dis');
        wl_interfaceCmd(WARP_nodes,sum(WARPLab_RF_vector),'tx_rx_dis');
    end
end

fprintf('\n\n');