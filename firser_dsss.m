function psk_mod_sym = firser_dsss(dsss_code_len, dsss_mod_sym)

%% Read global variables
adsssGlobalVars;


%% Demodulate using DSSS sequence

dsss_taps = firdes_dsss_taps(SPB * dsss_code_len, dsss_code_len);
% Reverse DSSS taps for match filtering
% dsss_taps = fliplr(dsss_taps);
psk_mod_sym = firser_fir_filter_ccf(1, dsss_taps, dsss_mod_sym);

end