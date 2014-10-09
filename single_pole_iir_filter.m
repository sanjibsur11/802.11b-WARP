% This file contains the implementation of single pole infinite impulse
% response filter
% 
% Author: Sanjib Sur
% Institution: University of Wisconsin - Madison
% Version: 0.0.1
% Last modified: 01/14/2014
% 
% Comments: 


function [filter_out] = single_pole_iir_filter(alpha, filter_in)

assert(alpha < 1);

filter_in = filter_in.';
filter_out = zeros(1, length(filter_in));

for fs = 2:length(filter_in)
    % computes y(i) = (1-alpha) * y(i-1) + alpha * x(i)
    filter_out(fs) = ((1-alpha)*filter_out(fs-1)) + (alpha*filter_in(fs));
end

filter_out = filter_out.';

end