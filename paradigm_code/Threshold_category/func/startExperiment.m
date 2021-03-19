function startData = startExperiment(experimentName)


disp('working from directory')
disp([pwd ' ...'])
disp(' ')

initials = input('Enter subjects initials:   ', 's');

if IsWin
    dataDir = [pwd '\data\' initials, 'data\'];
else
    dataDir = [pwd '/data/' initials, 'data/'];
end

mkdir(dataDir);
startupTime = clock;
% get distance from screen
%distFromScreen_inCm = input('Enter distance from screen in cm:   ');
distFromScreen_inCm = 60;
currentFile = 'datafile.mat';
dataFile = [dataDir currentFile];

% general comments
comments = input('Comments?   ','s');
startData.initials            = initials;
startData.dataDir             = dataDir;
startData.dataFile            = dataFile;
startData.distFromScreen_inCm = distFromScreen_inCm;
startData.startupTime         = startupTime;
startData.comments            = comments;