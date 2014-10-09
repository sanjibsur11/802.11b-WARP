function [dsss_mod_sym] = firdes_dsss(dsss_code_len, psk_mod_sym)

%% Read global variables
adsssGlobalVars;


%% Modulate using DSSS code sequence

dsss_taps = firdes_dsss_taps(SPB * dsss_code_len, dsss_code_len);
dsss_mod_sym = firdes_interp_fir_filter_ccf(SPB * dsss_code_len, dsss_taps, psk_mod_sym);


end