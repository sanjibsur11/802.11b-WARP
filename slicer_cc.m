function psk_mod_sym_slice = slicer_cc(samples_per_symbol, num_symbols, input)

%% Read global variables
adsssGlobalVars;


psk_mod_sym_slice = [];

d_samples_per_symbol = samples_per_symbol;
d_sample_block_size = num_symbols * d_samples_per_symbol;
d_symbol_index = 0;
d_sums = zeros(1, d_samples_per_symbol);
d_offset = 0;
d_f_offset = 0.0;
d_f_samples_per_symbol = d_samples_per_symbol + 0.0;
d_gain = 0.75;

% TODO: Skip first few samples having low energy. How do I choose the
% proper threshold?
sample_points = [];

samples_to_process = length(input);

while samples_to_process > 0
    
    if ((samples_to_process + d_symbol_index) >= d_sample_block_size)
        ntaps = (d_sample_block_size - d_symbol_index);
    else
        ntaps = samples_to_process;
    end
    
	for i = 1:ntaps/d_samples_per_symbol
        for j = 1:d_samples_per_symbol
            d_sums(j) = d_sums(j) + (real(input(j)) ^ 2) + (imag(input(j)) ^ 2);
        end
        [max_val max_idx] = max(d_sums);
        psk_mod_sym_slice = [psk_mod_sym_slice input(max_idx)];
        sample_points = [sample_points max_idx];
        input = input(d_samples_per_symbol+1:end);
        d_sums = zeros(1, d_samples_per_symbol);
    end
	samples_to_process = samples_to_process - ntaps;
	d_symbol_index = 0;
end

% while samples_to_process > 0
%     
%     if((samples_to_process + d_symbol_index) >= d_sample_block_size)
%         ntaps = (d_sample_block_size - d_symbol_index);
%         for i = 1:ntaps/d_samples_per_symbol
%             for j = 1:d_samples_per_symbol
%                 d_sums(j) = d_sums(j) + (real(input(j)) ^ 2) + (imag(input(j)) ^ 2);
%             end
%             psk_mod_sym_slice = [psk_mod_sym_slice input(d_offset + 1)];
%             sample_points = [sample_points d_offset + 1];
%             input = input(d_samples_per_symbol+1:end);
%         end
%         
%         samples_to_process = samples_to_process - ntaps;
%         d_symbol_index = 0;
%         max_val = 0;
%         max_idx = 0;
%         [max_val max_idx] = max(d_sums);
%         
%         delta = max_idx - d_f_offset + 0.0;
%         if VERBOSE2
%             fprintf('d_f_offset IN = %f, delta = %f.\n', d_f_offset, delta);
%         end
%     
%         if abs(delta) > (d_f_samples_per_symbol * 0.5)
%             if delta > 0
%                 delta = delta - d_f_samples_per_symbol;
%             else
%                 delta = delta + d_f_samples_per_symbol;
%             end
%         end
%         d_f_offset = d_f_offset + d_gain * delta;
%         
%         while d_f_offset >= (d_f_samples_per_symbol - 0.5)
%             d_f_offset = d_f_offset - d_f_samples_per_symbol;
%         end
%         
%         while d_f_offset < -0.5
%             d_f_offset = d_f_offset + d_f_samples_per_symbol;
%         end
%         
%         d_offset = round(d_f_offset);
%         
%         if VERBOSE2
%             fprintf('Processed %d samples. d_f_offset = %f.\n', d_sample_block_size, d_f_offset);
%             fprintf('max_idx = %d, d_offset = %d.\n', max_idx, d_offset);
%         end
%     else
%         ntaps = samples_to_process;
%         for i = 1:ntaps/d_samples_per_symbol
%             for j = 1:d_samples_per_symbol
%                 d_sums(j) = d_sums(j) + (real(input(j)) ^ 2) + (imag(input(j)) ^ 2);
%             end
%             psk_mod_sym_slice = [psk_mod_sym_slice input(d_offset + 1)];
%             sample_points = [sample_points d_offset + 1];
%             input = input(d_samples_per_symbol+1:end);
%         end
%         
%         d_symbol_index = d_symbol_index + ntaps;
%         samples_to_process = 0;
% 
%     end
%     
% end

end