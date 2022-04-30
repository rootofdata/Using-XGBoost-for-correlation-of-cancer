library(data.table)
library(dplyr)
library(ggplot2)
library(stringr)

ph <- fread("phenotype.txt", header=T, sep="\t")
snp <- fread("KCPS_r2_0.01.csv", header=T, sep=",")

##데이터 처리
p <- ph %>% mutate(INDEX=1:16955) %>% select(INDEX, everything())
check <- function(){
  colSums(is.na(p))
}

##->SMOK_B(1:비흡연자, 2:과거흡연자, 3:흡연자)
sum(is.na(p$SMOK_B)) #177명 결측치

#흡연여부 결측 and 흡연량 존재(3명, 흡연량에따라 흡연여부 결정)
sm_c1 <- p %>% select(INDEX, SMOK_B, SMOKA_MOD_B) %>% filter(is.na(SMOK_B), !is.na(SMOKA_MOD_B))
sm_c1[,2] <- c(3,1,3)
sm_c1


#흡연여부 결측 and 흡연량 결측(174명, 비흡연자가정)
sm_c2 <- p %>% select(INDEX, SMOK_B, SMOKA_MOD_B) %>% filter(is.na(SMOK_B), is.na(SMOKA_MOD_B))
sm_c2[,2] <- 1

new_smok <- rbind(sm_c1, sm_c2)[,1:2] %>% arrange(INDEX)
new_smok
p[new_smok$INDEX, "SMOK_B"] <- new_smok$SMOK_B
sum(is.na(p$SMOK_B)) #SMOK_B 결측제거

##--> SMOKA_MOD_B 
sum(is.na(p$SMOKA_MOD_B)) #5950명 결측치
table(p$SMOK_B, p$SMOKA_MOD_B, useNA = "ifany")

##이상치 수정
sma1 <- p %>% select(INDEX, SMOK_B, SMOKA_MOD_B) %>% filter(SMOKA_MOD_B>60) #하루에 3갑이상은 응답오류로 간주
sma1[,3] <- sma1[,3]/7 #일주일에 피는 담배량을 응답했을거라 가정
p[sma1$INDEX, "SMOKA_MOD_B"] <- round(sma1$SMOKA_MOD_B,1)

##비흡연자
sma2 <- p %>% select(INDEX, SMOK_B, SMOKA_MOD_B) %>% 
  filter(SMOK_B==1 ,SMOKA_MOD_B>0|is.na(SMOKA_MOD_B)) #비흡연자가 흡연량 존재 or 결측값
p[sma2$INDEX, "SMOKA_MOD_B"] <- 0  

##과거흡연자
p %>% filter(SMOK_B == 2) %>% select(SMOKA_MOD_B) %>% 
  table(useNA = "ifany") #과거흡연자 흡연량존재(비흡연자와 차이 필요)
#(i) 과거흡연자의 흡연량 결측치를 0으로 대치
sma3 <- p %>% filter(SMOK_B==2, is.na(SMOKA_MOD_B)) %>% select(INDEX, SMOKA_MOD_B) 
p[sma3$INDEX, "SMOKA_MOD_B"] <- 0  

#(ii) 과거흡연자중 흡연량이 0인 값을 평균으로 대치
meanval <- p %>% filter(SMOK_B==2, SMOKA_MOD_B!=0) %>% select(SMOKA_MOD_B) %>% summarise(mean(SMOKA_MOD_B))
sma4 <- p %>% filter(SMOK_B==2, SMOKA_MOD_B==0) %>% select(INDEX, SMOKA_MOD_B)
p[sma4$INDEX, "SMOKA_MOD_B"] <- round(meanval,1)

#(iii) 현재흡연자와 차이를두기위해 흡연량을 1/10값으로 대치
sma5 <- p %>% filter(SMOK_B==2) %>% select(INDEX, SMOKA_MOD_B)
p[sma5$INDEX, "SMOKA_MOD_B"] <- round(sma5$SMOKA_MOD_B/10,1)

##현재흡연자 
p %>% filter(SMOK_B==3) %>% select(SMOKA_MOD_B) %>% 
  table(useNA="ifany") #흡연자의 흡연량 결측값을 평균값으로 대치

meanval1 <- p %>% filter(SMOK_B==3, !is.na(SMOKA_MOD_B)) %>% select(SMOKA_MOD_B) %>% summarise(mean(SMOKA_MOD_B))
sma6 <- p %>% filter(SMOK_B==3, is.na(SMOKA_MOD_B)) %>% select(INDEX, SMOKA_MOD_B)
p[sma6$INDEX, "SMOKA_MOD_B"] <- round(meanval1 ,1)

table(p$SMOK_B, p$SMOKA_MOD_B, useNA = "ifany")

colSums(is.na(p)) #결측치 제거완료

##--> ALCO_B (음주여부 1:예 2:아니오)
table(p$ALCO_B, useNA = "ifany")
ac1 <- p %>% select(INDEX, ALCO_B, ALCO_AMOUNT_B) %>% 
  filter(is.na(ALCO_B), ALCO_AMOUNT_B>0) #음주여부 무응답 but 음주량 존재 -> 음주여부 예(1)로 수정

p[ac1$INDEX, "ALCO_B"] <- 1

ac2 <- p %>% select(INDEX, ALCO_B, ALCO_AMOUNT_B) %>% 
  filter(is.na(ALCO_B), ALCO_AMOUNT_B==0) #음주여부 무응답 and 음주량 0 -> 음주여부 아니오(2)로 수정
p[ac2$INDEX, "ALCO_B"] <- 2

ac3 <- p %>% select(INDEX, ALCO_B, ALCO_AMOUNT_B) %>% 
  filter(is.na(ALCO_B), is.na(ALCO_AMOUNT_B)) #음주여부 무응답 and 음주량 무응답 -> 음주여부 아니오(2)로 수정

p[ac3$INDEX, "ALCO_B"] <- 2

sum(is.na(p$ALCO_B)) #ALCO_B 결측값 존재 x

##--> ALCO_AMOUNT_B (음주량)
sum(is.na(p$ALCO_AMOUNT_B)) #결측값 1450

#음주여부(1) and 음주량 결측 -> 음주량(0)으로 수정
aca1 <- p %>% select(INDEX, ALCO_B, ALCO_AMOUNT_B) %>% 
  filter(ALCO_B==1, is.na(ALCO_AMOUNT_B)) 
p[aca1$INDEX, "ALCO_AMOUNT_B"] <- 0

#음주여부(2) and 음주량 결측 -> 음주량 평균으로 대체
acamean <- p %>% filter(ALCO_B==2, !is.na(ALCO_AMOUNT_B)) %>% 
  summarise(mean(ALCO_AMOUNT_B)) 

aca2 <- p %>% select(INDEX, ALCO_B,ALCO_AMOUNT_B) %>% filter(ALCO_B==2, is.na(ALCO_AMOUNT_B))
p[aca2$INDEX, "ALCO_AMOUNT_B"] <- acamean

#ALCO_AMOUNT_B 결측 확인
sum(is.na(p$ALCO_AMOUNT_B)) #0

colSums(is.na(p))

##-->EXER_B (규칙적으로 운동하는가 1:예 2:아니오)
#무응답 -> 아니오로 수정
table(p$EXER_B, useNA = "ifany") 
ex <- p %>% select(INDEX, EXER_B) %>% filter(is.na(EXER_B))
p[ex$INDEX, "EXER_B"] <- 2

##--> HT_B(신장)
#무응답 -> 성별에따른 평균키로 대체(1:남, 2:여)
table(p$HT_B, p$SEX1,useNA = "ifany") 
man.mean <- p %>% filter(SEX1==1) %>% summarise(mean(HT_B, na.rm=T))
wom.mean <- p %>% filter(SEX1==2) %>% summarise(mean(HT_B, na.rm=T))

ht1 <- p %>% filter(SEX1==1, is.na(HT_B)) %>% select(INDEX)
ht2 <- p %>% filter(SEX1==2, is.na(HT_B)) %>% select(INDEX)
p[ht1$INDEX, "HT_B"] <- man.mean; p[ht2$INDEX, "HT_B"] <- wom.mean

sum(is.na(p$HT_B)) #0

##--> WT_B(체중)
#성별과 키에따라 대체 
wt1 <- p %>% filter(SEX1==1, is.na(WT_B)) %>% select(INDEX, SEX1, HT_B, WT_B)
wt2 <- p %>% filter(SEX1==2, is.na(WT_B)) %>% select(INDEX, SEX1, HT_B, WT_B) #1명 제외 모두 ht_b도 결측값이였음

mwt.mean <- p %>% filter(SEX1==1) %>% summarise(mean(WT_B, na.rm=T))
wwt.mean <- p %>% filter(SEX1==2) %>% summarise(mean(WT_B, na.rm=T))

p[wt1$INDEX, "WT_B"] <- mwt.mean; p[wt2$INDEX, "WT_B"] <- wwt.mean; 

##--> WAIST_B(허리둘레)
#성별과 키 몸무게에따라 대체
p %>% filter(!is.na(WAIST_B)) %>% select(INDEX, SEX1, WT_B, HT_B, WAIST_B) %>% 
  ggplot(mapping=aes(x=WT_B, y=WAIST_B)) + geom_point(aes(color=SEX1))

#키 몸무게값만으로 허리둘레 대체가능


##--> SBP_B(수축기혈압), DBP_B(이완기혈압)
#평균값으로 대체
table(p$SBP_B, useNA="ifany")
p <- p %>% mutate(SBP_B = ifelse(is.na(SBP_B), mean(SBP_B, na.rm=T), SBP_B),
                  DBP_B = ifelse(is.na(DBP_B), mean(DBP_B, na.rm=T), DBP_B))


##--> CHO_B ~ URIC_B 
#평균값으로 대체
p <- p %>% mutate(CHO_B = ifelse(is.na(CHO_B), mean(CHO_B, na.rm=T), CHO_B),
                  LDL_B = ifelse(is.na(LDL_B), mean(LDL_B, na.rm=T), LDL_B),
                  TG_B = ifelse(is.na(TG_B), mean(TG_B, na.rm=T), TG_B),
                  HDL_B = ifelse(is.na(HDL_B), mean(HDL_B, na.rm=T), HDL_B),
                  FBS_B = ifelse(is.na(FBS_B), mean(FBS_B, na.rm=T), FBS_B),
                  GOT_B = ifelse(is.na(GOT_B), mean(GOT_B, na.rm=T), GOT_B),
                  GPT_B = ifelse(is.na(GPT_B), mean(GPT_B, na.rm=T), GPT_B),
                  GGT_B = ifelse(is.na(GGT_B), mean(GGT_B, na.rm=T), GGT_B),
                  URIC_B = ifelse(is.na(URIC_B), mean(URIC_B, na.rm=T), URIC_B)
)


##-> PCAN80 ~ FVC 
#결측값이 너무 많기때문에 분석에서 제외

##-> BIL, WBC, CREAT
#평균으로 대체
p <- p %>% mutate(BIL = ifelse(is.na(BIL), mean(BIL, na.rm=T), BIL),
                  WBC = ifelse(is.na(WBC), mean(WBC, na.rm=T), WBC),
                  CREAT = ifelse(is.na(CREAT), mean(CREAT, na.rm=T), CREAT))
pheno <- p

##데이터 생성
pheno <- pheno[,-c(1,2)]; snp <- snp[,-1] #IID를 key값으로 사용
str_locate(names(pheno), "STOMA"); str_locate(names(pheno), "RECTM")
cancer <- pheno[,c(1,47:54)]

c.name <- setdiff(names(pheno)[colSums(is.na(pheno))==0], names(cancer)) #결측값 존재열 제외 모두 사용
c.name #사용하는 변수
ph_dat <- pheno %>% select(IID, c.name)

cancer <- as.data.frame(cancer); ph_dat <- as.data.frame(ph_dat); snp <- as.data.frame(snp)

##데이터 결합
##->cancer + pheno
cp_dat <- list()
for (i in 1:8){
  cp_dat[[i]] <- list(cancer=names(cancer)[i+1], data=merge(cancer[,c(1,i+1)], ph_dat, by="IID"))
}

##-> cancer + snp
cs_dat <- list()
for (i in 1:8){
  cs_dat[[i]] <- list(cancer=names(cancer)[i+1], data=merge(cancer[,c(1,i+1)], snp, by="IID"))
}

##-> cancer + pheno + snp
cps_dat <- list()
for (i in 1:8){
  cps_dat[[i]] <- list(cancer=names(cancer)[i+1], data=merge(cp_dat[[i]]$data, snp, by="IID"))
}

##--------------------------------------------------------------->
set.seed(1)
train <- sort(sample(nrow(cp_dat[[1]]$data), size=floor(0.8*nrow(cp_dat[[1]]$data))))
test <- sort(setdiff(1:nrow(cp_dat[[1]]$data), train))

train
test