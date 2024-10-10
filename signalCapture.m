function preambleStartLocation = signalCapture(inputSignal,upChirp,upChirpNum,FrameLength)
    % upChirp = [upChirp; upChirp; upChirp; upChirp];
    K = length(upChirp);
    windowLength = ceil(0.5*FrameLength + upChirpNum*length(upChirp));

    % Cross correlate
    rWin = inputSignal;
    Phat = abs(xcorr(rWin, upChirp));
    Rhat = xcorr(abs(rWin), ones(K,1));
    Phat = Phat./Rhat;

    % Remove leading and tail zeros overlaps
    M = Phat(ceil(length(Phat)/2):end-K/2+1);
    
    % Determine start of short preamble. First find peak locations
    MLocations = find(M > (max(M)*0.8));

    % Determine correct peaks
    peaks = zeros(size(MLocations));
    desiredPeakLocations = (K:K:(upChirpNum-2)*K)';
    for i = 1:length(MLocations)
        MLocationGuesses = MLocations(i) + desiredPeakLocations;
        peaks(i) = length(intersect(MLocations(i:end), MLocationGuesses));
    end

    % Have at least obj.pNumRequiredPeaks peaks for positive match    
    peaks(peaks < ceil(0.3*upChirpNum)) = 0;

    % Pick earliest peak in time
    [numPeaks, frontPeakLocation] = max(peaks);
    if ~isempty(peaks) && (numPeaks > 0)
        preambleStartLocation = MLocations(frontPeakLocation);
    else % No desirable location found
        preambleStartLocation = -1; 
    end
end

