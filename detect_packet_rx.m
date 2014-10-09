function [detect_pkt_flag dataPos] = detect_packet_rx(sigin)

%% Read global variables
adsssGlobalVars;


%% Synchronization vector decoding
detect_pkt_flag = 0;
dataPos = 0;

input_bit_vector = sigin;
packet_sync_vector = [PKT_SYNC_VECTOR PKT_SFD_VECTOR];
packet_sync_bit_vector = reshape(de2bi(packet_sync_vector, 8, 'left-msb').', 1, length(packet_sync_vector) * 8);
% Skip first few ones in the sync vector
packet_sync_bit_vector = packet_sync_bit_vector(SKIP_ONES + 1:end);

ns = 0;
min_error_val = Inf;
min_error_idx = 0;
while ns < length(input_bit_vector) - length(packet_sync_bit_vector)
    bit_vector = input_bit_vector(ns + 1 : ns + length(packet_sync_bit_vector));
    xor_val = sum(xor(bit_vector, packet_sync_bit_vector));
    if min_error_val >= xor_val
        min_error_idx = ns + 1;
        min_error_val = xor_val;
    end
    ns = ns + 1;
end

% min_error_val

if min_error_val > SYNC_ERROR_THRESHOLD
    return;
end

detect_pkt_flag = 1;
dataPos = min_error_idx + length(packet_sync_bit_vector);

% % Skip first zero samples
% first_one = find(de2bi(sigin, 8, 'left-msb') == 1, 1);
% sigin = sigin(first_one:end);
% sync_vector = sigin(1:PKT_SYNC_COUNT);
% error_matrix = xor(de2bi(sync_vector, 8, 'left-msb'), de2bi(PKT_SYNC_VECTOR, 8, 'left-msb'));
% sync_error = sum(error_matrix(:));
% 
% if sync_error/(PKT_SYNC_COUNT*8) > SYNC_ERROR_THRESHOLD
%     return;
% end
% 
% if PKT_SFD_VECTOR == sigin(PKT_SYNC_COUNT+1:PKT_SYNC_COUNT+2)
%     detect_pkt_flag = 1;
% else
%     return;
% end
% 
% dataPos = PKT_SYNC_COUNT+3;


end