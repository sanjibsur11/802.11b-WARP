original_DSSSCode = [1.000000, -1.000000, 1.000000, 1.000000, -1.000000, 1.000000, 1.000000, 1.000000, -1.000000, -1.000000, -1.000000];
num_code = 9;
gen_DSSSCode = zeros(num_code, length(original_DSSSCode));

for i = 1:num_code
    gen_DSSSCode(i, :) = rand(1, length(original_DSSSCode));
    gen_DSSSCode(i, gen_DSSSCode(i, :) < 0.5) = -1;
    gen_DSSSCode(i, gen_DSSSCode(i, :) >= 0.5) = 1;
end