function [F,Parameters_out,FlowSignal]=PnasaltoFlowLeak(beta,Ydata1,Time,dt,plotfigs)
global settings
leakdelta=0; %should be already mean subtracted

%%
for w=1:2
FlowSignal = Ydata1;
%FlowSignal(5000:25000) = -0.03;

exponent=settings.scalingexponent;

FlowSignal=FlowSignal - leakdelta;

FlowSignal(FlowSignal>0)=(FlowSignal(FlowSignal>0).^(exponent))/(beta^0.5);
FlowSignal(FlowSignal<0)=(-(-FlowSignal(FlowSignal<0)).^(exponent))*(beta^0.5);

    [VT,VTi,VTe,leaktotal]=VflowanalysisFastLeak(FlowSignal,Time,dt,1-plotfigs); 
   
    if leaktotal>0
        leakdelta = leakdelta + (leaktotal*(beta^0.5))^(1/exponent);
    else
        leakdelta = leakdelta - (-leaktotal/(beta^0.5))^(1/exponent);
    end
end


    %% Contributes to finding the IEratio (for given leak) by finding baseline offset (FVTisecondlowestXtile)
    %toc
    FVTi = VTi-VTe;
    Nbreaths = length(VTe);
    minbreaths = 5;
    prclow = 10;
        if Nbreaths*prclow/100<minbreaths
            prclow = minbreaths/Nbreaths;
        end
    VTXtile = prctile(VT,prclow);
    prclow2 = 67;
    VTXtile2L = prctile(VT,prclow2);
    if VTXtile==0
        VTXtile=min(VT(VT>0));
    end
    if VTXtile2L==0
        VTXtile2L=min(VT(VT>0));
    end
    VTXtile2 = max(VT); %75
    VTbelowVTXtile=VT<=VTXtile;
    VTwithinVTXtile2=VT>=VTXtile2L&VT<=VTXtile2;
    
    FVTilowestXtile = median(FVTi(VTbelowVTXtile==1));
    VTlowestXtile = median(VT(VTbelowVTXtile==1));
    FVTisecondlowestXtile = median(FVTi(VTwithinVTXtile2==1));
    VTsecondlowestXtile = median(VT(VTwithinVTXtile2==1));
    
    
    if plotfigs||0
        figure(99); plot(VT,FVTi,'.',[VTlowestXtile VTsecondlowestXtile],[FVTilowestXtile FVTisecondlowestXtile],'ko-');
    end
    projectedFVTizeroVT = FVTilowestXtile-VTXtile*(FVTisecondlowestXtile-FVTilowestXtile)/(VTXtile2-VTXtile);
    if 0
        F = abs(projectedFVTizeroVT)+abs(FVTisecondlowestXtile); %
    else
        F = FVTisecondlowestXtile;
    end
    Parameters_out = [leakdelta FVTilowestXtile FVTisecondlowestXtile];
    %toc




