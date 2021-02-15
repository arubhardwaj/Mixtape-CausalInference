using StatFiles,DataFrames,GLM

df = DataFrame(load("data\\Chapter4\\yule.dta"))

linearfit = lm(@formula(paup ~ outrelief + old + pop),df)








    