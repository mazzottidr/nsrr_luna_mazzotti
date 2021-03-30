function [FlowSignal2,leak,IEratio] = sqrtscaling(Time,Flow,showfigures)
%% square root scaling, with leak calculation
plotfigs=0; %all figures for each loop | showfigures is just the summary
%tic
dt = Time(2)-Time(1);

leak1 = mean(Flow);
FlowSignal=Flow-mean(Flow);

%plotfigs=0;

expinspcorrectionlimit=2; % full range of this exponent is 1/3 to 3.

clear F Parameters_out Ydata1
N=3;
YY=10.^linspace(log10(1/expinspcorrectionlimit),log10(expinspcorrectionlimit),N); %%%%%% beta = E/I magnitude coefficient
for j=1:N
    try
    Parameters = YY(j);
    [F(j),Parameters_out(j,:),Ydata1{j}]=PnasaltoFlowLeak(Parameters,FlowSignal,Time,dt,plotfigs);
    catch me
        Parameters_out(j,:)=[NaN NaN NaN];
        F(j)=NaN;
    end
end


YY(isnan(F))=[]; F(isnan(F))=[];
IEratio = interp1(F,YY,0,'linear','extrap');
IEratioestimated=IEratio;
if IEratio>expinspcorrectionlimit
    IEratio=expinspcorrectionlimit;
elseif IEratio<1/expinspcorrectionlimit
    IEratio=1/expinspcorrectionlimit;
end

if showfigures
    figure(99); clf(99); 
    subplot(1,3,3);
    set(gcf,'color',[1 1 1]);
    semilogx(YY,F,'.--'); box('off');
    ylims=get(gca,'ylim');
    hold('on');
    plot(IEratioestimated*[1 1],ylims,'r:');
    plot(IEratio*[1 1],ylims,'k-');
    hold('off');
    ylabel('Zero flow estimate, large breaths');
    xlabel('IEratio');
end

[F_,Parameters_out_,FlowSignal2]=PnasaltoFlowLeak(IEratio,FlowSignal,Time,dt,plotfigs);

leak = Parameters_out_(1)+leak1; % Parameters_out_(1) is baseline
if showfigures
    figure(99); 
    set(gcf,'color',[1 1 1]);
    subplot(2,3,[1 2]); 
	plot(Time,Flow,'k'); hold on;
    plot(Time, Flow*0, 'r--');
    plot(Time, Flow*0+leak,'b'); 
    % refline(0, -leak); 
    set(gca,'Xtick',[],'Xcolor',[1 1 1]);
    
    ylabel('Original flow');
    box('off');
    subplot(2,3,[4 5]); 
	plot(Time,FlowSignal2,'k'); hold on;
	plot(Time,Flow*0, 'r--'); 
	ylabel('Modified flow');
	box('off');
end
%toc

