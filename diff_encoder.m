function [encoded] = diff_encoder(input, modulus)

last_out = 0;
for i = 1:length(input)
    encoded(i) = mod((last_out + input(i)), modulus);
    last_out = encoded(i);
end

end