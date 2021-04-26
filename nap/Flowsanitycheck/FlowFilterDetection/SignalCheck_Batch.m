%% Batch signal frequency analysis

% open directory (use converted files i.e. _XHz.mat s)
% for every file
% open/load file
% get flow signal
% do frequency analysis
% save plot
% next


%% start up
fh=findall(0,'type','figure');
close(fh)
clear global settings
clear
clc
warning('off','all'); % the GUI fig can generate warnings, so best off


%% set path
[currentdir,~,~] = fileparts(mfilename('fullpath'));
cd(currentdir); addpath(genpath(pwd));

%% add paths to filter tool and clipping tool
addpath('M:\Dropbox\PUPbeta_git\PUPbeta\FlowFilterDetection');
addpath('M:\Dropbox\PUPbeta_git\PUPbeta\Clipping');

%% start processing
% open directory (use converted files i.e. _XHz.mat s)
selpath = uigetdir('Select directory with _XHz.mat data');
dirx = dir(fullfile(selpath,'*_XHz.mat')); %dirx(1:2)=[];
for i=1:length(dirx) % for every file
    
    disp('.'); % add line space in command window for ease of viewing
    filedir = [selpath filesep dirx(i).name];
    str = ['File: ', dirx(i).name, ', loading ...'];  disp(str);
    try
        Fdata = open(filedir); % open
    catch Fopen_fail
        str = ['File: ', dirx(i).name, ', could not open ...'];  disp(str);
        continue        
    end
    
    % get time and flow signals
    Time = Fdata.DataEventHypnog_Mat(:,find(strcmp(Fdata.ChannelsList,'Time')==1));
    Flow = Fdata.DataEventHypnog_Mat(:,find(strcmp(Fdata.ChannelsList,'Flow')==1));
    
    % do frequency analysis
    ploton=1;   verbose=1; plotdims = [10 6];
    FlowFilterDetect = FlowFilterDetector(Flow,Time,ploton,verbose, plotdims);
    
    %     % do clip detection:
    %     ClipThresholdFmax=0.90;
    %     ClipFthresholdFnormal=0.002; %higher value removes more (i.e. false) clipping (0.002)
    %     [~,~,FclippedI,FclippedE,~] = ClipDetection(Flow,[],[],[],ClipThresholdFmax,ClipFthresholdFnormal,1);
    %
    %     FlowFilterDetect.FclippedI=FclippedI;
    %     FlowFilterDetect.FclippedE=FclippedE;
    %     FlowFilterDetect.FclippedTotal=FclippedE+FclippedI;
    %
    %     if verbose
    %         if FlowFilterDetect.FclippedTotal(1)>0.005
    %             disp('Warning: Flow appears clipped');
    %         else
    %             disp('Checked: Flow appears free of clipping');
    %         end
    %         disp(['   Clipping fraction: ' num2str(100*FlowFilterDetect.FclippedTotal,2) ' %']);
    %     end
    %
    
    
    % save plot
    fig = gcf;
    [filepath,nameOnly,ext] = fileparts(filedir);
    savedir = [selpath, filesep, 'FrequencyAnalysis', filesep];
    if ~exist(savedir, 'dir')
        mkdir(savedir);
    end
    saveas(fig, [savedir,nameOnly], 'png');
    
    close(fig);

end