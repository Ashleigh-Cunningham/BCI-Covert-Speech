numSets = 10;
numPMCISets = 4;
deleteTrials = [];
taskWindow = [0 2.5]; % period where participant is responding co/overtly
baseWindow = [4 4.97]; % baseline brain activity when participant is focusing on quieting their mind
bands = {
    [1 4]    % Delta
    [4 8]    % Theta
    [8 12]   % Alpha
    [12 30]  % Beta
    [30 70]  % Low Gamma
    [70 130] % High Gamma
    };
bandNames = {'Delta','Theta','Alpha','Beta','Low Gamma','High Gamma'};
% Setting which channels are in what region of the brain
regions = struct();
regions.RightFrontal = {'FP2','AF4','AF8','F2','F4','F6','F8','FC2','FC4','FC6'};
regions.LeftFrontal  = {'FP1','AF3','AF7','F1','F3','F5','F7','FC1','FC3','FC5','FPZ','AFZ','FZ'};
regions.RightTemporal = {'FT8','T8','TP8'};
regions.LeftTemporal  = {'FT7','T7','TP7'};
regions.Occipital     = {'O1','OZ','O2'};
regions.RightParietal = {'CP2','CP4','CP6','P2','P4','P6','P8','PO4','PO8'};
regions.LeftParietal  = {'CP1','CP3','CP5','P1','P3','P5','P7','PO3','PO7','CPZ','PZ','POZ'};
regions.Central       = {'FCZ','CZ','C1','C2','C3','C4','C5','C6'};
regions.All           = {'FP2','AF4','AF8','F2','F4','F6','F8','FC2','FC4','FC6','FP1','AF3','AF7','F1','F3','F5','F7','FC1','FC3','FC5','FPZ','AFZ','FZ', ...
    'FT8','T8','TP8', 'FT7','T7','TP7', 'O1','OZ','O2', 'CP2','CP4','CP6','P2','P4','P6','P8','PO4','PO8', 'CP1','CP3','CP5','P1','P3','P5','P7', ...
    'PO3','PO7','CPZ','PZ','POZ', 'FCZ','CZ','C1','C2','C3','C4','C5','C6'};

regionNames = fieldnames(regions);
allResults = struct();
% Loading a set that has not been preprocessed so all channels are present
% to create a master list of all possible channels
EEGALLCHANS = pop_loadset('filename', 'merged_participant6.set', 'filepath', 'C:\Users\cunni\ds003626-download\Matlab for Exp\Participant 6\');
EEGALLCHANS = pop_chanedit(EEGALLCHANS, 'load', {'C:\Users\cunni\Downloads\Channel Locations_TMSi.ced', 'filetype', 'autodetect'});
EEGALLCHANS= pop_select(EEGALLCHANS, 'nochannel',{'ExG62','ExG63','ExG64','BIP65','BIP66','BIP67','BIP68','AUX69','AUX70','AUX71','AUX72','Digi','Saw'});
masterChanLabels = {EEGALLCHANS.chanlocs.labels};

for part = 1:numPMCISets


    filePath = sprintf('C:\\Users\\cunni\\ds003626-download\\PMCI%d\\', part);
    fileName = sprintf('participantPCMI%d_FINALEPOCHS.set', part);
    EEGOUT = pop_loadset('filename', fileName, 'filepath', filePath);
    EEGOUT = eeg_checkset(EEGOUT);
    %EEGOUT = pop_eegplot(EEGOUT);
     % Epochs with artifacts that slipped through preporocessing and function below, ound through
     % manual checking of the EEG Plot
            if  part == 1
                deleteTrials(end+1) = 10;
                deleteTrials(end+1) = 14;
                deleteTrials(end+1) = 17;
                deleteTrials(end+1) = 31;
                deleteTrials(end+1) = 47;
                deleteTrials(end+1) = 56;
                deleteTrials(end+1) = 61;
                deleteTrials(end+1) = 74;
                deleteTrials(end+1) = 75;
                deleteTrials(end+1) = 76;
                deleteTrials(end+1) = 99;
                deleteTrials(end+1) = 105;
                deleteTrials(end+1) = 110;
                deleteTrials(end+1) = 115;
                %{
                deleteTrials(end+1) = 6;
                deleteTrials(end+1) = 16;
                deleteTrials(end+1) = 57;
                deleteTrials(end+1) = 66;
                deleteTrials(end+1) = 90;
                deleteTrials(end+1) = 96;
                deleteTrials(end+1) = 51;
                deleteTrials(end+1) = 55;
                deleteTrials(end+1) = 62;
                %}
            elseif part == 2
                deleteTrials(end+1) = 2;
                deleteTrials(end+1) = 6;
                deleteTrials(end+1) = 20;
                deleteTrials(end+1) = 22;
                deleteTrials(end+1) = 49;
                deleteTrials(end+1) = 1;
                deleteTrials(end+1) = 12;
                deleteTrials(end+1) = 30;
                deleteTrials(end+1) = 60;
                deleteTrials(end+1) = 67;
                deleteTrials(end+1) = 18;
                deleteTrials(end+1) = 24;
                deleteTrials(end+1) = 40;
                deleteTrials(end+1) = 47;
            elseif part == 3
                deleteTrials(end+1) = 24;
                deleteTrials(end+1) = 26;
                deleteTrials(end+1) = 30;
                deleteTrials(end+1) = 37;
                deleteTrials(end+1) = 39;
                deleteTrials(end+1) = 76;
                deleteTrials(end+1) = 86;
                deleteTrials(end+1) = 90;
                deleteTrials(end+1) = 93;
                deleteTrials(end+1) = 108;
            elseif part == 4
                deleteTrials(end+1) = 44;
                deleteTrials(end+1) = 81;
                deleteTrials(end+1) = 84;
                deleteTrials(end+1) = 175;
                deleteTrials(end+1) = 191;
                deleteTrials(end+1) = 216;
            end
    deleteTrials = unique(deleteTrials);
    EEGOUT = pop_select(EEGOUT, 'trial', setdiff(1:size(EEGOUT.data, 3),deleteTrials));
    EEGOUT = eeg_checkset(EEGOUT);
    chanLabels = {EEGOUT.chanlocs.labels};
    time = EEGOUT.times / 1000;
    taskIndex = time >= taskWindow(1) & time <= taskWindow(2); % power value during overt / covert speech
    baseIndex = time >= baseWindow(1) & time <= baseWindow(2); % Period after response to get baseline brain activity
    powerTaskPMCI = nan(length(EEGALLCHANS.chanlocs), length(bands));
    powerBasePMCI = nan(length(EEGALLCHANS.chanlocs), length(bands));
    powerNormPMCI = nan(length(EEGALLCHANS.chanlocs), length(bands)); % each power value in relation to their baseline


    for b = 1:length(bands)
        filtEEG = pop_eegfiltnew(EEGOUT, bands{b}(1), bands{b}(2)); %filtering results
        for r = 1:length(EEGALLCHANS.chanlocs)
            chanList = regions.All{r};
            chanIdx = find((ismember(chanLabels, chanList)));
            chanSignal = mean(filtEEG.data(chanIdx,:,:),1); % identifying signal in each channel
            chanSignal = squeeze(chanSignal);
            taskPowerValPMCI = mean(chanSignal(taskIndex,:).^2, 'all'); % taking signal and turning to power values
            basePowerValPMCI = mean(chanSignal(baseIndex,:).^2, 'all');
            normValPMCI = 100*(taskPowerValPMCI - basePowerValPMCI) ./ (abs(basePowerValPMCI) + 1e-10); %percentage of change compared to the baseline

            powerTaskPMCI(r,b) = taskPowerValPMCI;
            powerBasePMCI(r,b) = basePowerValPMCI;
            powerNormPMCI(r,b) = normValPMCI;
        end
    end

    allResults(1,part).subject = part;
    allResults(1,part).taskPower = powerTaskPMCI;
    allResults(1,part).baselinePower = powerBasePMCI;
    if topoData(currChannelIndices,b) > 200
        break;
    end
    allResults(1,part).normPower = powerNormPMCI;
    removeTrials = [];
    % Checking for any artifacts the preprocessing may have missed
    [EEGOUTFUNC, allResultsFunc] = checkForSpikes(part,1,EEGOUT, EEGALLCHANS, bandNames, regions, allResults, bands, removeTrials, part);
    EEGOUT = EEGOUTFUNC;
    allResults = allResultsFunc;
    fprintf("PMCI participant %d done\n", part);

end
tableExportPMCI = [];
tableExportBand = [];
tableExportPMCIval = [];
currentChannel = [];

for part = 1:numPMCISets
    for r = 1:length(EEGOUT.chanlocs)
        channelNum = string(chanLabels(r));
        for b = 1:length(bands)
            PMCIval = allResults(1,part).normPower(r,b); %displaying power values
            fprintf('PMCI %d, region %s, band %s: PMCI %.4f%% \n', part, channelNum, bandNames{b}, PMCIval);
            tableExportPMCI(end+1,1) = part;
            tableExportBand(end+1,1) = b;
            tableExportPMCIval(end+1,1) = PMCIval;
        end
    end
end

tableInfo = table(tableExportPMCI, tableExportBand, tableExportPMCIval, ... %export to excel sheet
    'VariableNames', {'PMCI_Set','Band','PMCI_Value'});
writetable(tableInfo, 'PMCI.xlsx');

numChans = length(EEGALLCHANS.chanlocs);

for p = 1:numPMCISets
    topoData = nan(numChans, length(bands));

    for r = 1:length(EEGALLCHANS.chanlocs)

        regionChannels = regions.All{r};
        [isFound, channelIndices] = ismember(regionChannels, masterChanLabels); % looking for if each channel is present in the current participant
        currChannelIndices = channelIndices(isFound);

        for b = 1:length(bands)
            averageNormPower = nan(1,numPMCISets);
            for i = 1:numPMCISets
                averageNormPower(i) = allResults(1,i).normPower(r,b);
            end
                topoData(currChannelIndices,b) = allResults(1,p).normPower(r,b); % storing data which will be in the topomap
        end
    end
    if ~exist('TopographicMaps','dir') % directory to save all topomaps to
        mkdir('TopographicMaps');
    end
    figure('Name', sprintf('PMCI Participant %d All Bands', p));
    for b = 1:length(bands)
        subplot(2,3,b);
        maxVal = max(abs(topoData(:,b)),[],'omitnan'); % creating the individual band topomaps
        topoplot(topoData(:,b), EEGALLCHANS.chanlocs,'maplimits', [-maxVal maxVal],'electrodes', 'labels');
        colormap;
        c = colorbar;
        c.Color = [0,0,0];
        title(sprintf('PMCI covert - %s participant %d',bandNames{b}, p), 'Color', 'black');
    end
    sgtitle(sprintf('PMCI Participant %d', p), 'Color', 'black');
    exportgraphics(gcf, fullfile('TopographicMaps', sprintf('PMCI Participant %d All Bands.png', p)),'Resolution',600);
end

participantChange = nan(numPMCISets, length(EEGALLCHANS.chanlocs), length(bands)); % creating the commonality topomaps
for part = 1:numPMCISets
    participantChange(part,:,:) = allResults(1,part).normPower;
end
validParticipants = squeeze(sum(~isnan(participantChange), 1)); % get rid of the participants who have no data
requiredMatches = ceil(0.70 * validParticipants); % this makes it so 70% of participants must match to consider a commonality
% checking to see if there are enough increases / decreases to consider
% a commonality
increaseEnough = squeeze(sum(participantChange > 0, 1)) >= requiredMatches & squeeze(sum(participantChange > 0, 1)) > 0;
decreaseEnough = squeeze(sum(participantChange < 0, 1)) >= requiredMatches & squeeze(sum(participantChange < 0, 1)) > 0;
commonalityPresent = increaseEnough | decreaseEnough; % checks if either increase or decrease has a commonality
avChange = squeeze(mean(participantChange, 1, 'omitnan'));

topoVals = avChange;
topoVals(~commonalityPresent) = NaN;
validValues = topoVals(~isnan(topoVals));
validValuesInLimit = prctile(abs(validValues), 95); % takes only bottom 95% to restrict outliers
if isempty(validValuesInLimit)
    maxLimit = 1;
    warning('%s: no channels consistent in at least 70% of participants', part);
else
    maxLimit = max(abs(validValuesInLimit)); % max and min values for the colour bar
end

figure('Name', 'PMCI'); % creates a topomap of only the channels which have commonalities averaged across all participants
for b = 1:length(bands)
    subplot(2,3,b); % allows for 6 topomaps in one image for comparison
    selectedChannels = find(commonalityPresent(:,b));
    if isempty(selectedChannels)
        topoplot([], EEGALLCHANS.chanlocs,'style','blank', 'electrodes','on');
        title(sprintf('%s\n no channels consistent in at least 70% of participants', bandNames{b}));
    else
        bandValues = topoVals(:,b);
        topoplot(bandValues, EEGALLCHANS.chanlocs, 'plotchans', selectedChannels,'electrodes','labels','maplimits',[-maxLimit maxLimit]);
        title(sprintf('%s: %d channels', bandNames{b}, length(selectedChannels)), 'Color', 'black');
        colorbar;
    end
    sgtitle(sprintf('All PMCI Participants commonalities'), 'Color', 'black');
end
exportTopo = fullfile('TopographicMaps',sprintf('All PMCI Participants commonalities.png'));
exportgraphics(gcf,exportTopo,'Resolution',600);

%the function that recursively checks for any missed spikes
function[EEGOUTFUNC, allResultsFunc] = checkForSpikes(i,cond, EEGOUTFUNC, EEGALLCHANS, bandNames, regions, allResultsFunc, bands, removeTrials, partID)
for b = 1:length(bandNames)
    filtEEG = pop_eegfiltnew(EEGOUTFUNC, bands{b}(1), bands{b}(2));
    for r = 1:length(EEGALLCHANS.chanlocs)
        if abs(allResultsFunc(cond,i).normPower(r,b)) > 200 % if any values are over 200 uv, the expected limit, consider it an artifact
            chanLabel = regions.All{r};
            chanIdx = find(strcmpi({EEGOUTFUNC.chanlocs.labels}, chanLabel), 1);
            if isempty(chanIdx)
                continue; % if none are found, skip to end of loop
            end
            for tri = 1:EEGOUTFUNC.trials
                if any(abs(filtEEG.data(chanIdx,:,tri)) > 200)
                    removeTrials(end+1) = tri;
                end
            end
        end
    end
end

if ~isempty(removeTrials) % if any values over 200 uv were found
    removeTrials = unique(removeTrials); % ensuring no potential duplicates
    keepTrials = setdiff(1:size(EEGOUTFUNC.data, 3), removeTrials);
    EEGOUTFUNC = pop_select(EEGOUTFUNC, 'trial', keepTrials);
    EEGOUTFUNC = eeg_checkset(EEGOUTFUNC);
    taskWindow = [0 2.5];
    baseWindow = [4 4.97];
    chanLabels = {EEGOUTFUNC.chanlocs.labels};
    time = EEGOUTFUNC.times / 1000;
    taskIndex = time >= taskWindow(1) & time <= taskWindow(2);
    baseIndex = time >= baseWindow(1) & time <= baseWindow(2);
    powerTask = zeros(length(EEGALLCHANS.chanlocs), length(bands));
    powerBase = zeros(length(EEGALLCHANS.chanlocs), length(bands));
    powerNorm = zeros(length(EEGALLCHANS.chanlocs), length(bands));

    for b = 1:length(bands)
        filtEEG = pop_eegfiltnew(EEGOUTFUNC, bands{b}(1), bands{b}(2));
        for r = 1:length(EEGALLCHANS.chanlocs)
            chanList = regions.All{r};
            chanIdx = find((ismember(chanLabels, chanList)));
            regionSignal = mean(filtEEG.data(chanIdx,:,:),1);
            regionSignal = squeeze(regionSignal); %removed third dimension of 1 to condense data
            taskPowerVal = mean(regionSignal(taskIndex,:).^2, 'all');
            basePowerVal = mean(regionSignal(baseIndex,:).^2, 'all');
            normVal = 100*(taskPowerVal - basePowerVal) ./ (abs(basePowerVal) + 1e-10);
            powerTask(r,b) = taskPowerVal;
            powerBase(r,b) = basePowerVal;
            powerNorm(r,b) = normVal;
        end
    end
    allResultsFunc(1,i).subject = partID;
    allResultsFunc(1,i).taskPower = powerTask;
    allResultsFunc(1,i).baselinePower = powerBase;
    allResultsFunc(1,i).normPower = powerNorm;
    % clearing all trials marked for removal and calling the function again
    % to see if any were missed
    removeTrials = [];
    [EEGOUTFUNC, allResultsFunc] = checkForSpikes(i,cond,EEGOUTFUNC,EEGALLCHANS, bandNames, regions, allResultsFunc, bands, removeTrials, partID);
end
end

