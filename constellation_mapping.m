function [output] = constellation_mapping(input)

% Constellation points
Constellation = [1 + j, -1 - j];

% Constellation modulation
complex_samples = Constellation(input + 1);

% Reducing power
output = complex_samples / sqrt(2);

end