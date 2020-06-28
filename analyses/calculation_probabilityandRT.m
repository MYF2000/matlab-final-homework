clear all;

cd('C:\Users\DAWN\Desktop\matlab_finalhomework_analysis');
AllData=dir('*exp*.xlsx');

for files=1:length(AllData)

    BehavData=readtable(AllData(files).name);
    BehavData = table2struct(BehavData,'ToScalar',true);
    Subs=unique(BehavData.subject_id);
    
for subj=1:length(Subs)
 RSubGain=NaN(length(BehavData.subject_id),1);
 RSubChoice=NaN(length(BehavData.subject_id),1);
 RSubWinStay=NaN(length(BehavData.subject_id),1);
 RSubLoseshift=NaN(length(BehavData.subject_id),1);
 RSubRT = NaN(length(BehavData.subject_id),1);

 
 RSubGain(BehavData.subject_id==Subs(subj)) = BehavData.is_reward(BehavData.subject_id==Subs(subj));
 RSubChoice(BehavData.subject_id==Subs(subj)) = BehavData.response(BehavData.subject_id==Subs(subj));
 RSubRT(BehavData.subject_id==Subs(subj)) = BehavData.RT(BehavData.subject_id==Subs(subj));
 
 
 RDifCh=(vertcat(0,RSubChoice))-(vertcat(RSubChoice,0));
 RDifCh = RDifCh(2:end);
 RSubWinStay(RDifCh==0)=RSubGain(RDifCh==0);
 RSubLoseshift(RDifCh~=0)=RSubGain(RDifCh~=0);
 
 
 SubWinStayProp(subj)=(nansum(RSubWinStay)/sum(~isnan(RSubWinStay))); 
 SubLoseshiftProp(subj)=(((sum(~isnan(RSubLoseshift)))-nansum(RSubLoseshift))/sum(~isnan(RSubLoseshift)));
 SubmeanRT(subj) = nansum(RSubRT)/sum(~isnan(RSubRT));
 
end

WinStayProp(files).name=AllData(files).name;
LoseshiftProp(files).name=AllData(files).name;
meanRT(files).name=AllData(files).name;

WinStayProp(files).data=SubWinStayProp;
LoseshiftProp(files).data=SubLoseshiftProp;
meanRT(files).data=SubmeanRT;

 SubWinStayProp=[];
 SubLoseshiftProp=[];
 RDifCh=[];
 SubmeanRT=[];
 colname=[];
 
end

winstay = (cat(1,WinStayProp.data))';
colNames = {WinStayProp.name};
wintable = array2table(winstay,'VariableNames',colNames);


loseshift = (cat(1,LoseshiftProp.data))';
colNames = {LoseshiftProp.name};
losetable = array2table(loseshift,'VariableNames',colNames);

Reactime = (cat(1,meanRT.data))';
colNames = {meanRT.name};
RTtable = array2table(Reactime,'VariableNames',colNames);

writetable(wintable, 'wintable.csv')
writetable(losetable, 'losetable.csv')
writetable(RTtable, 'RTtable.csv')
