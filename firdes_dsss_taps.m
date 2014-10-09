function [dsss_taps] = firdes_dsss_taps(sample_rate, dsss_code_len)


%% Read global variables
adsssGlobalVars;


%% Calculate the taps
total_taps = sample_rate * dsss_code_len * 3;
mid_point = total_taps / 2;

ff = zeros(1, total_taps);

if sample_rate > dsss_code_len
    filter_period = sample_rate;
else
    filter_period = dsss_code_len;
end

% Generate the sinc pulses
ff = firdes_dsss_sinc(total_taps, sample_rate);

% Convolve expanded DSSS codes with the sinc pulse
result = zeros(1, sample_rate);
for i = 1:dsss_code_len
    for j = 1:sample_rate
        result(j) = result(j) + ff((i - 1) * sample_rate + mid_point - (j - 1) * dsss_code_len) * DSSSCode(i);
    end
end

% Normalize to +/- 1
max_val = max(abs(result));
dsss_taps = result/max_val;

end