# 프로젝트

숭실대학교 기초과학융합연구소 2022 동계 인턴십 연구. 부스팅 계열 기법으로 질병(특히
폐암 LUNG) 발병 여부를 예측하고, 발병률과 설명변수(생활습관·검진 수치·유전형 SNP)의
상관관계를 분석한다. 표현형(phenotype)과 K-Chip SNP 유전 데이터를 결합해 분류 모델을 학습한다.

# 환경/실행

- 언어: Python 3(모델링 노트북) + R(초기 전처리 `code/dataprocess.R`).
- 주요 패키지: pandas, numpy, scikit-learn(RandomForest/DecisionTree/KNN/AdaBoost), xgboost, lightgbm,
  optuna(하이퍼파라미터 자동 탐색), Lasso(피처 선택). R은 data.table, dplyr, ggplot2, stringr.
- 실행: 주피터 노트북 셀 단위 실행. 자동화 테스트 스위트는 없다.
- 데이터 위치(`data/`):
  - `phenotype_1000.txt` — 표현형(검진·문진) 데이터, 탭 구분
  - `KCPS_r2_0.01_1000.csv` (약 30MB) — SNP 유전형 데이터
  - `KCPS_r2_0.01_1000.bim` / `.fam` — PLINK 포맷 SNP 메타(변이·샘플 정보)
  - `K-Chip_CodeBook.xlsx` — 변수 코드북
  - 노트북 안에는 `/data/phenotype.txt`, `KCPS_r2_0.01.csv` 같은 절대·축약 경로가 남아 있어
    로컬 실행 시 위 실제 파일명으로 바꿔야 한다.

# 폴더 구조

- `final/internship_inc_FVC.ipynb` — FVC(폐활량) 변수를 포함한 최종 파이프라인.
- `code/final/internship_exc_FVC` — FVC를 제외한 최종 파이프라인.
- `code/` — 단계별 실험 노트북. 파일명 앞 숫자가 작업 순서(1 시도 → 2 피처 중요도 → 3·4 전처리
  → 5 피처중요도/mglearn → 6 전처리·모델링 → 7 정확도 → 8 결과 → 9 lgbm). `dataprocess.R`는 R 전처리.
- `data/` — 원본 표현형·SNP 데이터와 코드북.
- `보고서/` — 인턴십 중간·결과 보고서(PDF/HWP/PPTX). `동계인턴십.pptx`는 발표자료.

# 컨벤션

- 분석은 두 시나리오로 나뉜다: FVC 포함(inc_FVC)과 제외(exc_FVC). 표본 수·선택 피처 수가 다르니 혼동 주의.
- 표현형 변수는 접미사 `_B`(baseline) 표기(예: AGE_B, SMOK_B, ALCO_B, HT_B, WT_B). BMI는 HT_B·WT_B에서 파생.
- 노트북 파일명은 `숫자+역할` 순서 규칙. SNP와 표현형은 8:2로 train/test 분할 후 결합, Lasso로 300~400개 피처 선택.
- 데이터 참조는 저장소 루트 기준 상대경로 권장(현 노트북은 절대경로 잔재 있음).

# 주의(gotchas)

- `KCPS_r2_0.01_1000.csv`(30MB), `.bim`/`.fam`, `phenotype_1000.txt`, `K-Chip_CodeBook.xlsx`는
  핵심 입력 데이터(유전체·표현형)다. 절대 삭제·정리하지 말 것. `.bim`/`.fam`은 PLINK 유전 데이터로 CSV와 짝이다.
- LUNG 양성은 전체의 약 0.026%로 극심한 클래스 불균형이다. 평가는 정확도가 아니라 AUC 중심으로 본다.
- 노트북/R 스크립트의 데이터 경로가 실제 파일명(`_1000` 접미사 등)과 어긋나므로 실행 전 경로를 맞출 것.
- 표현형 결측치 처리 규칙(PCAN80/FCAN80은 0 대체, 흡연량으로 흡연여부 보정 등)이 도메인 특화라 임의로 바꾸면 결과가 달라진다.
- 한글 파일/폴더명은 NFC로 통일. `__pycache__`, `.ipynb_checkpoints`, `.DS_Store`는 커밋 금지.
