# BN-Affective-Module-DBM
Data and programs for the article ‘Bayesian Network Approach to Building an Affective Module for a Driver Behavioural Model’.

# data_MW.Rdata
The `data_MW.Rdata` dataset contains the following variables:
- code: Participant identifier.
- phase: Assessment phase (0 = baseline, 1 = after the cognitive block).
- sex: Sex (0 = women, 1 = men).
- age: Age (years).
- BMI: Body mass index.
- SRT: Standard deviation of RR intervals (ms).
- SDD: Standard deviation of successive differences between adjacent RR intervals (ms).
- MHR: Mean heart rate (beats per minute).
- RLH: Ratio of low-frequency to high-frequency heart rate variability (HRV) variance.
- MNB: Mean number of breaths per minute.
- mental_load: Binary indicator of mental workload (1 = participant entered the mental state; 0 = otherwise).
- active_fatigue: Binary indicator of active fatigue (1 = participant entered the mental state; 0 = otherwise).

### Model.R

The `model.R` script contains the R code required to reproduce the results presented in the accompanying article.

**Requirements:**
- R version 4.4.1
- The following R packages:
  - `bnlearn`
  - `rjags`
  - `coda`
  - `Rgraphviz`

Install the required packages using:

```r
install.packages(c("bnlearn", "coda", "rjags"))
```

`Rgraphviz` can be installed through Bioconductor:

```r
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("Rgraphviz")
```

To reproduce the results, run `model.R` in R after installing the required dependencies.
