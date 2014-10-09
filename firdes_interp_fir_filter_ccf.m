function [output] = firdes_interp_fir_filter_ccf(interpolation, taps, input)

output = [];

xtaps = reshape(taps, interpolation, length(taps)/interpolation);
nfilters = interpolation;
filter_tap_len = length(taps)/interpolation;

for i = 1:length(input) - (filter_tap_len - 1)
    samples = input(i : i + filter_tap_len - 1);
    for nf = 1:nfilters
        filtered_out = xtaps(nf, :) * samples;
        output = [output filtered_out];
    end
end


end