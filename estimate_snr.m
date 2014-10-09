function snr = estimate_snr(dataPos)

%% Read global variables
adsssGlobalVars;


%% SNR estimation
snr = 0;
% Skip the first few syncs, as it might contain some zeros
skip_sync = 1;

% Extract energy in preamble
preamble_energy = RAW_ENERGY(dataPos - (8 * (length(PKT_SYNC_VECTOR) + length(PKT_SFD_VECTOR))):dataPos - 1);

% Extract energy from the sync vector
Z = preamble_energy(1:8*length(PKT_SYNC_VECTOR));
Z = Z(skip_sync + 1:end);

% Find signal+noise energy
L = length(Z);
SN = (1/2)*((sum(abs(Z))/L)^2);

% Find noise energy
N = (sum(Z.^2)/(L-1)) - (sum(abs(Z))^2/(L*(L-1)));

% Find the SNR
snr = 10*log10((SN-N)/N);


end