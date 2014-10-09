% Modulation of packet content for TVWS ADSSS communication
% 
% Author: Sanjib Sur
% Institute: University of Wisconsin - Madison
% Version: 0.0.1
% Last modified: 06/22/2014
% 
% Comments: 
% 

function [modulated_packet] = modulate_packet(Packet)

%% Read global variables
adsssGlobalVars;


%% Modulation for the packet data bytes

% Bytes to bits
bytes2bits = de2bi(Packet, 8, 'left-msb');
packetbits = reshape(bytes2bits.', 1, length(Packet) * 8);
packetchunks = reshape(packetbits, bits_per_chunk, length(packetbits)/bits_per_chunk);

% Differential encoding
% bits converted to differential values and hence modulus 2 is used
packet_diff_encoded = diff_encoder(packetchunks, 2);

% Differential encoding to constellation samples
psk_mod_sym = constellation_mapping(packet_diff_encoded);

% Complex samples with DSSS filter
dsss_mod_sym = firdes_dsss(Txparams.DSSScodelen, psk_mod_sym);

modulated_packet = dsss_mod_sym;

end