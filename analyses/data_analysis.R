rm(list=ls());

sink("C:/Users/DAWN/Desktop/matlab_finalhomework_analysis/Rconsole_output.txt");

# 对焦虑得分进行单因素方差分析，分组
questionnairedata <- read.csv('C:/Users/DAWN/Desktop/matlab_finalhomework_analysis/questionnaire.csv');

# 查看表格结构，方便下面提取数据
# head(questionnairedata);
# colnames(questionnairedata)
questionnairedata <- questionnairedata[,c(7,8,9,30)];

orderdata <- questionnairedata[order(-questionnairedata$总分),];

len = dim(orderdata)[1];
groupnum <-c(rep(1, len/2),rep(2,len/2));
# 1为焦虑问卷得分高分组，2为焦虑问卷得分低分组,下面的分析皆如此
orderdata['group']=groupnum;

library(bruceR);

questionnaire_score_result<-MANOVA(data=orderdata, dv="总分", between="group")

highanxiousid<-c(orderdata$请输入您的被试编号[1:(len/2)]);
lowanxiousid<-c(orderdata$请输入您的被试编号[(len/2+1):len]);

# 合并所有被试的experimental data文件

library(readxl);
# 设置工作空间
setwd('C:/Users/DAWN/Desktop/matlab_finalhomework_analysis/behavioral_data/exp');
# 读取该工作空间下的所有文件名
expfilenames <- dir();
# 初始化数据框，用于后面的数据合并
expdata <- data.frame();
#通过循环完成数据合并
for (i in expfilenames){
  # 构造数据路径
  path <- paste0(getwd(),'\\',i)
  #res <- c(res,path)
  # 读取并合并数据
  expdata <- rbind(expdata,read_excel(path = path))
}
expdata<-data.frame(expdata);
# 查看表格结构，方便下面提取数据
# head(expdata)
# colnames(expdata)
expdata<-expdata[,c(1,2,3,4,6)];
a <- sub("left","1",expdata$response);
b <- sub("right","2",a);

expdata$response <- b;


# 查看是否有缺失值
# sum(is.nan(expdata))

expdata$response<-as.numeric(expdata$response);
expdata$subject_id<-as.numeric(expdata$subject_id);

#生成运行calculate_probabilityandRT.m文件所需的四个xlsx文件

explow<-expdata[expdata$subject_id %in% lowanxiousid,];
exphigh<-expdata[expdata$subject_id %in% highanxiousid,];

safenum<-c(1:40,81:120);
threatnum<-c(41:80,121:160);

exphighsafe<-exphigh[exphigh$trial_num %in% safenum,];

exphighthreat<-exphigh[exphigh$trial_num %in% threatnum,];

explowsafe<-explow[explow$trial_num %in% safenum,];

explowthreat<-explow[explow$trial_num %in% threatnum,];

library(xlsx);

write.xlsx(exphighthreat,file ="C:/Users/DAWN/Desktop/matlab_finalhomework_analysis/exp_high_threat.xlsx",sheetName = 'sheet1',col.names = TRUE,row.names = FALSE);
write.xlsx(exphighsafe,file ="C:/Users/DAWN/Desktop/matlab_finalhomework_analysis/exp_high_safe.xlsx",sheetName = 'sheet1',col.names = TRUE,row.names = FALSE);
write.xlsx(explowthreat,file ="C:/Users/DAWN/Desktop/matlab_finalhomework_analysis/exp_low_threat.xlsx",sheetName = 'sheet1',col.names = TRUE,row.names = FALSE);
write.xlsx(explowsafe,file ="C:/Users/DAWN/Desktop/matlab_finalhomework_analysis/exp_low_safe.xlsx",sheetName = 'sheet1',col.names = TRUE,row.names = FALSE);



# 利用上面生成的四个xlsx文件，运行calculate_probabilityandRT.m文件,得到三个csv文件，利用这三个csv文件进行下面的分析




library(bruceR);

# winstayprobability的condition × group 两因素方差分析
winstaydata<-read.csv('C:/Users/DAWN/Desktop/matlab_finalhomework_analysis/wintable.csv');
names(winstaydata)<-c('high_safe','high_threat','low_safe','low_threat');
# head(winstay)
# # 查看表格结构，方便下面提取数据

winstaydata_anova<-data.frame(group=groupnum,consafe=c(winstaydata[,1],winstaydata[,3]),conthreat=c(winstaydata[,2],winstaydata[,4]));

winstayresult<-MANOVA(data=winstaydata_anova, dvs="consafe:conthreat", dvs.pattern="con(.)",between="group", within="con") %>%
  EMMEANS("group", by="con") %>%
  EMMEANS("con", by="group");

# loseshiftprobability的condition × group 两因素方差分析
loseshiftdata<-read.csv('C:/Users/DAWN/Desktop/matlab_finalhomework_analysis/losetable.csv');
names(loseshiftdata)<-c('high_safe','high_threat','low_safe','low_threat');
loseshiftdata_anova<-data.frame(group=groupnum,consafe=c(loseshiftdata[,1],loseshiftdata[,3]),conthreat=c(loseshiftdata[,2],loseshiftdata[,4]));

loseshiftresult<-MANOVA(data=loseshiftdata_anova, dvs="consafe:conthreat", dvs.pattern="con(.)",between="group", within="con") %>%
  EMMEANS("group", by="con") %>%
  EMMEANS("con", by="group");


# reaction time的condition × group 两因素方差分析
RTdata<-read.csv('C:/Users/DAWN/Desktop/matlab_finalhomework_analysis/RTtable.csv');
names(RTdata)<-c('high_safe','high_threat','low_safe','low_threat');
RTdata_anova<-data.frame(group=groupnum,consafe=c(RTdata[,1],RTdata[,3]),conthreat=c(RTdata[,2],RTdata[,4]));

RTresult<-MANOVA(data=RTdata_anova, dvs="consafe:conthreat", dvs.pattern="con(.)",between="group", within="con") %>%
  EMMEANS("group", by="con") %>%
  EMMEANS("con", by="group");

# evaluation的condition × group两因素方差分析

# 合并所有被试的数据文件 
library(readxl);
setwd('C:/Users/DAWN/Desktop/matlab_finalhomework_analysis/behavioral_data/ev');
evfilenames <- dir();
# 初始化数据框，用于后面的数据合并
evdata <- data.frame();
#通过循环完成数据合并
for (j in evfilenames){
  # 构造数据路径
  path2 <- paste0(getwd(),'\\',j)
  #res <- c(res,path)
  # 读取并合并数据
  evdata <- rbind(evdata,read_excel(path = path2,col_names = F))
}
evdata<-data.frame(evdata);


# 查看表格结构，方便下面提取数据
# head(evdata)
# colnames(evdata)
evdata<-evdata[,c(2,4,6)];
names(evdata)<-c('id','consafe','conthreat');


# sum(is.na(evdata))

evdata$id<-as.numeric(evdata$id);
evdata$consafe<-as.numeric(evdata$consafe);
evdata$conthreat<-as.numeric(evdata$conthreat);


# 修改一个错误的数据
evdata$consafe[which(evdata$id==5)]=3;

evlow<-evdata[evdata$id %in% lowanxiousid,]
evhigh<-evdata[evdata$id %in% highanxiousid,]

evhigh['group']=groupnum[1:(len/2)];
evlow['group']=groupnum[(len/2+1):len];

write.csv(evhigh,file="C:/Users/DAWN/Desktop/matlab_finalhomework_analysis/evhigh.csv",quote=F,row.names = F)
write.csv(evlow,file="C:/Users/DAWN/Desktop/matlab_finalhomework_analysis/evlow.csv",quote=F,row.names = F)

ev_anovadata<-rbind(evhigh,evlow);
ev_anovadata<-ev_anovadata[,c(2,3,4)];
evresult<-MANOVA(data=ev_anovadata, dvs="consafe:conthreat", dvs.pattern="con(.)",between="group", within="con") %>%
  EMMEANS("group", by="con") %>%
  EMMEANS("con", by="group")
setwd('C:/Users/DAWN/Desktop/matlab_finalhomework_analysis')