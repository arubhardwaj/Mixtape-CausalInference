using StatFiles,DataFrames,GLM,Econometrics,FixedEffectModels

judge = load("data\\Chapter7\\judge_fe.dta") |> DataFrame

for E in names(judge)
    judge[!,E] = convert.(Float64,judge[!,E])
end

min_formula = @formula(guilt ~ jail3 + day + day2 + bailDate + t1 + t2 + t3 + t4 + t5)
max_formula = @formula(guilt ~ jail3 + possess + robbery + DUI1st + drugSell + aggAss + black + age + male + white + priorCases + priorWI5 + prior_felChar + prior_guilt + onePrior + threePriors + fel + mis + sum + F1 + F2 + F3 + M1 + M2 + M3 + M + day + day2 + bailDate + t1 + t2 + t3 + t4 + t5)

# OLS
min_ols = lm(min_formula,judge)
max_ols = lm(max_formula,judge)

# 2sls
# control2 = day + day2 + bailDate + t1 + t2 + t3 + t4 + t5
min_2sls = @formula(guilt ~ day + day2 + bailDate + t1 + t2 + t3 + t4 + t5 ~ (0 ~ (jail3 ~ 0 +  judge_pre_1 + judge_pre_2 + judge_pre_3 + judge_pre_4 + judge_pre_5 + judge_pre_6 + judge_pre_7)))

max_2sls = @formula(guilt ~ black + age + male + white + possess + priorCases + priorWI5 + prior_felChar + prior_guilt + onePrior + threePriors + robbery + fel + mis + sum + F1 + F2 + F3 + M1 + M2 + M3 + M + DUI1st + day + day2 + bailDate + t1 + t2 + t3 + t4 + t5 + drugSell + aggAss ~ (0 ~ (jail3 ~ 0 + judge_pre_1 + judge_pre_2 + judge_pre_3 + judge_pre_4 + judge_pre_5 + judge_pre_6 + judge_pre_7)))

min_2sls = reg(judge,min_2sls)
