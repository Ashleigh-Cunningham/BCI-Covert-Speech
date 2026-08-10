numSets = 10;
numMatchesNeeded = 6;
commonalities = [];
conditionNames = {'Overt','Covert'};

tableExportCondition = []; % for exporting the data to an excel sheet
tableExportRegion = [];
tableExportBand = [];
tableExportAv = [];
tableExportInc = [];
tableExportDec = [];

taskWindow = [0 2.5];
baseWindow = [4 4.97];
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

%Loading a set with no channels deleted to get assess to all instead of
%only ones present in last participant
EEGALLCHANS = pop_loadset('filename', 'merged_participant6.set', 'filepath', 'C:\Users\cunni\ds003626-download\Matlab for Exp\Participant 6\');
EEGALLCHANS = pop_chanedit(EEGALLCHANS, 'load', {'C:\Users\cunni\Downloads\Channel Locations_TMSi.ced', 'filetype', 'autodetect'});
EEGALLCHANS= pop_select(EEGALLCHANS, 'nochannel',{'ExG62','ExG63','ExG64','BIP65','BIP66','BIP67','BIP68','AUX69','AUX70','AUX71','AUX72','Digi','Saw'});
masterChanLabels = {EEGALLCHANS.chanlocs.labels};


for cond = 1:2
    fprintf("\n CONDITION %d\n", cond);
    for i = 1:numSets
        partID = i + 4;
        filePath = sprintf('C:\\Users\\cunni\\ds003626-download\\Matlab for Exp\\Participant %d\\', partID);
        fileName = sprintf('participant%d_FINALEPOCHS.set', partID);
        EEGOUT = pop_loadset('filename', fileName, 'filepath', filePath);

        if rem(i,2) == 0 % if even, covert first
            overt = [7 8 9 10 11 12 19 20 21 22 23 24 31 32 33 34 35 36 43 44 45 46 47 48 55 56 57 58 59 60 ...
                67 68 69 70 71 72 79 80 81 82 83 84 91 92 93 94 95 96 103 104 105 106 107 108 115 116 117 118 ...
                119 120 127 128 129 130 131 132 139 140 141 142 143 144 151 152 153 154 155 156 163 164 165 166 ...
                167 168 175 176 177 178 179 180 187 188 189 190 191 192 199 200 201 202 203 204 211 212 213 214 ...
                215 216 223 224 225 226 227 228 235 236 237 238 239 240];
        else %overt first
            overt = [1 2 3 4 5 6 13 14 15 16 17 18 25 26 27 28 29 30 37 38 39 40 41 42 49 50 51 52 53 54 61 ...
                62 63 64 65 66 73 74 75 76 77 78 85 86 87 88 89 90 97 98 99 100 101 102 109 110 111 112 113 ...
                114 121 122 123 124 125 126 133 134 135 136 137 138 145 146 147 148 149 150 157 158 159 160 ...
                161 162 169 170 171 172 173 174 181 182 183 184 185 186 193 194 195 196 197 198 205 206 207 ...
                208 209 210 217 218 219 220 221 222 229 230 231 232 233 234];
        end

        overt = overt(overt <= size(EEGOUT.data, 3));

        if cond == 2 % covert removing overt
            deleteTrials = overt;
        else
            deleteTrials = setdiff(1:size(EEGOUT.data, 3), overt);
        end

        for b = 1:length(bands) % Epochs with artifacts that slipped through preporocessing and function below, ound through
            % manual checking of the EEG Plot
            if cond == 1 && ((b == 1 && (i == 6 || i == 8)) || (b == 5 && (i == 1 || i == 8)) || (b == 6 && i == 8))
                if  i == 1
                    deleteTrials(end+1) = 37;
                    deleteTrials(end+1) = 126;
                    deleteTrials(end+1) = 157;
                    deleteTrials(end+1) = 158;
                    deleteTrials(end+1) = 159;
                    deleteTrials(end+1) = 160;
                    deleteTrials(end+1) = 161;
                    deleteTrials(end+1) = 169;
                    deleteTrials(end+1) = 170;
                    deleteTrials(end+1) = 171;
                    deleteTrials(end+1) = 181;
                elseif i == 6
                    deleteTrials(end+1) = 31;
                    deleteTrials(end+1) = 79;
                elseif i == 8
                    deleteTrials(end+1) = 44;
                    deleteTrials(end+1) = 81;
                    deleteTrials(end+1) = 84;
                    deleteTrials(end+1) = 175;
                    deleteTrials(end+1) = 191;
                    deleteTrials(end+1) = 216;
                end
                deleteTrials = unique(deleteTrials);
            end
        end

        EEGOUT = pop_select(EEGOUT, 'trial', setdiff(1:size(EEGOUT.data, 3),deleteTrials));
        EEGOUT = eeg_checkset(EEGOUT);
        fs = EEGOUT.srate;
        chanLabels = {EEGOUT.chanlocs.labels};
        time = EEGOUT.times / 1000;
        taskIndex = time >= taskWindow(1) & time <= taskWindow(2); % power value during overt / covert speech
        baseIndex = time >= baseWindow(1) & time <= baseWindow(2); % Period after response to get baseline brain activity
        powerTask = zeros(length(EEGALLCHANS.chanlocs), length(bands));
        powerBase = zeros(length(EEGALLCHANS.chanlocs), length(bands));
        powerNorm = zeros(length(EEGALLCHANS.chanlocs), length(bands)); % each power value in relation to their baseline

        for b = 1:length(bands)
            filtEEG = pop_eegfiltnew(EEGOUT, bands{b}(1), bands{b}(2)); %filtering results
            for r = 1:length(EEGALLCHANS.chanlocs)
                chanList = regions.All{r};
                chanIdx = find((ismember(chanLabels, chanList)));
                chanSignal = mean(filtEEG.data(chanIdx,:,:),1); % identifying signal in each channel
                chanSignal = squeeze(chanSignal); %removed third dimension of 1 to condense data
                taskPowerVal = mean(chanSignal(taskIndex,:).^2, 'all'); % taking signal and turning to power values
                basePowerVal = mean(chanSignal(baseIndex,:).^2, 'all');
                normVal = 100*(taskPowerVal - basePowerVal) ./ (abs(basePowerVal) + 1e-10); %percentage of change compared to the baseline

                powerTask(r,b) = taskPowerVal;
                powerBase(r,b) = basePowerVal;
                powerNorm(r,b) = normVal;
            end
        end
        allResults(cond,i).subject = partID;
        allResults(cond,i).taskPower = powerTask;
        allResults(cond,i).baselinePower = powerBase;
        allResults(cond,i).normPower = powerNorm;
        % Checking for any artifacts the preprocessing may have missed
        removeTrials = [];
        [EEGOUTFUNC, allResultsFunc] = checkForSpikes(i,cond,EEGOUT, EEGALLCHANS, bandNames, regions, allResults, bands, removeTrials, partID);
        EEGOUT = EEGOUTFUNC;
        allResults = allResultsFunc;

        fprintf("Participant %d done\n", partID);
    end
end
for cond = 1:2  %displaying power values
    currCond = cond;
    for i = 1:numSets
        currPar = i;
        numIncrease = zeros(length(EEGALLCHANS.chanlocs),6);
        numDecrease = zeros(length(EEGALLCHANS.chanlocs),6);
        if cond == 1
            printCondition = "Overt";
        else
            printCondition = "Covert";
        end
        averageChange = zeros(length(EEGALLCHANS.chanlocs),6); % calculating the average to compare each signal to to see any outliers
        vals = zeros(1,numSets);
        for r = 1:length(EEGALLCHANS.chanlocs)
            for b = 1:length(bands)
                vals = zeros(1,numSets);
                vals(1,i) = allResults(cond,i).normPower(r,b);
                if ~isnan(allResults(cond,i).normPower(r,b))
                    if (allResults(cond,i).normPower(r,b)) > 0
                        numIncrease(r,b) = numIncrease(r,b) + 1;
                    elseif (allResults(cond,i).normPower(r,b)) < 0
                        numDecrease(r,b) = numDecrease(r,b) + 1;
                    end
                end
                averageChange(r,b) = mean(vals,'all', 'omitnan');
            end
        end
        for r = 1:length(EEGOUT.chanlocs)
            channelNum = string(chanLabels(r));
            for b = 1:length(bands)
                if b == 1
                    printBandName = "Delta";
                elseif b == 2
                    printBandName = "Theta";
                elseif b == 3
                    printBandName = "Alpha";
                elseif b == 4
                    printBandName = "Beta";
                elseif b == 5
                    printBandName = "Low Gamma";
                elseif b == 6
                    printBandName = "High Gamma";
                end
                if ~isnan(averageChange(r,b))
                    if numIncrease(r,b) > 0
                        region = r;
                        band = b;
                        fprintf('%s, increase in region %s, band %s with an average of %.4f%% : %d increased %d decreased \n', ...
                            printCondition, channelNum, printBandName, averageChange(r,b), numIncrease(r,b), numDecrease(r,b));
                        tableExportCondition(end+1, 1) = cond;
                        tableExportRegion(end+1, 1) = r;
                        tableExportBand(end+1, 1) =  b;
                        tableExportAv(end+1, 1) = averageChange(r,b);
                        tableExportInc(end+1, 1) = numIncrease(r,b);
                        tableExportDec(end+1, 1) = numDecrease(r,b);

                    elseif numDecrease(r,b) > 0
                        region = r;
                        band = b;
                        fprintf('%s, DECREASE in region %s, band %s with an AVERAGE OF %.4f%% : %d increased %d decreased \n', ...
                            printCondition, channelNum, printBandName, averageChange(r,b), numIncrease(r,b), numDecrease(r,b));
                        tableExportCondition(end+1, 1) = cond;
                        tableExportRegion(end+1, 1) = r;
                        tableExportBand(end+1, 1) =  b;
                        tableExportAv(end+1, 1) = averageChange(r,b);
                        tableExportInc(end+1, 1) = numIncrease(r,b);
                        tableExportDec(end+1, 1) = numDecrease(r,b);
                    end
                end
            end
        end
        % exporting to an excel sheet
        tableInfo = table(tableExportCondition, tableExportRegion, tableExportBand, tableExportAv, tableExportInc, tableExportDec);
        tableInfo(:,6)
        writetable(tableInfo, 'TDPops.xlsx');
        %prepping to make the topomaps per band per participant
        tdTopo = nan(length(EEGALLCHANS.chanlocs),length(bands));
        topoData = nan(length(EEGALLCHANS.chanlocs), length(bands));

        for r = 1:length(EEGALLCHANS.chanlocs)

            regionChannels = regions.All{r};
            [isFound, channelIndices] = ismember(regionChannels, masterChanLabels); % looking for if each channel is present in the current participant
            currChannelIndices = channelIndices(isFound);

            for b = 1:length(bands)
                averageNormPower = nan(1,numSets);
                covAverageNormPower = nan(1,numSets);
                tdOvertVals(r,b) = allResults(1,i).normPower(r,b); % storing data which will be in the topomaps
                tdCovertVals(r,b) = allResults(2,i).normPower(r,b);

                if cond == 1
                    if tdOvertVals(r,b) < 250
                        topoData(currChannelIndices,b) =  tdOvertVals(r,b);
                    else
                        topoData(currChannelIndices,b) = nan;
                    end
                else
                    if tdOvertVals(r,b) < 250
                        topoData(currChannelIndices,b) =  tdCovertVals(r,b);
                    else
                        topoData(currChannelIndices,b) = nan;
                    end
                end
            end
        end
        if ~exist('TopographicMaps','dir') % directory to save all topomaps to
            mkdir('TopographicMaps');
        end
    end
end

for cond = 1:2

    participantChange = nan(numSets, length(EEGALLCHANS.chanlocs), length(bands)); % creating the commonality topomaps

    for i = 1:numSets
        participantChange(i,:,:) = allResults(cond,i).normPower;
    end
    validParticipants = squeeze(sum(~isnan(participantChange), 1)); % get rid of the participants who have no data
    requiredMatches = ceil(0.70 * validParticipants);  % this makes it so 70% of participants must match to consider a commonality
    % checking to see if there are enough increases / decreases to consider

    increaseEnough = squeeze(sum(participantChange > 0, 1)) >= requiredMatches & squeeze(sum(participantChange > 0, 1)) > 0;
    decreaseEnough = squeeze(sum(participantChange < 0, 1)) >= requiredMatches & squeeze(sum(participantChange < 0, 1)) > 0;
    commonalityPresent = increaseEnough | decreaseEnough; % checks if either increase or decrease has a commonality
    avChange = squeeze(mean(participantChange, 1, 'omitnan'));

    topoVals = avChange;
    topoVals(~commonalityPresent) = NaN;

    figure('Name', conditionNames{cond});  % creates a topomap of only the channels which have commonalities averaged across all participants
    for b = 1:length(bands)
        maxLimit = max(abs(topoVals(:,b)),[],'omitnan');
        subplot(2,3,b); % allows for 6 topomaps in one image for comparison
        selectedChannels = find(commonalityPresent(:,b));
        if isempty(selectedChannels)
            topoplot([], EEGALLCHANS.chanlocs,'style','blank', 'electrodes','on');
            title(sprintf('%s\n no channels reached 70%%',bandNames{b}), 'Color','black');
        else
            bandValues = topoVals(:,b);
            topoplot(bandValues, EEGALLCHANS.chanlocs, 'plotchans', selectedChannels,'electrodes','labels','maplimits',[-maxLimit maxLimit]);
            title(sprintf('%s: %d channels', bandNames{b}, length(selectedChannels)), 'Color','black');
            c = colorbar;
            c.Color = [0,0,0];
        end
    end
    sgtitle(sprintf('All TD Participants %s', conditionNames{cond}), 'Color','black');
    exportTopo = fullfile('TopographicMaps',sprintf('All TD Participants %s.png', conditionNames{cond}));
    exportgraphics(gcf,exportTopo,'Resolution',600);
end

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
            regionSignal = squeeze(regionSignal); %removed third dimention of 1 to condense data
            taskPowerVal = mean(regionSignal(taskIndex,:).^2, 'all');
            basePowerVal = mean(regionSignal(baseIndex,:).^2, 'all');
            normVal = 100*(taskPowerVal - basePowerVal) ./ (abs(basePowerVal) + 1e-10);
            powerTask(r,b) = taskPowerVal;
            powerBase(r,b) = basePowerVal;
            powerNorm(r,b) = normVal;
        end
    end
    allResultsFunc(cond,i).subject = partID;
    allResultsFunc(cond,i).condition = cond-1;
    allResultsFunc(cond,i).taskPower = powerTask;
    allResultsFunc(cond,i).baselinePower = powerBase;
    allResultsFunc(cond,i).normPower = powerNorm;
    % clearing all trials marked for removal and calling the function again
    % to see if any were missed
    removeTrials = [];
    [EEGOUTFUNC, allResultsFunc] = checkForSpikes(i,cond,EEGOUTFUNC,EEGALLCHANS, bandNames, regions, allResultsFunc, bands, removeTrials, partID);
end
end

