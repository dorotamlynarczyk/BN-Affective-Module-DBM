# Load libraries for Bayesian modeling and plotting
library(bnlearn)
library(Rgraphviz)
library(rjags)
library(coda)

# Load the dataset
load("data_MW.Rdata")

# Define and print the DAG structure
bn <- model2network("[mental_load][active_fatigue][SDD|mental_load:active_fatigue][MHR|mental_load:active_fatigue:SDD][RLH|mental_load:active_fatigue:SDD:MHR][SRT|active_fatigue:SDD:MHR:RLH][MNB|SRT]")
graphviz.plot(
  bn, fontsize=15, shape="rectangle",
  highlight = list(nodes = c("mental_load", "active_fatigue"), col = "orange", fill = "orange"),
  layout = "dot"
)

# Set seed for reproducibility
set.seed(5432)

# Define the Bayesian hierarchical model in JAGS syntax
model_def <- "
model {
  # Priors for regression coefficients (intercept, sex, age, BMI, ML, AF, SDD, MHR, RLH, SRT)
  for (j in 1:5) {
    beta1[j] ~ dnorm(0, 0.04)  # intercept
  }
  for (j in 1:5) {
    beta2[j] ~ dnorm(0, 0.04)  # sex
  }
  for (j in 1:5) {
    beta3[j] ~ dnorm(0, 0.04)  # age
  }
  for (j in 1:5) {
    beta4[j] ~ dnorm(0, 0.04)  # BMI
  }
  for (j in 1:3) {
    beta6[j] ~ dnorm(0, 0.04)  # mental_load (ML)
  }
  for (j in 1:3) {
    beta7[j] ~ dnorm(0, 0.04)  # active_fatigue (AF)
  }
  for (j in 1:3) {
    beta8[j] ~ dnorm(0, 0.04)  # SDD
  }
  for (j in 1:2) {
    beta9[j] ~ dnorm(0, 0.04)  # MHR
  }
  betaa10[1] ~ dnorm(0, 0.04)  # RLH
  betaa11[1] ~ dnorm(0, 0.04)  # SRT
  
  # Priors for standard deviations of continuous variables
  for (k in 1:5) {
    sigma[k] ~ dunif(0, 30)
    tau[k] <- 1 / pow(sigma[k], 2)  # Precision for JAGS
  }

  # Priors for Bernoulli variables (ML and AF)
  for (j in 1:2) {
    alpha_ML[j] ~ dnorm(0, 0.04)
    alpha_AF[j] ~ dnorm(0, 0.04)
  }

  # Main model: likelihood for each observation
  for (i in 1:N) {
    # Mental load (ML) modeled as Bernoulli with logit link
    logit(p_ML[i]) <- alpha_ML[1] + alpha_ML[2] * phase[i]
    ML[i] ~ dbern(p_ML[i])

    # Active fatigue (AF) modeled as Bernoulli with logit link
    logit(p_AF[i]) <- alpha_AF[1] + alpha_AF[2] * phase[i]
    AF[i] ~ dbern(p_AF[i])

    # Continuous outcomes modeled as Normal
    # SDD
    mu1[i] <- beta1[1] + beta2[1]*sex[i] + beta3[1]*age[i] + beta4[1]*BMI[i] + beta6[1]*ML[i] + beta7[1]*AF[i]
    SDSD[i] ~ dnorm(mu1[i], tau[1])

    # MHR
    mu2[i] <- beta1[2] + beta2[2]*sex[i] + beta3[2]*age[i] + beta4[2]*BMI[i] + beta6[2]*ML[i] + beta7[2]*AF[i] + beta8[1]*SDSD[i]
    Mean_HR[i] ~ dnorm(mu2[i], tau[2])

    # RLH
    mu3[i] <- beta1[3] + beta2[3]*sex[i] + beta3[3]*age[i] + beta4[3]*BMI[i] + beta6[3]*ML[i] + beta7[3]*AF[i] + beta8[2]*SDSD[i] + beta9[1]*Mean_HR[i]
    LF_HF_ratio[i] ~ dnorm(mu3[i], tau[3])

    # SRT
    mu4[i] <- beta1[4] + beta2[4]*sex[i] + beta3[4]*age[i] + beta4[4]*BMI[i] + beta8[3]*SDSD[i] + beta9[2]*Mean_HR[i] + betaa10[1]*LF_HF_ratio[i]
    SDNN[i] ~ dnorm(mu4[i], tau[4])

    # MNB
    mu5[i] <- beta1[5] + beta2[5]*sex[i] + beta3[5]*age[i] + beta4[5]*BMI[i] + betaa11[1]*SDNN[i]
    Resp_rate[i] ~ dnorm(mu5[i], tau[5])
  }
}
"

# Prepare data for JAGS
data_jags <- list(
  N = nrow(data_MW),
  ML = data_MW$mental_load,
  AF = data_MW$active_fatigue,
  SDSD = data_MW$SDD,
  Mean_HR = data_MW$MHR,
  LF_HF_ratio = data_MW$RLH,
  SDNN = data_MW$SRT,
  Resp_rate = data_MW$MNB,
  sex = data_MW$sex,
  age = data_MW$age,
  BMI = data_MW$BMI,
  phase = data_MW$phase
)

# Initialize the JAGS model with 4 chains
model <- jags.model(textConnection(model_def), data = data_jags, n.chains = 4)

# Burn-in
update(model, 2000)

# Draw posterior samples for parameters
samples <- coda.samples(
  model,
  variable.names = c("beta1", "beta2", "beta3", "beta4", "beta6", "beta7", "beta8", "beta9", "betaa10", "betaa11", "alpha_ML", "alpha_AF", "sigma"),
  n.iter = 20000
)

# Summarize posterior distributions of parameters
summary(samples)
