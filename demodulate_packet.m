function [psk_demod_sym] = demodulate_packet(input)

%% Read global variables
adsssGlobalVars;


%% Demodulation of the packet to generate bits for FSM input

% Complex sample with DSSS filter
psk_mod_sym = firser_dsss(Txparams.DSSScodelen, input);

% Slice the output
psk_mod_sym_slice = slicer_cc(SPB * Txparams.DSSScodelen, 1, psk_mod_sym);

% Differential demodulation
psk_demod_sym = dpsk_demod_cb(psk_mod_sym_slice);


end