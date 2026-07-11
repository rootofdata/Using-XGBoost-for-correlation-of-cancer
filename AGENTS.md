# AGENTS.md

범용 코딩 에이전트(Codex 등)를 위한 저장소 가이드. 사람용 상세 설명은 `README.md` / `README(KR).md` 참고.

## 프로젝트 요약

숭실대 기초과학융합연구소 2022 동계 인턴십 연구. 부스팅 기법으로 폐암(LUNG) 발병을 예측하고
발병률-설명변수 상관관계를 분석. 표현형(phenotype)과 K-Chip SNP 유전 데이터를 결합해 분류 모델 학습.

## 셋업 / 실행

```bash
# Python 3
pip install pandas numpy scikit-learn xgboost lightgbm optuna seaborn matplotlib
# R 전처리(code/dataprocess.R): data.table, dplyr, ggplot2, stringr 필요
```

- 실행은 주피터 노트북 셀 단위. 자동화 테스트 스위트는 없다.
- 모델: RandomForest, DecisionTree, KNN, AdaBoost, XGBoost, LGBM을 Optuna로 튜닝(AUC 최대화), Lasso로 피처 선택.

## 데이터 (`data/`)

- `phenotype_1000.txt` — 표현형 데이터(탭 구분)
- `KCPS_r2_0.01_1000.csv` (~30MB) — SNP 유전형 데이터
- `KCPS_r2_0.01_1000.bim` / `.fam` — PLINK 포맷 SNP 메타(변이·샘플). CSV와 짝이므로 함께 유지.
- `K-Chip_CodeBook.xlsx` — 변수 코드북
- 노트북 안 경로(`/data/phenotype.txt`, `KCPS_r2_0.01.csv`)는 실제 파일명(`_1000` 포함)과 다르니 실행 전 교체.

## 디렉토리

- `final/internship_inc_FVC.ipynb` — FVC 포함 최종 파이프라인
- `code/final/internship_exc_FVC` — FVC 제외 최종 파이프라인
- `code/` — 단계별 실험 노트북(파일명 앞 숫자가 순서), `dataprocess.R`
- `data/` — 원본 데이터·코드북
- `보고서/` — 인턴십 보고서, 발표자료

## 규칙 / 주의

- 대용량 CSV/XLSX와 `.bim`/`.fam`은 핵심 입력 데이터. 삭제·정리 금지.
- 분석은 FVC 포함(inc_FVC)/제외(exc_FVC) 두 시나리오로 나뉜다. 표본·피처 수가 다르니 섞지 말 것.
- 표현형 변수는 `_B`(baseline) 접미사. BMI는 HT_B·WT_B에서 파생.
- LUNG 양성 약 0.026%로 클래스 불균형이 심하다. 평가는 AUC 중심.
- 결측치 처리 규칙은 도메인 특화(임의 변경 시 결과 달라짐).
- 한글 파일/폴더명은 NFC로 통일. `__pycache__`, `.ipynb_checkpoints`, `.DS_Store`는 커밋 금지.
- CLAUDE.md와 이 문서의 내용은 일치시킨다.
