function [EEcp, PEcp, MPEcp, EffEEcp] = computeExposureProfiles(exposures)

% exposures is nCP-by-nSteps-by-nScen or nSteps-by-nScen

%[numCp, numSteps, numScenarios] = size(exposures);

if ndims(exposures) == 3
    scenDim = 3; stepDim = 2; 
else
    scenDim = 2; stepDim = 1;
end

% expProfile = zeros(numCp, numSteps);

% Peak Exposure (same as Potential Future Exposure)
PEcp   = prctile(exposures,95,scenDim);

% Maximum Peak Exposure
MPEcp   = max(PEcp,[],stepDim);

% Expected Exposure
EEcp   = mean(exposures,scenDim);

% Expected Positive Exposure: Weighted average over time of EE
% * In continuous time, this is the average expected exposures over time,
%   an integral of EE(t) over the time interval, divided by the length of
%   the interval
% * Compute using a "trapezoidal" approach here
% simTimeInterval = yearfrac(Settle, dates, 1);
% simTotalTime = simTimeInterval(end)-simTimeInterval(1);
% EPEcp   = 0.5*(EEcp(:,1:end-1)+EEcp(:,2:end))*diff(simTimeInterval)'/simTotalTime;

% Effective Expected Exposure: Max EE up to time simTimeInterval
% EffEEcp = zeros(size(EEcp));
% for i = 1:size(EEcp,1)
%     
%     % Compute cumulative maximum
%     m = EEcp(i,1);
%     for j = 1:size(EEcp,2)
%         if EEcp(i,j) > m
%             m = EEcp(i,j);
%         end
%         EffEEcp(i,j) = m;
%     end
%     
% end
EffEEcp = cummax(EEcp,stepDim);

% Effective Expected Positive Exposure: Weighted average over time of EffEE
%EffEPEcp   = 0.5*(EffEEcp(:,1:end-1)+EffEEcp(:,2:end))*diff(simTimeInterval)'/simTotalTime;
%EffEPEport = 0.5*(EffEEport(1:end-1)+EffEEport(2:end))*diff(simTimeInterval)'/simTotalTime;
