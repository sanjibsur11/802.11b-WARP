function outbits = decode_data_rx(dataPos, sigin)

%% Read global variables
adsssGlobalVars;


if dataPos == length(sigin)
    return;
end

outbits = sigin(dataPos:dataPos+length(inbits)-1);

end