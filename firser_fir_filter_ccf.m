function psk_mod_sym = firser_fir_filter_ccf(decimation, taps, input)

output = [];

% Pad some zeros at the end
input = [input zeros(1, length(taps) - mod(length(input), length(taps)))];

% TODO: Need to check correct implementation of the filter in GNURadio
filter_tap_len = length(taps);
input = decimate(input, decimation);
for i = 1:length(input) - (filter_tap_len - 1)
    samples = input(i : i + filter_tap_len - 1);
    filtered_out = taps * samples.';
    output = [output filtered_out];
end

psk_mod_sym = output;

end