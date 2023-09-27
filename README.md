## Using boosting techniques to analyze and predict the correlation of cancer incidence rates.   
<2022_internship_ssu project>
   
### **1. Research Objectives**   
To use boosting techniques to reduce bias and bridge the gap between bias and supervised learning in predicting COVID-19 and various disease rates.  
To analyze the relationship between disease rates and explanatory variables.  
   
### **2. Research Content**   
For various diseases, the study focused on 'LUNG' (lung cancer) and conducted the following steps:   
   
**2.1 Data Preprocessing**
- Removed variables (MDM_B, MHTN_B, MLPD_B, PHTN_B, PDM_B, PLPD_B) with a high number of missing values from the phenotype data, not solely due to missing values but also due to their low correlation or relevance with LUNG.  

- Included PCAN80 (0.33) and FCAN80 (0.053), which had a high probability of being LUNG cases, from family history and past history data (PCAN_00, FCAN_00), while removing other data with probabilities of 0 or less than 0.02. Replaced missing values in PCAN80 and FCAN80 with zeros.  

- Removed overlapping data (ALCO_AMOUNT_B, SMOKA_MOD_B) as they were redundant with ALCO_B (alcohol consumption) and SMOKA_B (smoking amount).

- Created a BMI (Body Mass Index) feature using HT_B (height) and WT_B (weight) and removed HT_B and WT_B.  
- Due to a high percentage of missing values (about 40-50%), removed FEV1 and divided FVC into two subsets, one with FVC included and one without.  

Phenotype data included a total of 23 (or 24) variables, as follows:
AGE_B, SMOK_B, ALCO_B, EXER_B, SBP_B, DBP_B, CHO_B, LDL_B, TG_B, HDL_B, FBS_B, GOT_B, GPT_B, GGT_B, URIC_B, BIL, WBC, CREAT, LUNG, SEX1, CRC, PCAN80, FCAN80, BMI, (FVC if included).

**2.2 Number of Data Features**  
Split the data into a 8:2 train-test ratio and combined phenotype and SNPs data. Used Lasso to select 300-400 features.    

**2.2.1. In cases where FVC is present:**   
- Total data count: 8763, with 232 LUNG cases (approx. 0.026%).   
- Train data: 7010, Test data: 1753.   
- Selected features: 330 (SNPs) + 24 (phenotype) = Total 354 features.    

**2.2.2. In cases where FVC is absent:**    
- Total data count: 13505, with 350 LUNG cases (approx. 0.026%).     
- Train data: 10804, Test data: 2701.      
- Selected features: 401 (SNPs) + 23 (phenotype) = Total 424 features.        

### **3. Modeling**      
Utilized six classification models: RandomForestClassifier, DecisionTreeClassifier, KNeighborsClassifier, AdaboostClassifier, XGBClassifier, and LGBMClassifier. Used Optuna (AutoML technique) to automatically set model parameters to maximize AUC scores.    

**3.1. In cases where FVC is present:**   

|Algorithm|Best trial|Best AUC score|
|:------:|---|:---:|
|Random forest|max_depth: 6, max_leaf_nodes: 157, n_estimators: 162|0.703|    
|Decision tree|max_depth: 3, max_leaf_nodes: 970|0.714|    
|KNeighbors|n_neighbors: 182, leaf_size: 184|0.657|    
|Adaboost|n_estimators: 375|0.668|    
|XGBoost|n_estimators: 157, min_child_weight: 156|0.761|    
|LGBM|n_estimators: 59, max_depth: 866|0.700|     
     
**3.2. In cases where FVC is absent:**    
|Algorithm|Best trial|Best AUC score|
|:------:|---|:---:|
|Random forest|max_depth: 2, max_leaf_nodes: 305, n_estimators: 310|0.745|    
|Decision tree|max_depth: 6, max_leaf_nodes: 867|0.764|     
|KNeighbors|n_neighbors: 157, leaf_size: 156|0.679|     
|Adaboost|n_estimators: 59|0.702|     
|XGBoost|n_estimators: 833, min_child_weight: 212|0.767|     
|LGBM|n_estimators: 182, max_depth: 182|0.754|     

### **4. Final AUC Results**    
- FVC Present (354 features): **XGBoost: 0.761**     
- FVC Absent (424 features): **XGBoost: 0.767**
    
**In conclusion, XGBoost achieved the highest AUC values of 0.761 and 0.767, demonstrating its effectiveness in predicting LUNG, especially when FVC is absent.**   

### **5. Future Research Plans**   

In future research, we plan to explore deep learning (classification) or AutoEncoder methods, with the potential to improve AUC values by incorporating more sophisticated features.
