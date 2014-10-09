function psk_demod_sym = dpsk_demod_cb(psk_mod_sym_slice)

%% Read global variables
adsssGlobalVars;


psk_demod_sym = [];
d_e_squared = 0;
d_sample_count = 0;
d_rssi = 0;
d_prev = 0;

% % First skip samples having low correlation thresholds
% for i = 1:length(psk_mod_sym_slice)
%     mag_squared = real(psk_mod_sym_slice(i)) ^ 2 + imag(psk_mod_sym_slice(i)) ^ 2;
%     if mag_squared < CORR_THRESHOLD
%         continue;
%     else
%         break;
%     end
% end
% 
% psk_mod_sym_slice = psk_mod_sym_slice(i:end);

% Padding at the end
len = length(psk_mod_sym_slice);
psk_mod_sym_slice = [psk_mod_sym_slice zeros(1, 8 - mod(len, 8))];
samples = psk_mod_sym_slice;

for j = 1:length(psk_mod_sym_slice)
    % samples = psk_mod_sym_slice((i - 1) * 8 + 1 : i * 8);
    bits = 0;
    % for j = 1:8
	mag_squared = real(samples(j)) ^ 2 + imag(samples(j)) ^ 2;
	d_e_squared = d_e_squared + mag_squared;
    
    RAW_ENERGY = [RAW_ENERGY mag_squared];
    
	d_sample_count = d_sample_count + 1;
    
    % Find RSSI every RSSI_AVE_COUNT samples
    if d_sample_count == RSSI_AVE_COUNT
        % RAW_ENERGY = [RAW_ENERGY d_e_squared];
        RSSI = [RSSI calculate_rssi(d_e_squared)];
        d_e_squared = 0;
        d_sample_count = 0;
    end
    
	innerProd = real(samples(j)) * real(d_prev) + imag(samples(j)) * imag(d_prev);
	bits = (innerProd <= 0);
	% byte = bitor(bitshift(byte, 1), ~(innerProd > 0));
	d_prev = samples(j);
    % end
    % psk_demod_sym = [psk_demod_sym byte];
    psk_demod_sym = [psk_demod_sym bits];
end


end