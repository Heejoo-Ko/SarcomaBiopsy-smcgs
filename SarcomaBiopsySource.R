library(readxl)
library(dplyr)

#read data------------------------------------------------------------------------------------------
setwd("C:/Users/USER/Desktop/sarcoma/biopsy")
a<-excel_sheets("SarcomaDataSheet.xlsx") %>% 
  lapply(function(x){read_excel("SarcomaDataSheet.xlsx",sheet=x,skip=2)})
b<-a[[1]] %>% 
  left_join(a[[2]],by="ȯ�ڹ�ȣ") %>% 
  left_join(a[[3]],by="ȯ�ڹ�ȣ") %>% 
  left_join(a[[4]],by="ȯ�ڹ�ȣ") %>% 
  left_join(a[[5]],by="ȯ�ڹ�ȣ") %>% 
  left_join(a[[6]],by="ȯ�ڹ�ȣ") %>% 
  left_join(a[[7]],by="ȯ�ڹ�ȣ")

b[["ECOG\r\n\r\n0/1/2/3/4"]][which(is.na(b[["ECOG\r\n\r\n0/1/2/3/4"]]))]<-"0"
b[["EBL\r\n(ml)"]]<-ifelse(b[["EBL\r\n(ml)"]]=="UK",NA,as.numeric(b[["EBL\r\n(ml)"]]))
b$Age<-as.numeric(b[["������¥\r\n\r\ndd-mm-yyyy"]]-b[["�������\r\n\r\ndd-mm-yyyy"]])/365.25

#Q1 : �Լ��� ������ ¥�� �ǳ��� ���� ��� �̺κ� ReadData.R, Method.R.. �̷���..
#Q2 : �����͵� �߿��� �� ECOG, EBL �� ���� ó���߳���?
#Q3 : b[[����]]]�� b$������ ���� �ǰ���?
#Q4 : b[[����]]������ a[[��Ʈ��ȣ]]�� �ٸ� ���� ������.... ��.. ��..

#Method------------------------------------------------------------------------------------------
c<-b %>% 
  filter(`Primary ��������\r\n\r\n0. Primary tumor\r\n1. Residual after incomplete resection\r\n2. Local recurrence.x`== 0,
         `ȯ�ڹ�ȣ`!=21733889) %>% 
  mutate(biopsy_preop_primary=as.integer(`���� �� Biopsy\r\n\r\n0. None\r\n1. Primary site\r\n2. Local recurrence site\r\n3. Metastatic site`==1)
         ,type_needle=`Type of needle\r\n\r\n0. Core\r\n1. FNA\r\n2. N/A\r\n3. Unknown`) %>%
  mutate(type_needle=ifelse(type_needle==0,"Core needle",ifelse(type_needle==1,"FNA","Excisional biopsy")))

out<-c %>% select(ȯ�ڹ�ȣ,Age,`����\r\n\r\nM/F`,biopsy_preop_primary,type_needle)
names(out)[3]<-"Sex"

# #2001�� 9�� ���� 2020�� 2������ ������ retroperitoneal sarcoma ȯ�� ��
# #primary tumor 274�� (ù��° sheet H�� ��0��) #ȯ�ڹ�ȣ 21733889 ���� 273��
# out %>% nrow
# #preOP biopsy of primary tumor 69 ��
# #(�ι�° sheet O�� ��1��, ȯ�ڹ�ȣ 21733889 ����) vs non-biopsy 204�� �� (�ι�° sheet O�� ������)
# out %>% filter(biopsy_preop_primary==TRUE) %>% nrow
# out %>% filter(biopsy_preop_primary==FALSE) %>% nrow
# #Core needle 62�� (�ι�° sheet P�� ��0��)
# out %>% filter(type_needle=="Core needle",biopsy_preop_primary==TRUE) %>% nrow
# #FNA 4�� (�ι�° sheet P�� ��1��)
# out %>% filter(type_needle=="FNA") %>% nrow
# #Excisional biopsy 3�� (�ι�° sheet P�� ��2���� ��3�� 4�� �� 21733889����)
# out %>% filter(type_needle=="Excisional biopsy",biopsy_preop_primary==1) %>% nrow

#Outcome------------------------------------------------------------------------------------------
#Biopsy accuracy-result_biopsy_preop,result_biopsy_postop
out$result_biopsy_preop<-c[["preOP Bx. ���\r\n\r\n0. WD \r\n1. DD \r\n2. Pleomorphic \r\n3. LMS\r\n4. MPNST\r\n5. Solitary fibrous tumor\r\n6. PEComa\r\n7. Other"]]
out$result_biopsy_postop<-c[["�������\r\n\r\n0. WD Liposarcoma\r\n1. DD Liposarcoma\r\n2. Pleomorphic Liposarcoma\r\n3. Leiomyosarcoma\r\n4. MPNST\r\n5. Solitary fibrous tumor\r\n6. PEComa\r\n7. Other.y"]]
#Q6 : ������� ������ sheet 1 �� �ϳ� ���ִµ�.. ���� ������ ��ġ�ؿ�. �߿����� ���� ����. �ᱹ result_biopsy_postop �� result_biopsy�� ������ �ƴѰ���?

#Patients survival rate-death,day-FU
out$death<-as.integer(c[["�������\r\n\r\n0.Alive\r\n1.Dead\r\n2.Unknown.y"]])
out$day_FU<-as.numeric(c[["������ f/u\r\n\r\ndd-mm-yyyy"]]-c[["������¥\r\n\r\ndd-mm-yyyy"]])
#Q8 : ""�� [[]]�� ���� ���ǹ������� ``�� ���� ���ϱ�..

#Local recurrence free survival rate-recur_local,recur_site,recur_day
out$recur_local<-c[["���#1\r\n\r\n0: ��\r\n1: ��"]]
out$recur_site<-c$`Site of local recurrence`
#Q9 : ���� �� ���� �� c[[]], c$ �̷��� �ٸ��� ������??
out$recur_site<-ifelse(out$recur_site=="6",NA,out$recur_site)
out$recur_day<-ifelse(out$recur_local==1,
                      as.numeric(as.Date(as.integer(c[["Date of local recurrence"]]),origin="1899-12-30")-as.Date(c[["������¥\r\n\r\ndd-mm-yyyy"]])),
                      as.numeric(c[["������ f/u\r\n\r\ndd-mm-yyyy"]]-c[["������¥\r\n\r\ndd-mm-yyyy"]]))
#Q18 : out$recur_day ��� ���� ������ �͵��� ��¼��..
#Q15 : ppt�� Sarcomatosis patter �� site of local recurrence�� 4. sarcomatosis �� �ٸ��ǰ���? ���� sarcomatosis pattern�� ��Ÿ�ΰŸ�.. 

#RT-RTdose,RTx_tissue_expander
out$RTx_dose<-c[["RT dose\r\n(Gy)"]] #Q10 : �� �� ������ ���ϽŰǰ���??
cond1<-c[["RT timing\r\n\r\n0.None \r\n1.Preop only\r\n2. IORT only\r\n3.Preop + IORT\r\n4.Postop only\r\n5.Preop + postop boost\r\n6.IORT + postop"]] %in% c("1","5")
cond2<-(c[["RT timing\r\n\r\n0.None \r\n1.Preop only\r\n2. IORT only\r\n3.Preop + IORT\r\n4.Postop only\r\n5.Preop + postop boost\r\n6.IORT + postop"]]=="4") & (c[["Tisuue expander insertion \r\n����\r\n\r\n0. No\r\n1. Yes"]]=="1")
out$RTx_tissue_expander<-as.integer(cond1|cond2)
#Q16 : ������ �̷��� �����ϴ°� �ǹ̰� ������..? preop�� �߰ų� postop&&tissueexpander �� ��츦 ���� �Ŵϱ�..
#tissue expander�� ���� �˱�δ�.. �� ���� ���� �Ŀ� ���߿� ���� recon�� ���� ǳ�������� �־�δ� ��� �ƴѰ���? html ���� �� �Ʒ��ٿ� �� �ǹ��Ͻ� ���� �𸣰ھ��!


#Result------------------------------------------------------------------------------------------
#�������
out$result_biopsy<-c[["�������\r\n\r\n0. WD Liposarcoma\r\n1. DD Liposarcoma\r\n2. Pleomorphic Liposarcoma\r\n3. Leiomyosarcoma\r\n4. MPNST\r\n5. Solitary fibrous tumor\r\n6. PEComa\r\n7. Other.y"]]
#Neoadjuvant therapy
out$RTx_preop<-as.integer(c[["������ \r\nRT ����\r\n\r\n0.No\r\n1.Yes"]])
out$Chemo_preop<-as.integer(c[["������ \r\nChemo ����\r\n\r\n0.No\r\n1.Yes"]])
out$Neoadjuvant<-as.integer(out$RTx_preop|out$Chemo_preop)
#Q11 : ppt�� �ִ� A+B�� ���� and�� �ƴϰ� or �ǹ�?
#Q12 : excel ���� �ϳ��� �� �´°Ŵ� ���� 1���� �߰��ϼż� �׷��ǰ��� �ƴ� ����?? 1���� Ư���� �ʿ伺?!
#Q13 : '������chemo����'column�̶� 'neoadjuvant chemo����'column ���� �����մϴ�.

#�߰��� �׸��
out$meta_liver<-c[["Liver metastasis\r\n\r\n0. No\r\n1. Yes"]]
out$meta_lung<-c[["Lung metastasis\r\n\r\n0. No\r\n1. Yes"]]
#Q13 : bone�̶� abdominal�� ppt�� ���µ� �ϴ� �ϽŰǰ���??
out$meta_bm<-c[["Bone metastasis\r\n\r\n0. No\r\n1. Yes"]]
out$meta_abd<-c[["Intra-abdominal metastasis\r\n\r\n0. No\r\n1. Yes"]]
out$multifocal<-c[["Mutifocality ����\r\n\r\n0. No\r\n1. Yes"]]

#�������� ����
#Q13 : info$resection�� �ƴϰ� info.resection���� �� ������ �ϳ��� �ٷ�� ������? ���� �Ϻ� ������ out$A���� out.A�ε� ������ ã��������.. ����
#Q14 : �������� \r\n��� �� �����ϴ� ������ ���̿� 2�� �־ ���Խ��Ѽ� �����߽��ϴ�.
info.resection<-c %>% 
  select(starts_with("��������")) %>% 
  mutate_at(1:25,as.integer) %>% 
  mutate_at(26,function(x){as.integer(!is.na(x))})
info.resection[26]
out$num_resected_organ<-rowSums(info.resection,na.rm=T)

#RT
out$RTx_total<-as.integer(c[["���� ���� RT ����\r\n\r\n0.No\r\n1.Yes"]])
#Chemo
out$Chemo_postop<-as.integer(c[["Adjuvant chemo ����\r\n\r\n0.No\r\n1.Yes"]])
out$Chemo_both<-as.integer(out$Chemo_preop|out$Chemo_postop)

#Risk factor analysis for tumor recurrence
#Q17 : tumor size ���� ������ �־����
out$tumor_size<-c[["���� ũ��\r\n(Tumor size, mm)\r\n�ٹ߼��� ��� largest tumor size"]]
#resection margin
out$resection_margin<-c[["Surgical margins\r\n\r\n0. R0/R1\r\n1. R2\r\n2. Not available"]]
out$resection_margin<-ifelse(out$resection_margin=="2",NA,out$resection_margin)
#histologic subtype (LPS=1, nonLPS=0)
out$result_biopsy2<-as.integer(out$result_biopsy %in% c(0,1))
#FNCLCC tumor grade
out$FNCLCC_grade<-c[["FNCLCC grade\r\n\r\n1. total score 2-3\r\n2. total score 4-5\r\n3. total score 6,7,8"]]
out$FNCLCC_grade<-ifelse(out$FNCLCC_grade=="UK",NA,out$FNCLCC_grade)


#------------------------------------------------------------------------------------------

#Q5 : ������ Ŭ���� ������ ���ϳ���?

out %>% head
out %>% summary





