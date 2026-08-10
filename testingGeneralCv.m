eeglab redraw; % "Cleans slate" of all past variables in variable log
EEG_1 = pop_biosig('C:\Users\cunni\ds003626-download\sub-04\ses-01\eeg\sub-04_ses-01_task-innerspeech_eeg.bdf'); %Importing data from bdf files to create data sets
EEG_2 = pop_biosig('C:\Users\cunni\ds003626-download\sub-04\ses-02\eeg\sub-04_ses-02_task-innerspeech_eeg.bdf');
EEG_3 = pop_biosig('C:\Users\cunni\ds003626-download\sub-04\ses-03\eeg\sub-04_ses-03_task-innerspeech_eeg.bdf');

[ALLEEG, EEGOUT] = eeg_store(ALLEEG, EEG_1, 1);
[ALLEEG, EEGOUT] = eeg_store(ALLEEG, EEG_2, 2);
[ALLEEG, EEGOUT] = eeg_store(ALLEEG, EEG_3, 3);

for i = 1:numel(ALLEEG)
    fprintf('Dataset %d: %d channels\n', i, size(ALLEEG(i).data,1));
end

EEGOUT = pop_mergeset(ALLEEG, [1 2 3], 0); %merging all sets into one
EEGOUT = pop_saveset(EEGOUT,'filename', 'patient4-alltrials.set','filepath', 'C:\Users\cunni\ds003626-download\sets\Participant 4');
EEGOUT = eeg_checkset(EEGOUT);

eventTypes = string({EEGOUT.event.type});
unique(string({EEGOUT.event.type}));

%%
innerTag = "22";  %start of inner speech trial
visTag = "23";    %start of visualised speech trial (where we want to end)
actionTag = "44"; %start of action interval
upTag = "31";     %participant was saying "up" in inner speech
downTag = "32";   %participant was saying "down" in inner speech
keepReading = false;

eventTypes = string({EEGOUT.event.type}); %noting the different event types (tags)

keepTags = []; %important events 
indexArr = [];
trialConditions = []; % up vs down markers for each kept trial

for i = 1:length(eventTypes)-1
    if eventTypes(i) == innerTag 
        keepReading = true; % if it's in the inner speech trials, look for up and down tags, else, ignore
    end
    if keepReading == true
        if eventTypes(i) == visTag
            keepReading = false; % if sees a vistag, indicates no longer in inner speech, therefore should stop and look for another innerTag
        end
        relDir = find(eventTypes(i+1:end) == upTag | eventTypes(i+1:end) == downTag, 1, 'first'); % finding first up / down tag
        dirIdx = i + relDir; % keeping track of what index it was found in

        nextAct = find(eventTypes(i+1:end) == actionTag, 1, 'first'); % finding the action interval after up / down cue was said
        if ~isempty(nextAct)
            actInt = i + nextAct;
            if keepReading == true
                indexArr = [indexArr; nextAct + i]; % only adding it to array if keepReading is true (discards any vis trials)

                if numel(indexArr) == numel(unique(indexArr)) % looks for unique events, doesnt count the same one multiple times
                    keepTags = [keepTags; actInt];
                    %fprintf("Number of items in keep is %d\n", length(keepTags))
                    if eventTypes(dirIdx) == upTag
                        fprintf("This trial is UP\n")
                        trialConditions = [trialConditions "up"];
                    elseif eventTypes(dirIdx) == downTag
                        fprintf("This trial is DOWN\n")
                        trialConditions = [trialConditions "down"];
                    end
                else
                    indexArr = unique(indexArr, 'stable'); % stays the same if the index was not unique
                end
            end
            %fprintf("44 paired at index %d\n", nextAct + i)
        end
    end
end



deleteTags = setdiff(1:length(EEGOUT.event), keepTags); %finding all tags that weren't kept
EEGOUT = pop_editeventvals(EEGOUT, 'delete', deleteTags);

eventTypes = string({EEGOUT.event.type});
uniqueTypes = unique(eventTypes);
%%

for i = 1:length(uniqueTypes)
    fprintf('%s: %d events\n', uniqueTypes(i), sum(eventTypes == uniqueTypes(i)));
end

EEGOUT = pop_saveset(EEGOUT, 'filename', 'set4-tagsIdentified.set','filepath', 'C:\Users\cunni\ds003626-download\sets\Participant 4');
%%
EEGOUT = pop_loadset('filename', 'set4_ICA.set','filepath', 'C:\Users\cunni\ds003626-download\sets\Participant 4\');
%%whos keepTags %checking twice to see if when loads set it disapears
EEGOUT = pop_select(EEGOUT, 'nochannel',{'EXG1','EXG2','EXG3','EXG4','EXG5','EXG6','EXG7','EXG8'}); %remove non EEG channels
EEGOUT = pop_chanedit(EEGOUT, 'load', {'C:\Users\cunni\ds003626-download\DatasetchannelLocs_ThinkingOutLoud.ced', 'filetype', 'autodetect'});

%%

EEGOUT = pop_resample(EEGOUT, 512);
EEGOUT = pop_reref( EEGOUT, []);
EEGOUT = pop_eegfiltnew(EEGOUT, 'locutoff',1); %highpass and lowpass filters
EEGOUT = pop_eegfiltnew(EEGOUT, 'hicutoff',130);
EEGOUT = pop_eegfiltnew(EEGOUT, 'locutoff',59,'hicutoff',61,'revfilt',1,'plotfreqz',0);
%EEGOUT = pop_runica(EEGOUT, 'icatype', 'runica', 'extended',1,'interrupt','on'); 
%EEGOUT = pop_saveset(EEGOUT, 'filename', 'set4_ICA.set', 'filepath', 'C:\Users\cunni\ds003626-download\sets\Participant 4');

%EEGOUT = pop_loadset('filename', 'set8_ICA.set','filepath', 'C:\Users\cunni\ds003626-download\sets\Participant 8\');
length(EEGOUT.chanlocs)
EEGOUT = eeg_checkset(EEGOUT);

[EEGOUT.chanlocs(1:5).X]' % showing example of x.y.z values for first 5 trials to make sure theres nothing wrong
[EEGOUT.chanlocs(1:5).Y]'
[EEGOUT.chanlocs(1:5).Z]'

whos keepTags

EEGOUT = pop_iclabel(EEGOUT, 'default');
EEGOUT = pop_icflag(EEGOUT, [NaN NaN;0.9 1;0.9 1;NaN NaN;NaN NaN;NaN NaN;NaN NaN]);
EEGOUT = pop_subcomp( EEGOUT, [], 0);

EEGOUT = pop_epoch( EEGOUT, {  '44'  }, [0         2.5], 'newname', 'Continuous Data TMSi Name: sub3 pruned with ICA epochs', 'epochinfo', 'no');
EEGOUT = pop_rmbase( EEGOUT, [],[]);
pop_eegplot( EEGOUT, 1, 1, 1); %plot channel scroll
EEGOUT = pop_saveset( EEGOUT, 'filename','set4_Preprocessed.set','filepath','C:\Users\cunni\ds003626-download\sets\Participant 4\');

whos keepTags %details about keeptags to make sure number and dimension of trials is known

%% Load EEG
rng(1)
fs = 512; ts = 1/fs; %adjusting sampling frequency
SampleNum = EEGOUT.pnts;
time = (0:SampleNum-1)*ts;
eeg=EEGOUT.data;

ID = 9; % Change ID NUMBER!!!!!!!

nChan = EEGOUT.nbchan; 
nTrials = EEGOUT.trials;
nSamples = SampleNum;
UpTrials = find(trialConditions == 'up');

DownTrials = find(trialConditions == 'down');
nUp = length(UpTrials);
nDown = length(DownTrials);

data1 = zeros(EEGOUT.nbchan, SampleNum, nUp);  %prepping for making datasets to test and train on
data2 = zeros(EEGOUT.nbchan, SampleNum, nDown);

for i = 1:nUp
    data1(:,:,i) = EEGOUT.data(:,:,UpTrials(i));
end

for i = 1:nDown
    data2(:,:,i) = EEGOUT.data(:,:,DownTrials(i));
end

%% Set up cross validation so CSP can be in each fold

Label = double(trialConditions(:) == "up"); %checks is trial conditions is up: if so, 1, if not, 0- just like our classification

cv = cvpartition(Label, 'KFold', 5, 'Stratify',true);
Freqband = [4 8; 8 12; 12 30; 30 70; 70 130];    % alpha, beta, low gamma, high gamma
Bandnum = size(Freqband,1);
order = 4;% Butter worth filter order 4, most common order for EEG
features = []; %initializing feature vector
filters = cell(Bandnum,1);
m = 1; %number of CSP components
Trialnum = size(EEGOUT.data,3); %%changed Alldata to EEGOUT.data
Xfeatures = zeros(Trialnum, Bandnum*2*m);

for b = 1:Bandnum
    [bFilt, aFilt] = butter(order, Freqband(b,:)/(fs/2));
    filters{b} = struct('b',bFilt,'a',aFilt);
end


for fold = 1:cv.NumTestSets

    trainIdx = cv.training(fold);
    testIdx  = cv.test(fold);

    X_train = EEGOUT.data(:,:,trainIdx); %%changed Alldata to EEGOUT.data
    Y_train = Label(trainIdx);
    X_test  = EEGOUT.data(:,:,testIdx);
    Y_test = Label(testIdx);

    XtrainFold = []; %folds 
    XtestFold  = [];

    for b = 1:Bandnum

        XtrainBand = zeros(nChan, nSamples, sum(trainIdx)); %testing across different bandwidths
        XtestBand = zeros(nChan, nSamples, sum(testIdx));

        %% filtering

        for t = 1:sum(trainIdx)
            XtrainBand(:,:,t) = filtfilt(filters{b}.b,filters{b}.a,...
                double(squeeze(X_train(:,:,t)))')';
        end

        for t = 1:sum(testIdx)
            XtestBand(:,:,t) = filtfilt(filters{b}.b,filters{b}.a,...
                double(squeeze(X_test(:,:,t)))')';
        end


        %% Start to CSP
        X_yes = XtrainBand(:,:,Y_train==1);
        X_no = XtrainBand(:,:,Y_train==0);

        [w_selected, discriminativity, SIN, wtot, Rh, Rf] = myCSP(X_yes, X_no,m);

        XtrainFeat = zeros(sum(trainIdx), size(w_selected,2));
        XtestFeat = zeros(sum(testIdx), size(w_selected,2));


        for t = 1:sum(trainIdx)
            XtrainFeat(t,:) = log(var(w_selected'*XtrainBand(:,:,t),0,2))';
        end


        for t = 1:sum(testIdx)
            XtestFeat(t,:) = log(var(w_selected'*XtestBand(:,:,t),0,2))';
        end

        %concatenate across bands
        XtrainFold = [XtrainFold XtrainFeat];
        XtestFold = [XtestFold XtestFeat];

    end

    %% Z-score normalization

    mu  = mean(XtrainFold, 1);
    sig = std(XtrainFold, 0, 1);

    XtrainFold = (XtrainFold - mu) ./ sig;
    XtestFold  = (XtestFold  - mu) ./ sig;

    Xfeatures(trainIdx,:) = XtrainFold;
    Xfeatures(testIdx,:)  = XtestFold;
end

size(Xfeatures)
length(Label)
nUp
nDown
Trialnum

%% Classifier
% Make a table for classifiers
featNames = strcat('v', string(1:size(Xfeatures,2)));
EEGTable = array2table(Xfeatures, 'VariableNames', featNames);
EEGTable.Label = Label;

% Preallocate
predBag   = zeros(size(Label));
scoresBag = zeros(size(Label,1),2);

predBoost   = zeros(size(Label));
scoresBoost = zeros(size(Label,1),2);

predLDA   = zeros(size(Label));
scoresLDA = zeros(size(Label,1),2);

predSVM   = zeros(size(Label));
scoresSVM = zeros(size(Label,1),2);

% Loop over the same folds used in CSP
for fold = 1:cv.NumTestSets
    trainIdx = cv.training(fold);
    testIdx  = cv.test(fold);


    % ---- Bagged Tree ----
    bagTree = templateTree('MaxNumSplits',15,'MinLeafSize',5);
    MdlBagFold = fitcensemble(Xfeatures(trainIdx,:), Label(trainIdx), 'Method','Bag', 'NumLearningCycles',100,'Learners',bagTree);
    [predBag(testIdx), scoreFold] = predict(MdlBagFold, Xfeatures(testIdx,:));
    scoresBag(testIdx,:) = scoreFold;

    % ---- Boosted Tree ----
    boostTree = templateTree('MaxNumSplits',15,'MinLeafSize',5);
    MdlBoostFold = fitcensemble(Xfeatures(trainIdx,:), Label(trainIdx), 'Method','AdaBoostM1', 'NumLearningCycles',100,'Learners',boostTree);
    [predBoost(testIdx), scoreFold] = predict(MdlBoostFold, Xfeatures(testIdx,:));
    scoresBoost(testIdx,:) = scoreFold;

    % ---- LDA ----
    MdlLDAFold = fitcdiscr(Xfeatures(trainIdx,:), Label(trainIdx),'DiscrimType','linear'); %%used to be linear
    [predLDA(testIdx), scoreFold] = predict(MdlLDAFold, Xfeatures(testIdx,:));
    scoresLDA(testIdx,:) = scoreFold;

    % ---- Linear SVM ----
    MdlSVMFold = fitcsvm(Xfeatures(trainIdx,:), Label(trainIdx), 'KernelFunction','linear', 'Standardize',true, 'ScoreTransform','logit');
    [predSVM(testIdx), scoreFold] = predict(MdlSVMFold, Xfeatures(testIdx,:));
    scoresSVM(testIdx,:) = scoreFold;
end

% Compute accuracies
accBag   = mean(predBag == Label);
accBoost = mean(predBoost == Label);
accLDA   = mean(predLDA == Label);
accSVM   = mean(predSVM == Label);

fprintf('Bagged Tree Accuracy: %.2f%%\n', accBag*100);
fprintf('Boosted Tree Accuracy: %.2f%%\n', accBoost*100);
fprintf('LDA Accuracy: %.2f%%\n', accLDA*100);
fprintf('SVM Accuracy: %.2f%%\n', accSVM*100);

% Compute AUC
[~,~,~,AUCBag]   = perfcurve(Label, scoresBag(:,2),1);
[~,~,~,AUCBoost] = perfcurve(Label, scoresBoost(:,2),1);
[~,~,~,AUCLDA]   = perfcurve(Label, scoresLDA(:,2),1);
[~,~,~,AUCSVM]   = perfcurve(Label, scoresSVM(:,2),1);

fprintf('Bagged Tree AUC: %.3f\n', AUCBag);
fprintf('Boosted Tree AUC: %.3f\n', AUCBoost);
fprintf('LDA AUC: %.3f\n', AUCLDA);
fprintf('SVM AUC: %.3f\n', AUCSVM);

% confusion matrix
figure;
CM = confusionchart(Label, predBag);
numPerm = 100;
permAcc = zeros(numPerm,1);

for p = 1:numPerm
    rng(p);
    Label_perm = Label(randperm(length(Label)));
    predPerm = zeros(size(Label));
    for fold = 1:cv.NumTestSets
        trainIdx = cv.training(fold);
        testIdx = cv.test(fold);
        X_train = EEGOUT.data(:,:,trainIdx);
        Y_train = Label_perm(trainIdx);
        X_test = EEGOUT.data(:,:,testIdx);
        XtrainFold = [];
        XtestFold = [];
        for b = 1:Bandnum
            XtrainBand = zeros(nChan, nSamples, sum(trainIdx));
            XtestBand = zeros(nChan, nSamples, sum(testIdx));
            for t = 1:sum(trainIdx)
                XtrainBand(:,:,t) = filtfilt(filters{b}.b,filters{b}.a,...
                double(squeeze(X_train(:,:,t)))')';
            end
            for t = 1:sum(testIdx)
                XtestBand(:,:,t) = filtfilt(filters{b}.b,filters{b}.a,...
                double(squeeze(X_test(:,:,t)))')';
            end
            X_yes = XtrainBand(:,:,Y_train==1);
            X_no = XtrainBand(:,:,Y_train==0);
            [w_selected,~,~,~,~,~] = myCSP(X_yes, X_no, m);
            XtrainFeat = zeros(sum(trainIdx), size(w_selected,2));
            XtestFeat = zeros(sum(testIdx), size(w_selected,2));
            for t = 1:sum(trainIdx)
                 XtrainFeat(t,:) = log(var(w_selected'*XtrainBand(:,:,t),0,2))';
            end
            for t = 1:sum(testIdx)
                XtestFeat(t,:) = log(var(w_selected'*XtestBand(:,:,t),0,2))';
            end
            XtrainFold = [XtrainFold XtrainFeat];
            XtestFold = [XtestFold XtestFeat];
        end
        Mdl = fitcensemble(XtrainFold, Y_train, ...
        'Method','Bag','NumLearningCycles',100);
        predPerm(testIdx) = predict(Mdl, XtestFold);
    end
    permAcc(p) = mean(predPerm == Label_perm);
    p
end
fprintf('Permutation (proper) mean = %.2f%% ± %.2f%%\n', ...
mean(permAcc)*100, std(permAcc)*100)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [w_selected, discriminativity, SIN, wtot, Rh, Rf] = myCSP(data1, data2, m)
Rh=0;
for i=1:size(data1,3)
    x1= data1(:,:,i);
    x1 = x1 - mean(x1,2);

    % step 1: normal data
    rh= (x1*x1')/trace(x1*x1'); %spatial covariance matrix for individual trials
    Rh = Rh+ rh; %summing covariance matrices for all trials in class 1
end
% step2: calculate Rh and Rf mean
Rh= Rh / size(data1,3);
Rf=0;
for i=1:size(data2,3)
    x2= data2(:,:,i);
    % step 1: normal data
    %   x2 = x2 - repmat(mean(x2,2),1,size(x2,2));
    x2 = x2 - mean(x2,2);

    % step 1: normal data
    rf= (x2*x2')/trace(x2*x2');
    Rf = Rf+ rf; %summing covariance matrices for all trials in class 2
end
% step2: calculate Rh and Rf mean
Rf= Rf / size(data2,3);

%% SHRINKAGE REGULARIZATION FOR OVERFITTING
Shrinkage = 0.1;
C = size(Rh,1);
Rh = (1-Shrinkage)*Rh + Shrinkage*(trace(Rh)/C)*eye(C);
Rf = (1-Shrinkage)*Rf + Shrinkage*(trace(Rf)/C)*eye(C);

%% step 3: generalized eigen value decomposition
[wtot,v] = eig(Rh,Rf);
v_= diag(v);
[~,ind]= sort(v_,'descend');
wtot= wtot(:,ind);
v_ = v_(ind);
w_selected= [wtot(:,1:m) , wtot(:,end-m+1:end)];

discriminativity = [v_(1:m); v_(end-m+1:end)];
SIN = NaN;

end
