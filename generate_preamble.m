% To generate preambles suitable for TV white space adaptive DSSS
% communication
% 
% Author: Sanjib Sur
% Institute: University of Wisconsin - Madison
% Version: 0.0.1
% Last modified: 06/22/2014
% 
% Comments: Preamble generation for adaptive DSSS communication in TVWS
% 
% 

function [Preamble] = generate_preamble()


%% Read global variables
adsssGlobalVars;


%% Generate preamble by concatenating sync and sfd vectors
Preamble = [PKT_SYNC_VECTOR PKT_SFD_VECTOR];


end