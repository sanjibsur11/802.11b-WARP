% To generate payload suitable for TVWS ADSSS communications
% 
% Author: Sanjib Sur
% Institute: University of Wisconsin - Madison
% Version: 0.0.1
% Last modified: 06/22/2014
% 
% Comments: Payload generation for TVWS ADSSS PHY layer
% 

function [Payload] = generate_payload()


%% Read global variables
adsssGlobalVars;


%% Data generation

Payload = bi2de(reshape(inbits, 8, Txparams.numBitsTotal/8).', 'left-msb').';

end