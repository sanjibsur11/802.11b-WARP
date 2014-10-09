% A configuration file to modify various parameters for the transmitter and
% receiver in TV white space adaptive DSSS WURC communication
% 
% Author: Sanjib Sur
% Institute: University of Wisconsin - Madison
% Version: 0.0.1
% Last modified: 06/22/2014
% 
% Comments: Various parameters handling file to have configuration across
% transmitter and receivers.
% 
% 

%% Read global variables
adsssGlobalVars;


%% Basic mode control
% Simulation control
USESIM = 1; % whether to use simulation/emulation or WARP board
% Whether to use WURC or WARP board
WURC = 0;
% Debugging control
% Show constellation or not
DEBUG_ON = 1;
% First level of print outs
VERBOSE1 = 1;
% Second level and detailed print outs
VERBOSE2 = 1;
% Suitable for debugging without adding noise to the signal
useFakeChannel = 0; % Use a fake channel to Debug
% Whether to add frequency offset in simulaton
addFreqOffset = 10;
% How much freq offset to add? In kHz
freq_offset_val = 1;
% Whether to use trace driven channel estimation results
TRACE_DRIVEN = 0;
% Whether to perform regression test with the channel trace files
TRACE_DRIVEN_REGRESSION = 0;
% Whether to collect trace of the channels to later use for emulation
TRACE_COLLECT = 0;


% Parameters check
assert((USESIM == 0 || USESIM == 1), 'USESIM = 0 or USESIM = 1');
assert((DEBUG_ON == 0 || DEBUG_ON == 1), 'DEBUG_ON = 0 or DEBUG_ON = 1');
assert(~(VERBOSE1 == 0 && VERBOSE2 == 1), 'Assign VERBOSE1 = 1 before assigning VERBOSE2 = 1');
assert(~(USESIM == 0 && useFakeChannel == 1), 'Assign USESIM == 1 before assigning useFakeChannel = 1');
assert(~(USESIM == 0 && TRACE_DRIVEN == 1), 'Assign USESIM == 1 before assigning TRACE_DRIVEN = 1');
assert(~(USESIM == 1 && TRACE_COLLECT == 1), 'Simulation should be OFF before collecting traces');
assert(~(TRACE_DRIVEN && TRACE_COLLECT), 'Can not enable both trace driven and trace collection simulteneously!');
assert(~(TRACE_DRIVEN && useFakeChannel), 'Can not enable both trace driven and useFakeChannel simulteneously!');
% Will enable this assertion after I finish debugging the trace collection
% and trace driven emulation
assert(~(USESIM == 1 && TRACE_COLLECT == 1), 'Trace collection only from WARP board');
assert(~(USESIM == 1 && WURC == 1), 'Assign USESIM=0 before using WURC=1');



%% Preamble parameters
% Sync vector is of length 16 and each containing 0xff
PKT_SYNC_COUNT = 8;
PKT_SYNC_VECTOR = repmat(hex2dec('ff'), 1, PKT_SYNC_COUNT);

% Start of Frame Delimeter: 0x05cf
PKT_SFD_VECTOR = [hex2dec('05') hex2dec('cf')];

% R Start of Frame Delimeter: 0xf3a0
PKT_RSFD_VECTOR = [hex2dec('f3') hex2dec('a0')];

% Synchronization vector error threshold
SYNC_ERROR_THRESHOLD = 1;

% Skip first few ones
SKIP_ONES = 0;


%% Timing parameters
% Timing related parameters
Timeparams = [];


%% Transmitter and Receiver Configuration
Txparams = [];
Rxparams = [];

% PHY transmission modes
Txparams.PHYmode = 0;

% PHY DSSS code length to choose from
Txparams.DSSScodelen = 64;

% Number of data packets
Txparams.totalDataPkts = 1;

% Total number of data symbols
Txparams.numSymbTotal = 1024;

% We have neglect the last byte
% Txparams.numSymbTotal = 16 + 8;

% Modulation size: BPSK = 2, QAM = 4, 8-QAM = 8, 16-QAM = 16 etc.
Txparams.modulationM = 2;

% Number of bits per symbols
symb2BitNum = log2(Txparams.modulationM);

% Number of bits send by Tx
Txparams.numBitsTotal = Txparams.numSymbTotal * symb2BitNum;

% Number of antennas is always in SISO mode
if Txparams.PHYmode == 0
    Txparams.numAntenna = 1;
    Rxparams.numAntenna = 1;
end

% Parameters check
assert(log2(Txparams.modulationM)-floor(log2(Txparams.modulationM)) == 0, 'modulationM should be power of 2');
% Assert that the number of bit is multiple of bytes
assert(mod(Txparams.numBitsTotal, 8) == 0, 'Number of bits is not multiple of 8');


%% Simulation parameters
% Do we need any oversampling?
if USESIM
    osamp = 1;
else
    % Oversampling is required when transmitting through WARP board
    osamp = 1;
end

% Intended simulation SNR per antennas
SIMSNR = [0];

% Sampling frequency: In kHz
Fs = 20e3;


%% Packet detection parameters
CORR_THRESHOLD = 1;


%% Initialization of WARP radio parameters

% We need to initialize separately if we are using WURC daughter board
if ~USESIM
    
    if WURC % If WURC board is used
        
        WURC_FLAG_IS_BOARD_GREEN = false; % XU, Change this for your hardware!!
        WURC_USE_AGC = 1;
        WURC_gainTX_wsd_n = 10; % [1:30]
        WURC_gainRX_wsd_db = 0; % [1:60]

        WURC_gainRX_warp_rf = 2;
        WURC_gainRX_warp_bb = 30;

        WURC_agc_WARP_target = -15;
        WURC_agc_WSD_target = -15;

        % Using Channel 17, which is unoccupied near Engineering Drive
        WURC_channel_wsd = 490000; % Enter in kHz
        
        % Add some delays
        WURC_TxDelay = 1000;
        % WURC buffer size 32k
        WURC_TxLength = 2^15 - WURC_TxDelay; % Length of transmission. In [0:2^15-1-TxDelay]

        %                     rx_RSSI_wsd(:,i) =  wl_process_rssi(wl_basebandCmd(nc.allRx(i),nc.RAD_WSDA,'read_RSSI',0,nc.txLength/4));
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Set up the WARPLab experiment
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        WURC_NUMNODES = 2;

        % %Create a vector of node objects
        WURC_nodes = wl_initNodes(WURC_NUMNODES); % INITIALIZE WL NODES

        wl_setWsd(WURC_nodes);    % Set nodes as WSD enabled nodes
        wl_wsdCmd(WURC_nodes, 'initialize'); % Initialize WSD Nodes


        %Create a UDP broadcast trigger and tell each node to be ready for it
        WURC_eth_trig = wl_trigger_eth_udp_broadcast;
        wl_triggerManagerCmd(WURC_nodes,'add_ethernet_trigger',[WURC_eth_trig]);

        %Get IDs for the interfaces on the boards. Since this example assumes each
        %board has the same interface capabilities, we only need to get the IDs
        %from one of the boards
        [WURC_RAD_WARP_24a, WURC_RAD_WARP_24b, WURC_RAD_WSDA, null] = wl_getInterfaceIDs(WURC_nodes(1));

        %Set up the interface for the experiment
        % wl_interfaceCmd(nodes,'RF_ALL','tx_gains',3,30);
        wl_wsdCmd(WURC_nodes, 'tx_gains', WURC_RAD_WSDA, WURC_gainTX_wsd_n, 99); % the 99 is a hack.  leave it.
        % wl_interfaceCmd(nodes,'RF_ALL','channel',2.4,11);
        wl_wsdCmd(WURC_nodes, 'channel', WURC_RAD_WSDA, WURC_channel_wsd);




        if(WURC_USE_AGC)

            wl_basebandCmd(WURC_nodes,'agc_reset');
            wl_interfaceCmd(WURC_nodes, WURC_RAD_WARP_24a,'rx_gain_mode','automatic');
            wl_basebandCmd(WURC_nodes,'agc_target', WURC_agc_WARP_target);
            wl_basebandCmd(WURC_nodes,'agc_trig_delay', 511);

            wl_wsdCmd(WURC_nodes,'rx_gain_mode', WURC_RAD_WSDA, 'automatic');
            wl_wsdCmd(WURC_nodes,'agc_target', WURC_agc_WSD_target);
            wl_wsdCmd(WURC_nodes,'agc_trig_delay', 511);
            %     wl_wsdCmd(nodes,'agc_thresh', 100, 250, 1, 4);
            wl_wsdCmd(WURC_nodes,'agc_thresh', 100, 1, 1, 4);
            wl_wsdCmd(WURC_nodes,'agc_reset');

            % Enable HOLD mode for AGC trigger
        %     wl_triggerManagerCmd(nodes, 'output_config_hold_mode',[T_OUT_AGC],'enable');

        else
            % **** TODO: ADD WSD MODIFICATIONS HERE

            wl_interfaceCmd(WURC_nodes, WURC_RAD_WARP_24a,'rx_gain_mode','manual');
            %     wl_interfaceCmd(nodes, RAD_WARP_24,'rx_gains',gainRX_warp_rf,gainRX_warp_bb);
            wl_interfaceCmd(WURC_nodes, WURC_RAD_WARP_24a,'rx_gains',WURC_gainRX_warp_rf,WURC_gainRX_warp_bb);
            wl_wsdCmd(WURC_nodes, 'rx_gain_mode', WURC_RAD_WSDA, 'manual');
            %     wl_wsdCmd(nodes(4), 'rx_gains', RAD_WSDA, gainRX_wsd_J, gainRX_wsd_K);
            %     wl_wsdCmd(nodes(3), 'rx_gains', RAD_WSDA, gainRX_wsd_db, 0);
            wl_wsdCmd(WURC_nodes, 'rx_gains', WURC_RAD_WSDA, WURC_gainRX_wsd_db);


        end





        % wl_interfaceCmd(nodes,'RF_ALL','rx_gain_mode','manual');
        % wl_wsdCmd(nodes, 'rx_gain_mode', RAD_WSDA, 'manual'); % Both WARP and WSD need to know they are in MGC

        % RxGainRF = 1; %Rx RF Gain in [1:3]
        % RxGainBB = 15; %Rx Baseband Gain in [0:31]
        % wl_interfaceCmd(nodes,'RF_ALL','rx_gains',RxGainRF,RxGainBB);

        wl_wsdCmd(WURC_nodes, 'rx_gains', WURC_RAD_WSDA, WURC_gainRX_wsd_db);

        if(WURC_FLAG_IS_BOARD_GREEN)
            wl_wsdCmd(WURC_nodes, 'send_ser_cmd', WURC_RAD_WSDA, 'L', 2);
        else
             wl_wsdCmd(WURC_nodes, 'send_ser_cmd', WURC_RAD_WSDA, 'L', 0);
        end
        %We'll use the transmitter's I/Q buffer size to determine how long our
        %transmission can be
        txLength = WURC_nodes(1).baseband.txIQLen;

        %Set up the baseband for the experiment
        wl_basebandCmd(WURC_nodes, 'tx_delay', WURC_TxDelay);
        wl_basebandCmd(WURC_nodes, 'tx_length', WURC_TxLength);
        
        WURC_node_tx = WURC_nodes(1);
        WURC_node_rx = WURC_nodes(2);
        % RF_TX = RFA;
        % RF_RX = RFA;
        WURC_RF_TX = WURC_RAD_WSDA;
        WURC_RF_RX = WURC_RAD_WSDA;
        % RF_TX = RAD_WARP_24a;
        % RF_RX = RAD_WARP_24a;
        
        
    else % Is plain WARP board
    
        numTxNode = 1;
        numRxNode = 1;

        WARPLab_TxDelay = 1000;
        % WARPLab buffer size 32k
        WARPLab_TxLength = 2^15-WARPLab_TxDelay; % Length of transmission. In [0:2^15-1-TxDelay]
        WARPLab_CarrierChannel = 13; % Channel in the 2.4 GHz band. In [1:14] (avoid...
                             % 1 to 11); 5GHz in [15:37]
        WARPLab_TxGain_RF = 35; % Tx RF Gain. In [0:63] 
        WARPLab_TxGain_BB = 1; % Tx Baseband Gain. In [0:3]
        WARPLab_RxGain_BB = 15; % Rx Baseband Gain. In [0:31]
        WARPLab_RxGain_RF = 1; %2; % Rx RF Gain. In [1:3]

        WURC_USE_AGC = false;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Set up the WARPLab experiment
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Create a vector of node objects
        WARP_nodes = wl_initNodes(numRxNode + numTxNode);
        WARPLab_node_tx = WARP_nodes(1);
        WARPLab_node_rx = WARP_nodes(2:length(WARP_nodes));
        %{
        nodes = wl_initNodes(3);
        node_tx = nodes(2);
        node_rx = nodes(3);
        %}

        %Create a UDP broadcast trigger and tell each node to be ready for it
        WARPLab_eth_trig = wl_trigger_eth_udp_broadcast;
        wl_triggerManagerCmd(WARP_nodes,'add_ethernet_trigger',[WARPLab_eth_trig]);

        %Get IDs for the interfaces on the boards. Since this example assumes each
        %board has the same interface capabilities, we only need to get the IDs
        %from one of the boards
        [RFA,RFB] = wl_getInterfaceIDs(WARP_nodes(1));

        % Txparams.PHYmode: 0 SISO
        if Txparams.PHYmode == 0
            WARPLab_RF_vector = [RFA];
        elseif Txparams.PHYmode == 1
            if Txparams.numAntenna == 2
                WARPLab_RF_vector = [RFA RFB];
            end
        end

        %Set up the interface for the experiment
        wl_interfaceCmd(WARP_nodes,sum(WARPLab_RF_vector),'tx_gains',WARPLab_TxGain_BB,WARPLab_TxGain_RF);
        wl_interfaceCmd(WARP_nodes,sum(WARPLab_RF_vector),'channel',2.4,WARPLab_CarrierChannel);

        if(WURC_USE_AGC)
            wl_interfaceCmd(WURC_nodes,sum(WARPLab_RF_vector),'rx_gain_mode','automatic');
            wl_basebandCmd(WURC_nodes,'agc_target',-10);
            wl_basebandCmd(WURC_nodes,'agc_trig_delay', 500);
            wl_basebandCmd(WURC_nodes,'agc_dco', true);
        else
            wl_interfaceCmd(WARP_nodes,sum(WARPLab_RF_vector),'rx_gain_mode','manual');
            wl_interfaceCmd(WARP_nodes,sum(WARPLab_RF_vector),'rx_gains',WARPLab_RxGain_RF,WARPLab_RxGain_BB);
        end


        %We'll use the transmitter's I/Q buffer size to determine how long our
        %transmission can be
        %txLength = nodes(1).baseband.txIQLen;

        %Set up the baseband for the experiment
        wl_basebandCmd(WARP_nodes,'tx_delay',WARPLab_TxDelay);
        wl_basebandCmd(WARP_nodes,'tx_length',WARPLab_TxLength);
    
    end
    
end


%% Padding
padding_size = 108;
Padding = zeros(1, padding_size);

% assert(~(USESIM == 1 && useFakeChannel == 0 && padding_size < 64), 'padding_size should be atleast 64 samples in simulations');


%% Modulation parameters
% M-QAM modulation using communication toolbox
hmodem = modem.qammod('M', Txparams.modulationM);
% M-QAM demodulation using communication toolbox
hdemodem = modem.qamdemod('M', Txparams.modulationM);

% Bytes to bits mapping
bits_per_chunk = 1;



%% Initialize the Code book

if Txparams.DSSScodelen == 11
    % DSSSCode = [1.000000, -1.000000, 1.000000, 1.000000, -1.000000, 1.000000, 1.000000, 1.000000, -1.000000, -1.000000, -1.000000];
    DSSSCode = [-1     1     1     1    -1    -1     1    -1     1    -1    -1];
    % DSSSCode = [1     1     1     1    -1    -1     1    -1     1     1     1];
    % DSSSCode = [-1     1    -1     1    -1     1     1    -1    -1    -1     1];
    % DSSSCode = [-1    -1     1    -1     1    -1    -1    -1     1     1     1];
    % DSSSCode = [ 1     1     1    -1    -1     1     1    -1     1     1     1];
    % DSSSCode = [-1     1     1    -1     1    -1     1    -1     1     1     1];
    % DSSSCode = [-1    -1     1     1    -1    -1    -1     1    -1    -1     1];
    % DSSSCode = [ 1     1    -1    -1     1     1    -1    -1    -1    -1     1];
    % DSSSCode = [1     1    -1    -1     1     1     1     1     1    -1    -1];
elseif Txparams.DSSScodelen == 2
    DSSSCode = [1.000000, -1.000000];
elseif Txparams.DSSScodelen == 4
    DSSSCode = [1.000000, -1.000000, 1.000000, -1.000000];
elseif Txparams.DSSScodelen == 8
    DSSSCode = [-1.000000, 1.000000, -1.000000, 1.000000, 1.000000, 1.000000, 1.000000, -1.000000];
elseif Txparams.DSSScodelen == 16
    DSSSCode = [1.000000, -1.000000, -1.000000, -1.000000, -1.000000, 1.000000, -1.000000, -1.000000, 1.000000, -1.000000, -1.000000, -1.000000, 1.000000, -1.000000, -1.000000, 1.000000];
elseif Txparams.DSSScodelen == 32
    DSSSCode = [-1.000000, 1.000000, -1.000000, 1.000000, 1.000000, -1.000000, -1.000000, -1.000000, 1.000000, 1.000000, -1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, -1.000000, 1.000000, -1.000000, -1.000000, -1.000000, -1.000000, -1.000000, -1.000000, -1.000000, 1.000000, -1.000000, -1.000000, 1.000000, -1.000000, 1.000000, 1.000000];
elseif Txparams.DSSScodelen == 64
    DSSSCode = [1.000000, -1.000000, 1.000000, 1.000000, 1.000000, 1.000000, -1.000000, 1.000000, 1.000000, -1.000000, -1.000000, 1.000000, -1.000000, 1.000000, 1.000000, 1.000000, 1.000000, -1.000000, -1.000000, -1.000000, -1.000000, 1.000000, -1.000000, -1.000000, 1.000000, 1.000000, -1.000000, 1.000000, -1.000000, 1.000000, -1.000000, 1.000000, -1.000000, 1.000000, -1.000000, -1.000000, 1.000000, 1.000000, -1.000000, 1.000000, -1.000000, -1.000000, 1.000000, -1.000000, -1.000000, 1.000000, -1.000000, -1.000000, 1.000000, 1.000000, 1.000000, -1.000000, 1.000000, 1.000000, -1.000000, -1.000000, 1.000000, -1.000000, 1.000000, 1.000000, -1.000000, 1.000000, -1.000000, 1.000000];
elseif Txparams.DSSScodelen == 128
    DSSSCode = [-1.000000, -1.000000, 1.000000, -1.000000, 1.000000, -1.000000, -1.000000, 1.000000, 1.000000, -1.000000, -1.000000, 1.000000, -1.000000, 1.000000, 1.000000, 1.000000, -1.000000, -1.000000, 1.000000, -1.000000, 1.000000, -1.000000, -1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, -1.000000, 1.000000, 1.000000, 1.000000, -1.000000, 1.000000, -1.000000, -1.000000, -1.000000, 1.000000, 1.000000, 1.000000, 1.000000, -1.000000, -1.000000, -1.000000, 1.000000, 1.000000, -1.000000, -1.000000, 1.000000, -1.000000, -1.000000, 1.000000, 1.000000, -1.000000, 1.000000, -1.000000, 1.000000, -1.000000, 1.000000, 1.000000, 1.000000, 1.000000, -1.000000, 1.000000, -1.000000, -1.000000, 1.000000, 1.000000, 1.000000, -1.000000, -1.000000, 1.000000, -1.000000, -1.000000, 1.000000, -1.000000, 1.000000, -1.000000, -1.000000, -1.000000, 1.000000, -1.000000, 1.000000, 1.000000, -1.000000, -1.000000, 1.000000, 1.000000, -1.000000, -1.000000, -1.000000, 1.000000, 1.000000, -1.000000, 1.000000, 1.000000, -1.000000, -1.000000, -1.000000, 1.000000, -1.000000, 1.000000, 1.000000, -1.000000, 1.000000, -1.000000, -1.000000, -1.000000, -1.000000, -1.000000, -1.000000, 1.000000, -1.000000, -1.000000, -1.000000, -1.000000, -1.000000, 1.000000, 1.000000, -1.000000, 1.000000, -1.000000, 1.000000, -1.000000, -1.000000, -1.000000, 1.000000];
elseif Txparams.DSSScodelen == 256
    DSSSCode = [-1.000000, -1.000000, 1.000000, 1.000000, -1.000000, 1.000000, 1.000000, -1.000000, -1.000000, 1.000000, 1.000000, -1.000000, 1.000000, 1.000000, 1.000000, -1.000000, 1.000000, 1.000000, -1.000000, 1.000000, -1.000000, 1.000000, -1.000000, -1.000000, -1.000000, 1.000000, -1.000000, -1.000000, 1.000000, 1.000000, 1.000000, 1.000000, -1.000000, -1.000000, -1.000000, -1.000000, -1.000000, -1.000000, -1.000000, -1.000000, 1.000000, 1.000000, -1.000000, 1.000000, -1.000000, 1.000000, 1.000000, -1.000000, -1.000000, -1.000000, -1.000000, -1.000000, 1.000000, 1.000000, -1.000000, -1.000000, -1.000000, 1.000000, -1.000000, 1.000000, 1.000000, 1.000000, -1.000000, 1.000000, -1.000000, 1.000000, 1.000000, -1.000000, 1.000000, -1.000000, -1.000000, -1.000000, 1.000000, 1.000000, 1.000000, -1.000000, -1.000000, -1.000000, -1.000000, -1.000000, 1.000000, -1.000000, -1.000000, 1.000000, -1.000000, 1.000000, -1.000000, -1.000000, 1.000000, -1.000000, 1.000000, 1.000000, 1.000000, 1.000000, -1.000000, -1.000000, 1.000000, 1.000000, -1.000000, -1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, -1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, -1.000000, 1.000000, 1.000000, -1.000000, 1.000000, -1.000000, -1.000000, 1.000000, 1.000000, -1.000000, -1.000000, -1.000000, -1.000000, -1.000000, -1.000000, -1.000000, 1.000000, 1.000000, 1.000000, -1.000000, -1.000000, 1.000000, -1.000000, 1.000000, 1.000000, -1.000000, 1.000000, -1.000000, -1.000000, -1.000000, 1.000000, -1.000000, -1.000000, 1.000000, 1.000000, 1.000000, -1.000000, 1.000000, -1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, -1.000000, -1.000000, 1.000000, 1.000000, 1.000000, -1.000000, -1.000000, -1.000000, 1.000000, 1.000000, -1.000000, -1.000000, 1.000000, 1.000000, -1.000000, 1.000000, 1.000000, -1.000000, 1.000000, 1.000000, 1.000000, -1.000000, -1.000000, 1.000000, 1.000000, 1.000000, -1.000000, 1.000000, -1.000000, 1.000000, -1.000000, -1.000000, 1.000000, 1.000000, 1.000000, -1.000000, -1.000000, 1.000000, 1.000000, 1.000000, 1.000000, 1.000000, -1.000000, -1.000000, 1.000000, -1.000000, 1.000000, -1.000000, -1.000000, 1.000000, -1.000000, 1.000000, -1.000000, -1.000000, -1.000000, 1.000000, 1.000000, -1.000000, -1.000000, 1.000000, 1.000000, 1.000000, 1.000000, -1.000000, -1.000000, 1.000000, -1.000000, 1.000000, -1.000000, 1.000000, -1.000000, 1.000000, 1.000000, -1.000000, 1.000000, -1.000000, -1.000000, 1.000000, -1.000000, -1.000000, -1.000000, 1.000000, -1.000000, -1.000000, 1.000000, 1.000000, 1.000000, -1.000000, 1.000000, 1.000000, -1.000000, 1.000000, 1.000000, -1.000000, 1.000000, -1.000000, -1.000000, -1.000000, 1.000000, -1.000000, 1.000000];
end

codebook_len = [11 2 4 8 16 32 64 128 256];

% Assert that DSSS code length chosen is valid
assert(~isempty(codebook_len == Txparams.DSSScodelen), 'DSSS code is not valid!');


%% Samples per Baud
SPB = 8;


%% RSSI calculation

% Store RSSI values
RSSI = [];
% Raw energy for noise calculation
RAW_ENERGY = [];

% Packet SNR to be estimated from the preambles
PKT_SNR = 0;

RSSI_AVE_COUNT = 16;
RSSI_MAX = 0;

% Initialize log table to calculate the RSSI value from energy 
dB = 0.5;
j = 0;
LOG_TABLE = zeros(1, 64);
for i = 0:6
    threshold = ceil(10^(dB / 10) * 16);
    if threshold > 64
        threshold = 64;
    end
    while j < threshold
        LOG_TABLE(j + 1) = i;
        j = j + 1;
    end
    dB = dB + 1;
end