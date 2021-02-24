using DataFrames, Distributions, GLM

n = 10000;

female = rand(Normal(), n) .> 0
ability = rand(Normal(), n)