% Implementation of ADSSS PHY layer receiver side
% 
% Author: Sanjib Sur
% Institution: University of Wisconsin - Madison
% Version: 0.0.1
% Last modified: 06/22/2014
% 
% Comments: This file contains the ADSSS PHY layer receiver code. Derived
% from the 802.11b GNURadio implementation and written in ZigbeeRx.m file
% format.
% 

function [detect_pkt_flag BER] = adsss_rx(RxData_board)

%% Read global variables
adsssGlobalVars;


%% Plotting raw samples and psd

if DEBUG_ON
    % Raw samples
    length_rx = length(RxData_board);
	figure(200);
	plot(1:length_rx, real(RxData_board), 'b-', ...
        1:length_rx, imag(RxData_board), 'r-');
	xlabel('Sample count');
	ylabel('Rx samples');
    title('Received samples');
    
    % PSD 
    sigdft = fft(RxData_board);
    figure(201);
    plot(10*log10(abs(fftshift(sigdft)).^2)); 
    title('PSD for received samples');
    
end

% Downsample the received samples
sigin = decimate(RxData_board, osamp);


%% Receiver logic starts here

sigin = demodulate_packet(sigin);


%% Packet detection logic
% Convert bytes into bits
% sigin = reshape(de2bi(sigin, 8, 'left-msb').', 1, length(sigin) * 8);
[detect_pkt_flag dataPos] = detect_packet_rx(sigin);


%% Decode
% Only if packet is detected proceed
if ~detect_pkt_flag 
	BER = Inf;
    if VERBOSE1
        fprintf('No packet is detected!\n');
    end
	return;
end

if VERBOSE1
    fprintf('Packet is detected!\n');
end


%% Estimate the noise floor and SNR
% Estimate the noise floor by back-tracking the preamble before matched
% filtering
% estimated_noise = calculate_noise(dataPos, sigin, RxData_board);
% SNR = 10*log10(RAW_ENERGY/estimated_noise);

% Estimate SNR from the Raw energy output
PKT_SNR = estimate_snr(dataPos);

if VERBOSE2
    fprintf('SNR: %f dB\n', PKT_SNR);
end

if DEBUG_ON

    figure(202);
    plot_rssi = reshape(repmat(RSSI.', 1, RSSI_AVE_COUNT).', 1, length(RSSI) * RSSI_AVE_COUNT);
    plot(plot_rssi);
    xlabel('Samples');
    ylabel('RSSI');
    title('RSSI values from the table after matched filtering at the receiver');
    
    figure(203);
    % plot_raw_energy = reshape(repmat(RAW_ENERGY.', 1, RSSI_AVE_COUNT).', 1, length(RAW_ENERGY) * RSSI_AVE_COUNT);
    plot_raw_energy = RAW_ENERGY;
    plot(plot_raw_energy);
    xlabel('Samples');
    ylabel('Raw energy');
    title('Raw energy after matched filtering at the receiver');
    
%     figure(204);
%     plot_snr = reshape(repmat(SNR.', 1, RSSI_AVE_COUNT).', 1, length(SNR) * RSSI_AVE_COUNT);
%     plot(plot_snr);
%     xlabel('Samples');
%     ylabel('SNR (dB)');
%     title('SNR of received samples');
    
end


%% Data decoding logic
outbits = decode_data_rx(dataPos, sigin);


%% Visualize the data
mBER = sum(outbits ~= inbits)/length(inbits);    
BER = mBER;
    
if DEBUG_ON
        
    figure(208);
    stairs(inbits);
    axis([0 length(inbits) -0.5 1.5]);
    xlabel('Bit number');
    ylabel('Bit value');
    title('Input bits');
     
    figure(209);
    stairs(outbits);
    axis([0 length(outbits) -0.5 1.5]);
    xlabel('Bit number');
    ylabel('Bit value');
    title('Output bits');
     
    bit_error = xor(outbits, inbits);
    idx = (bit_error == 0);
    x = 1:length(bit_error);
    figure(210);
    plot(x(idx), bit_error(idx), 'g*', x(~idx), bit_error(~idx), 'ro');
    axis([0 length(bit_error) -0.5 1.5]);
    xlabel('Bit position');
    ylabel('Error');
    title('Error position');
     
end

end