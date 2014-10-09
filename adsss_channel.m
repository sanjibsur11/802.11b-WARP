% Channel model for TVWS
% 
% Author: Sanjib Sur
% Institute: University of Wisconsin - Madison
% Version: 0.0.1
% Last modified: 06/22/2014
% 
% Comments: This file contains the channel model for TV white space
% communications
% 
% 1. Fake channel: Extremely helpful for initial debugging and
% implementation of the PHY layer
% 
% 2. Additive Gaussian: Useful for simulations etc. and to calculate
% bit-error rate in simulation
% 
% 4. WARP board: This is the main WARP transmit and receive channel
% 
% 5. WURC board: This is the main Whitespace WARP transmit and receive
% channel
% % 


function [RxData_board] = adsss_channel(TxData_board)

%% Read global variables
adsssGlobalVars;


%% Transmit through channel 

if USESIM % Use only simulation
    
    if useFakeChannel % Use a Fake channel; easy to debug
        RxData_board = TxData_board;
    else % Use AWGN channel for simulation
        % RxData_board = awgn(TxData_board, SIMSNR);
        noise_power = 10.0 ^ (-SIMSNR/20.0);
        normal_noise = normrnd(0, 1, 1, length(TxData_board)) + sqrt(-1) * normrnd(0, 1, 1, length(TxData_board));
        normal_noise = normal_noise / max(abs(normal_noise));
        noise = noise_power * normal_noise;
        RxData_board = TxData_board + noise;
        
        % If we need to add random frequency offset
        if addFreqOffset
            RxData_board = RxData_board .* exp(2 * sqrt(-1) * pi * freq_offset_val * rand(1) / Fs * (0 : length(RxData_board) - 1));
        end
    end
   
    
else % Use plain WARP board to transmit and receive
    
    if WURC % Use WURC board for transmission and reception
        
        if length(TxData_board) < WURC_TxLength
            TxData_board = [TxData_board zeros(Txparams.numAntenna, WURC_TxLength - ...
                length(TxData_board))];
        end
        
        wl_basebandCmd(WURC_node_tx, [WURC_RF_TX], 'write_IQ', TxData_board.');
        
        wl_wsdCmd(WURC_node_tx,  'tx_en', WURC_RF_TX);
        wl_wsdCmd(WURC_node_rx, 'rx_en', WURC_RF_RX);

        wl_basebandCmd(WURC_node_tx, WURC_RF_TX,'tx_buff_en');
        wl_basebandCmd(WURC_node_rx, WURC_RF_RX,'rx_buff_en');

        WURC_eth_trig.send();

        RxData_board = wl_basebandCmd(WURC_node_rx, [WURC_RF_RX],'read_IQ', 0, WURC_TxLength + WURC_TxDelay);
        RxData_board = RxData_board.';
        
    else % Use WARP board for transmission and reception
    
        if length(TxData_board) < WARPLab_TxLength
            TxData_board = [TxData_board zeros(Txparams.numAntenna, WARPLab_TxLength - ...
                length(TxData_board))];
        end

        % assign the data to transmit
        wl_basebandCmd(WARPLab_node_tx(1), WARPLab_RF_vector, 'write_IQ', TxData_board.');

        % start transmission and reception
        wl_interfaceCmd(WARPLab_node_tx, sum(WARPLab_RF_vector),'tx_en');
        wl_interfaceCmd(WARPLab_node_rx, sum(WARPLab_RF_vector),'rx_en');

        wl_basebandCmd(WARPLab_node_tx, sum(WARPLab_RF_vector),'tx_buff_en');
        wl_basebandCmd(WARPLab_node_rx, sum(WARPLab_RF_vector),'rx_buff_en');

        WARPLab_eth_trig.send();

        % get the received data
        RxData_board = wl_basebandCmd(WARPLab_node_rx(1), WARPLab_RF_vector, 'read_IQ', 0,...
                                                                WARPLab_TxLength+WARPLab_TxDelay);
        RxData_board = RxData_board.';
    
    end
    
end

end