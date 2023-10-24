## <2022 인턴십 SSU 프로젝트>

### 암 발생률의 상관 관계를 분석하고 예측하기 위해 부스팅 기술 사용

**1. 연구 목표**
- 부스팅 기술을 사용하여 COVID-19 및 다양한 질병률을 예측할 때 편향을 줄이고 편향과 지도 학습 간의 간격을 좁히는 것.
- 질병률과 설명 변수 간의 관계를 분석.

**2. 연구 내용**
- 여러 질병에 대해 'LUNG' (폐암)에 중점을 둔 연구를 진행했.

**2.1 데이터 전처리**

- 높은 수의 결측값을 가진 변수들 (MDM_B, MHTN_B, MLPD_B, PHTN_B, PDM_B, PLPD_B)을 LUNG과 높은 상관성 또는 관련성을 가지지 않아서가 아니라 결측값 때문에 편향되었다고 판단하여 제거.
- 가족력 및 과거력 데이터 (PCAN_00, FCAN_00)에서 LUNG 사례일 가능성이 높은 PCAN80 (0.33) 및 FCAN80 (0.053)을 포함하고 나머지 데이터는 0 또는 0.02 미만의 확률을 가진 것들은 제거. PCAN80 및 FCAN80의 결측값은 0으로 대체.
- 중복 데이터 (ALCO_AMOUNT_B, SMOKA_MOD_B)를 제거. 이 데이터들은 ALCO_B (알코올 소비) 및 SMOKA_B (흡연량)과 중복됨.
- HT_B (키) 및 WT_B (몸무게)를 사용하여 BMI (체질량 지수) 특성을 생성하고 HT_B 및 WT_B를 제거.
- 결측값 비율이 높은 FEV1은 제거하고 FVC를 FVC가 포함된 것과 포함되지 않은 두 하위 집합으로 나눔 (약 40-50%의 결측값).

- 페노타입 데이터에는 총 23(또는 24)개의 변수가 포함되었습니다: AGE_B, SMOK_B, ALCO_B, EXER_B, SBP_B, DBP_B, CHO_B, LDL_B, TG_B, HDL_B, FBS_B, GOT_B, GPT_B, GGT_B, URIC_B, BIL, WBC, CREAT, LUNG, SEX1, CRC, PCAN80, FCAN80, BMI, (FVC가 포함되어 있다면 FVC).

**2.2 데이터 특성 수**
- 데이터를 8:2의 학습 및 테스트 비율로 나누고 페노타입 및 SNPs 데이터를 결합. Lasso를 사용하여 300-400개의 특성을 선택.

**2.2.1. FVC가 있는 경우:**

- 총 데이터 수: 8763, LUNG 사례는 232개 (약 0.026%).
- 학습 데이터: 7010, 테스트 데이터: 1753.
- 선택된 특성: 330 (SNPs) + 24 (페노타입) = 총 354개의 특성.

**2.2.2. FVC가 없는 경우:**

- 총 데이터 수: 13505, LUNG 사례는 350개 (약 0.026%).
- 학습 데이터: 10804, 테스트 데이터: 2701.
- 선택된 특성: 401 (SNPs) + 23 (페노타입) = 총 424개의 특성.

**3. 모델링**
- 여섯 가지 분류 모델을 사용: RandomForestClassifier, DecisionTreeClassifier, KNeighborsClassifier, AdaboostClassifier, XGBClassifier, LGBMClassifier. Optuna (AutoML 기술)를 사용하여 모델 매개 변수를 자동으로 설정하여 AUC 점수를 최대화함.

**3.1. FVC가 있는 경우:**

- 알고리즘	최상의 시도	Best AUC 점수
- Random forest	max_depth: 6, max_leaf_nodes: 157, n_estimators: 162	0.703
- Decision tree	max_depth: 3, max_leaf_nodes: 970	0.714
- KNeighbors	n_neighbors: 182, leaf_size: 184	0.657
- Adaboost	n_estimators: 375	0.668
- XGBoost	n_estimators: 157, min_child_weight: 156	0.761
- LGBM	n_estimators: 59, max_depth: 866	0.700

**3.2. FVC가 없는 경우:**

- 알고리즘	최상의 시도	Best AUC 점수
- Random forest	max_depth: 2, max_leaf_nodes: 305, n_estimators: 310	0.745
- Decision tree	max_depth: 6, max_leaf_nodes: 867	0.764
- KNeighbors	n_neighbors: 157, leaf_size: 156	0.679
- Adaboost	n_estimators: 59	0.702
- XGBoost	n_estimators: 833, min_child_weight: 212	0.767
- LGBM	n_estimators: 182, max_depth: 182	0.754

**4. 최종 AUC 결과**
- FVC가 있는 경우 (354개의 특성): XGBoost: 0.761
- FVC가 없는 경우 (424개의 특성): XGBoost: 0.767

결론적으로 FVC가 없을 때 특히 LUNG을 예측하는 데 효과적인 XGBoost가 최고의 AUC 값인 0.761 및 0.767을 달성.

**5. 향후 연구 계획**
- 향후 연구에서는 더 복잡한 특성을 포함하여 AUC 값을 향상시킬 수 있는 딥 러닝 (분류) 또는 AutoEncoder 방법을 탐구할 계획.
