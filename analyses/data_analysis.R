rm(list=ls());

sink("C:/Users/DAWN/Desktop/matlab_finalhomework_analysis/Rconsole_output.txt");

# �Խ��ǵ÷ֽ��е����ط������������
questionnairedata <- read.csv('C:/Users/DAWN/Desktop/matlab_finalhomework_analysis/questionnaire.csv');

# �鿴����ṹ������������ȡ����
# head(questionnairedata);
# colnames(questionnairedata)
questionnairedata <- questionnairedata[,c(7,8,9,30)];

orderdata <- questionnairedata[order(-questionnairedata$�ܷ�),];

len = dim(orderdata)[1];
groupnum <-c(rep(1, len/2),rep(2,len/2));
# 1Ϊ�����ʾ��÷ָ߷��飬2Ϊ�����ʾ��÷ֵͷ���,����ķ��������
orderdata['group']=groupnum;

library(bruceR);

questionnaire_score_result<-MANOVA(data=orderdata, dv="�ܷ�", between="group")

highanxiousid<-c(orderdata$���������ı��Ա��[1:(len/2)]);
lowanxiousid<-c(orderdata$���������ı��Ա��[(len/2+1):len]);

# �ϲ����б��Ե�experimental data�ļ�

library(readxl);
# ���ù����ռ�
setwd('C:/Users/DAWN/Desktop/matlab_finalhomework_analysis/behavioral_data/exp');
# ��ȡ�ù����ռ��µ������ļ���
expfilenames <- dir();
# ��ʼ�����ݿ����ں�������ݺϲ�
expdata <- data.frame();
#ͨ��ѭ��������ݺϲ�
for (i in expfilenames){
  # ��������·��
  path <- paste0(getwd(),'\\',i)
  #res <- c(res,path)
  # ��ȡ���ϲ�����
  expdata <- rbind(expdata,read_excel(path = path))
}
expdata<-data.frame(expdata);
# �鿴����ṹ������������ȡ����
# head(expdata)
# colnames(expdata)
expdata<-expdata[,c(1,2,3,4,6)];
a <- sub("left","1",expdata$response);
b <- sub("right","2",a);

expdata$response <- b;


# �鿴�Ƿ���ȱʧֵ
# sum(is.nan(expdata))

expdata$response<-as.numeric(expdata$response);
expdata$subject_id<-as.numeric(expdata$subject_id);

#��������calculate_probabilityandRT.m�ļ�������ĸ�xlsx�ļ�

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



# �����������ɵ��ĸ�xlsx�ļ�������calculate_probabilityandRT.m�ļ�,�õ�����csv�ļ�������������csv�ļ���������ķ���




library(bruceR);

# winstayprobability��condition �� group �����ط������
winstaydata<-read.csv('C:/Users/DAWN/Desktop/matlab_finalhomework_analysis/wintable.csv');
names(winstaydata)<-c('high_safe','high_threat','low_safe','low_threat');
# head(winstay)
# # �鿴����ṹ������������ȡ����

winstaydata_anova<-data.frame(group=groupnum,consafe=c(winstaydata[,1],winstaydata[,3]),conthreat=c(winstaydata[,2],winstaydata[,4]));

winstayresult<-MANOVA(data=winstaydata_anova, dvs="consafe:conthreat", dvs.pattern="con(.)",between="group", within="con") %>%
  EMMEANS("group", by="con") %>%
  EMMEANS("con", by="group");

# loseshiftprobability��condition �� group �����ط������
loseshiftdata<-read.csv('C:/Users/DAWN/Desktop/matlab_finalhomework_analysis/losetable.csv');
names(loseshiftdata)<-c('high_safe','high_threat','low_safe','low_threat');
loseshiftdata_anova<-data.frame(group=groupnum,consafe=c(loseshiftdata[,1],loseshiftdata[,3]),conthreat=c(loseshiftdata[,2],loseshiftdata[,4]));

loseshiftresult<-MANOVA(data=loseshiftdata_anova, dvs="consafe:conthreat", dvs.pattern="con(.)",between="group", within="con") %>%
  EMMEANS("group", by="con") %>%
  EMMEANS("con", by="group");


# reaction time��condition �� group �����ط������
RTdata<-read.csv('C:/Users/DAWN/Desktop/matlab_finalhomework_analysis/RTtable.csv');
names(RTdata)<-c('high_safe','high_threat','low_safe','low_threat');
RTdata_anova<-data.frame(group=groupnum,consafe=c(RTdata[,1],RTdata[,3]),conthreat=c(RTdata[,2],RTdata[,4]));

RTresult<-MANOVA(data=RTdata_anova, dvs="consafe:conthreat", dvs.pattern="con(.)",between="group", within="con") %>%
  EMMEANS("group", by="con") %>%
  EMMEANS("con", by="group");

# evaluation��condition �� group�����ط������

# �ϲ����б��Ե������ļ� 
library(readxl);
setwd('C:/Users/DAWN/Desktop/matlab_finalhomework_analysis/behavioral_data/ev');
evfilenames <- dir();
# ��ʼ�����ݿ����ں�������ݺϲ�
evdata <- data.frame();
#ͨ��ѭ��������ݺϲ�
for (j in evfilenames){
  # ��������·��
  path2 <- paste0(getwd(),'\\',j)
  #res <- c(res,path)
  # ��ȡ���ϲ�����
  evdata <- rbind(evdata,read_excel(path = path2,col_names = F))
}
evdata<-data.frame(evdata);


# �鿴����ṹ������������ȡ����
# head(evdata)
# colnames(evdata)
evdata<-evdata[,c(2,4,6)];
names(evdata)<-c('id','consafe','conthreat');


# sum(is.na(evdata))

evdata$id<-as.numeric(evdata$id);
evdata$consafe<-as.numeric(evdata$consafe);
evdata$conthreat<-as.numeric(evdata$conthreat);


# �޸�һ�����������
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