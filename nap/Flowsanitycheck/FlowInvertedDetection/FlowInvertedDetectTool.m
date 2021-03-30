function [PrUpright,Fnoise2All]=FlowInvertedDetectTool(FlowSig,TimeSig)
global settings
% clear all;
% close all;
% clc;

% addpath(genpath('C:\Users\rma56\Dropbox (Partners HealthCare)\PUPbeta_git\PUPbeta\'))
% load('D:\MrOS\Visit1\Converted\mros-visit1-aa0003_XHz.mat')

% load model
load('FlowInvertedDetector.mat')

% settings required
settings.plotbreathdetectionfigures=0;
settings.sqrt_scaling=1;
settings.plotfiguresqrtscaling=0;
settings.modBB_i_start = logical(1); % modifybreathstartusingflowsilence

settings.scalingexponent=0.67;
settings.plotfigure=0;

PrctileList = [12.5:12.5:87.5];

% FlowSig = -DataEventHypnog_Mat(:,2);
% TimeSig = DataEventHypnog_Mat(:,1);

%overall noise
noisewavAll = FlowSignalToNoise(TimeSig,FlowSig,settings.plotfigure);
Fnoise2All=sum(noisewavAll>=2)/length(noisewavAll);

figure(1); 
    set(gcf,'color',[1 1 1]);

clear Tone 
clf(1)
Tone.diffcurr = nan(length(PrctileList),1);
Tone.diffprev = nan(length(PrctileList),1);
Tone.COVVTi = nan(length(PrctileList),1);

for i=1:length(PrctileList)
    figure(1);

    try
    lt = prctile(TimeSig,PrctileList(i));
    I = find(TimeSig>lt & TimeSig<lt+420);
    
   
    %plot(TimeSig(I),FlowSig(I));
            tempx = TimeSig(I);
            temp = FlowSig(I);
            temp = (temp-nanmean(temp))/nanstd(temp);
            subplot(length(PrctileList),1,i); 
            plot(tempx,temp); 
            set(gca,'box','off','ylim',[-4 4],'xlim',[min(tempx) max(tempx)],'xtick',[],'xcolor',[1 1 1],'ytick',[],'ycolor',[1 1 1]);
            if i==1
               h=ylabel('Example signals','fontweight','normal','color',[0 0 0]);
               if isfield(settings,'fname')
               title(settings.fname)
               end
            end

    %add code to detct if flow is there (e.g. Noise code, uses fft)
    noisewav = FlowSignalToNoise(tempx,temp,settings.plotfigure);
    
    Fnoise2(i,1)=sum(noisewav>=2)/length(noisewav);
    if Fnoise2(i,1)>=0.1
        display(['Skipping ' num2str(i) ':' ', noisy or absent flow signal']);
        Tone.diffcurr(i,1)=NaN;
        Tone.diffprev(i,1)=NaN;
        Tone.COVVTi(i,1)=NaN;
    else
        [~,~,~,~,~,~,~,~,~,~,...
            ~,VT,~,~,Apnea_B,~,VTi,VTe,Ti,Te] =...
            VEfromFlow(TimeSig(I),FlowSig(I));
        
        [Tone.diffcurr(i,1),Tone.diffprev(i,1),Tone.COVVTi(i,1)] = FlowInvertedParameters(VTi,VTe,VT,Apnea_B);
    end
    catch me
    end
end


Tone = struct2table(Tone);
Tone.diffcurroverprev = Tone.diffcurr./Tone.diffprev;


Tone.PappearsInverted = 1-predict(FlowInvertedDetector.mdlUpright,Tone);
Tone.Perror = predict(FlowInvertedDetector.mdlError,Tone);

Ttwo=table([]);
MeanPw = nanmean(Tone.PappearsInverted.*(1-Tone.Perror))/nanmean(1-Tone.Perror);
Ttwo=table(MeanPw);
PrUpright = predict(FlowInvertedDetector.mdlSubjUpright,Ttwo);

if isfield(settings,'savefigure')&& settings.savefigure==1
    savefigdir=[extractBefore(settings.workdir,'\PUPStart') '\FlowQCPlots\'];
    if ~(exist(savefigdir, 'dir') == 7)
        mkdir(savefigdir);
    end
    savefigname=[savefigdir extractBefore(settings.fname,'.edf') '.png'];
    saveas(figure(1),savefigname);
    
    savefigdir2=[extractBefore(settings.workdir,'\PUPStart') '\FlowQCPlots\MatFigs\'];
    if ~(exist(savefigdir2, 'dir') == 7)
        mkdir(savefigdir2);
    end 
    savefigname2=[savefigdir2 extractBefore(settings.fname,'.edf') '.fig'];
    
    saveas(figure(1),savefigname2);
end

   
   
   
   
   
