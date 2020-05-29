clear all;

col1 = [127,201,127] ./ 255;
col2 = [190,174,212] ./ 255;
col3 = [253,192,134] ./ 255;
col4 = [255,255,153] ./ 255;
col5 = [56,108,176] ./ 255;
col6 = [231 164 252] ./ 255;

%Once you have a folder with simulated AND real data in it, you can use
%this script to run the Descriptive Task analysis on it.


AllData=dir('*andit*.txt');

%e.g. for my data ('parse_test' are outputs from the simulation script):
%{'BanditDataforRANX.txt';'BanditDataforRHC.txt';'bandit4_parse_testData__ANXdiagPrior44.txt';'bandit4_parse_testData__HCdiagPrior88.txt'}


for files=1:length(AllData)

    BehavData=tdfread(AllData(files).name);
    Subs=unique(BehavData.subjID);

for subj=1:length(Subs)
 RSubGain=NaN(length(BehavData.subjID),1);
 RSubLoss=NaN(length(BehavData.subjID),1);
 RSubChoice=NaN(length(BehavData.subjID),1);
 RSubWinStay=NaN(length(BehavData.subjID),1);
 RSubLoseStay=NaN(length(BehavData.subjID),1);
 RNanForCombo=NaN(length(BehavData.subjID),1);
 RCombowin=NaN(length(BehavData.subjID),1);
 OneForStay=ones(length(BehavData.subjID),1);
 ZeroForCombo=zeros(length(BehavData.subjID),1);
 RSubComboStay=NaN(length(BehavData.subjID),1);

 
 RSubGain(BehavData.subjID==Subs(subj)) = BehavData.gain(BehavData.subjID==Subs(subj));
 RSubLoss(BehavData.subjID==Subs(subj)) = BehavData.loss(BehavData.subjID==Subs(subj));
 RSubChoice(BehavData.subjID==Subs(subj)) = BehavData.choice(BehavData.subjID==Subs(subj));
 
 RDifCh=(vertcat(0,RSubChoice))-(vertcat(RSubChoice,0));
 RDifCh = RDifCh(2:end);
 RSubWinStay(RDifCh==0)=RSubGain(RDifCh==0);
 RSubLoseStay(RDifCh==0)=(RSubLoss(RDifCh==0)*-1);
 
 RCombowin=((RSubLoss*-1)+RSubGain);
 RSubWinStay(RCombowin==2)=RNanForCombo(RCombowin==2);
 RSubLoseStay(RCombowin==2)=RNanForCombo(RCombowin==2);
 
 RSubComboStay(RCombowin==2)=ZeroForCombo(RCombowin==2);
 RSubComboStay(RDifCh==0)=OneForStay(RDifCh==0);
 RSubComboStay(RCombowin~=2)=RNanForCombo(RCombowin~=2);
 
 SubWinStayProp(subj)=(nansum(RSubWinStay)/sum(~isnan(RSubWinStay)));
 SubLoseStayProp(subj)=(nansum(RSubLoseStay)/sum(~isnan(RSubLoseStay)));
 SubComboProp(subj)=(nansum(RSubComboStay)/sum(~isnan(RSubComboStay)));
 SubShiftProb(subj)=1-(sum(RDifCh==0)/length(RDifCh(~isnan(RDifCh))));
 
 
end

WinStayProp(files).data=SubWinStayProp;
LoseStayProp(files).data=SubLoseStayProp;
ComboStayProp(files).data=SubComboProp;
PSwitch(files).data=SubShiftProb;


 SubWinStayProp=[];
 SubLoseStayProp=[];
 SubComboProp=[];
 SubShiftProb=[];
 RDifCh=[];

end


RowIndexANXsim = find(contains({AllData.name},'ANXdia'));
RowIndexHCsim = find(contains({AllData.name},'HCdia'));
RowIndexANXreal = find(contains({AllData.name},'RAN'));
RowIndexHCreal = find(contains({AllData.name},'RHC'));

diag=vertcat(ones(length(WinStayProp(RowIndexHCsim).data),1), zeros(length(WinStayProp(RowIndexANXsim).data),1));
WSSim= horzcat(WinStayProp(RowIndexHCsim).data, WinStayProp(RowIndexANXsim).data) ;
WSReal= horzcat(WinStayProp(RowIndexHCreal).data, WinStayProp(RowIndexANXreal).data);
LSSim= horzcat(LoseStayProp(RowIndexHCsim).data, LoseStayProp(RowIndexANXsim).data) ;
LSReal= horzcat(LoseStayProp(RowIndexHCreal).data, LoseStayProp(RowIndexANXreal).data);
ComboSim= horzcat(ComboStayProp(RowIndexHCsim).data, ComboStayProp(RowIndexANXsim).data);
ComboReal= horzcat(ComboStayProp(RowIndexHCreal).data, ComboStayProp(RowIndexANXreal).data);
PSwitchSim= horzcat(PSwitch(RowIndexHCsim).data, PSwitch(RowIndexANXsim).data);
PSwitchReal= horzcat(PSwitch(RowIndexHCreal).data, PSwitch(RowIndexANXreal).data);

varnam={'diag','WSSim','LSSim','ComboSim', 'PSwitchSim', 'WSReal','LSReal','ComboReal','PSwitchReal' };
T = table(diag, WSSim',LSSim',ComboSim', PSwitchSim', WSReal',LSReal',ComboReal',PSwitchReal' ,'VariableNames',varnam);
writetable(T,'SimRealDataDiagPrior.csv','Delimiter',',')  ;



%% Figures %%

col1 = [228,26,28] ./ 255;
col2 = [55,126,184] ./ 255;

HCSRSubShiftProb=PSwitch(RowIndexHCreal).data;
HCSSSubShiftProb=PSwitch(RowIndexHCsim).data;
ANXRSubShiftProb=PSwitch(RowIndexANXreal).data;
ANXSSubShiftProb=PSwitch(RowIndexANXsim).data;

figure()
scattitle = {'p(switch)'};
scatter(HCSRSubShiftProb, HCSSSubShiftProb,'MarkerEdgeColor',col2,'MarkerFaceColor',col2,'LineWidth',1.5,'MarkerFaceAlpha',.4);
title(scattitle{1},'FontSize',15);
ylabel('Modelled Data');
xlabel('Real Data');
hline = refline(1,0);
hline.Color = 'k';
hline.LineStyle = '--';
hold on
scatter(ANXRSubShiftProb, ANXSSubShiftProb,'MarkerEdgeColor',col1,'MarkerFaceColor',col1,'LineWidth',1.5,'MarkerFaceAlpha',.4);
RPswi=corrcoef(horzcat(HCSRSubShiftProb,ANXRSubShiftProb), horzcat(HCSSSubShiftProb,ANXSSubShiftProb));
text(0.6, 0.2, ['r =' sprintf('%.2f',RPswi(1,2))],'FontSize',13);


HCSRSubWinStayProb=WinStayProp(RowIndexHCreal).data;
HCSSSubWinStayProb=WinStayProp(RowIndexHCsim).data;
ANXRSubWinStayProb=WinStayProp(RowIndexANXreal).data;
ANXSSubWinStayProb=WinStayProp(RowIndexANXsim).data;

HCSRSubLoseStayProb=LoseStayProp(RowIndexHCreal).data;
HCSSSubLoseStayProb=LoseStayProp(RowIndexHCsim).data;
ANXRSubLoseStayProb=LoseStayProp(RowIndexANXreal).data;
ANXSSubLoseStayProb=LoseStayProp(RowIndexANXsim).data;

HCSRSubComboStayProb=ComboStayProp(RowIndexHCreal).data;
HCSSSubComboStayProb=ComboStayProp(RowIndexHCsim).data;
ANXRSubComboStayProb=ComboStayProp(RowIndexANXreal).data;
ANXSSubComboStayProb=ComboStayProp(RowIndexANXsim).data;

figure()
scattitle = {'Win stay','Lose stay', 'Combostay'};
subplot(1,3,1)
scatter(HCSRSubWinStayProb, HCSSSubWinStayProb,'MarkerEdgeColor',col2,'MarkerFaceColor',col2,'LineWidth',1.5,'MarkerFaceAlpha',.4);
hold on
scatter(ANXRSubWinStayProb, ANXSSubWinStayProb,'MarkerEdgeColor',col1,'MarkerFaceColor',col1,'LineWidth',1.5,'MarkerFaceAlpha',.4);
title(scattitle{1},'FontSize',15);
ylabel('Modelled Data');
xlabel('Real Data');
hline = refline(1,0);
hline.Color = 'k';
hline.LineStyle = '--';
RPswi=corrcoef(horzcat(HCSRSubWinStayProb,ANXRSubWinStayProb), horzcat(HCSSSubWinStayProb,ANXSSubWinStayProb));
text(0.2, 0.9, ['r =' sprintf('%.2f',RPswi(1,2))],'FontSize',13);
subplot(1,3,2)
scatter(HCSRSubLoseStayProb, HCSSSubLoseStayProb,'MarkerEdgeColor',col2,'MarkerFaceColor',col2,'LineWidth',1.5,'MarkerFaceAlpha',.4);
hold on
scatter(ANXRSubLoseStayProb, ANXSSubLoseStayProb,'MarkerEdgeColor',col1,'MarkerFaceColor',col1,'LineWidth',1.5,'MarkerFaceAlpha',.4);
title(scattitle{2},'FontSize',15);
ylabel('Modelled Data');
xlabel('Real Data');
hline = refline(1,0);
hline.Color = 'k';
hline.LineStyle = '--';
RPswi=corrcoef(horzcat(HCSRSubLoseStayProb,ANXRSubLoseStayProb), horzcat(HCSSSubLoseStayProb,ANXSSubLoseStayProb));
text(0.2, 0.9, ['r =' sprintf('%.2f',RPswi(1,2))],'FontSize',13);
subplot(1,3,3)
scatter(HCSRSubComboStayProb, HCSSSubComboStayProb,'MarkerEdgeColor',col2,'MarkerFaceColor',col2,'LineWidth',1.5,'MarkerFaceAlpha',.4);
hold on
scatter(ANXRSubComboStayProb, ANXSSubComboStayProb,'MarkerEdgeColor',col1,'MarkerFaceColor',col1,'LineWidth',1.5,'MarkerFaceAlpha',.4);
title(scattitle{3},'FontSize',15);
ylabel('Modelled Data');
xlabel('Real Data');
hline = refline(1,0);
hline.Color = 'k';
hline.LineStyle = '--';
RPswi=corrcoef(horzcat(HCSRSubComboStayProb,ANXRSubComboStayProb), horzcat(HCSSSubComboStayProb,ANXSSubComboStayProb));
text(0.2, 0.9, ['r =' sprintf('%.2f',RPswi(1,2))],'FontSize',13);

