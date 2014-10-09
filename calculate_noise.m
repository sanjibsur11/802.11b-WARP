function noise = calculate_noise(dataPos, bit_vector, RxData_board)

%% Read global variables
adsssGlobalVars;


%% Estimate noise
noise = 0;

% Extract Preamble by back-tracking
% For debugging
preamble_bits = bit_vector(dataPos - (8 * (length(PKT_SYNC_VECTOR) + length(PKT_SFD_VECTOR))):dataPos - 1);
preamble_sig = RxData_board((dataPos - (8 * (length(PKT_SYNC_VECTOR) + length(PKT_SFD_VECTOR))) - 1)*SPB*Txparams.DSSScodelen + 1:...
    (dataPos - 1)*SPB*Txparams.DSSScodelen);

% Extract the synchronization signals from the preamble
% Skip the first sync, as it might contain some zeros
skip_preamble = 1;
pkt_sync_sig = preamble_sig((1 + skip_preamble - 1)*8*SPB*Txparams.DSSScodelen + 1:8*length(PKT_SYNC_VECTOR)*SPB*Txparams.DSSScodelen);


short_preamble = zeros(length(PKT_SYNC_VECTOR)-skip_preamble, 8*SPB*Txparams.DSSScodelen);
% Find average Mean Squared Error in the received preambles
for i = 1:length(PKT_SYNC_VECTOR)-skip_preamble
    short_preamble(i, :) = pkt_sync_sig((i-1)*8*SPB*Txparams.DSSScodelen+1:i*8*SPB*Txparams.DSSScodelen);
end

% Find mutual Mean Squared Error
% mse = 0;
% for i = 1:length(PKT_SYNC_VECTOR)-skip_preamble
%     for j = 1:length(PKT_SYNC_VECTOR)-skip_preamble
%         mse = mse + sum(abs(short_preamble(i, :) - short_preamble(j, :)).^2);
%     end
% end
% 
% noise = mse/(length(PKT_SYNC_VECTOR)-skip_preamble)^2;

% Find mutual Variance
% for i = 1:length(PKT_SYNC_VECTOR)-skip_preamble
%     mse = mse + var(short_preamble(i,:));
% end

% noise = mse/(length(PKT_SYNC_VECTOR)-skip_preamble);


% Find mutual covariance
mse = 0;
for i = length(PKT_SYNC_VECTOR)-skip_preamble
    for j = 1:length(PKT_SYNC_VECTOR)-skip_preamble
        preamble1 = short_preamble(i,:);
        preamble2 = short_preamble(j,:);
        mse = mse + (sum(abs((preamble1 - mean(preamble1))).*abs((preamble2 - mean(preamble2))))/(length(preamble1) - 1));
    end
end

noise = mse/(length(PKT_SYNC_VECTOR)-skip_preamble)^2;



end