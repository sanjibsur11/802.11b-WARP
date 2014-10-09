function [sinc_output] = firdes_dsss_sinc(numSamples, period)

f = -numSamples/2;

sinc_output = zeros(1, length(numSamples));

for i = 1:numSamples
    if f == 0
        sinc_output(i) = 1;
    else
        sinc_output(i) = period * sin(pi * f / period) / (f * pi);
    end
    f = f + 1.0;
end

end