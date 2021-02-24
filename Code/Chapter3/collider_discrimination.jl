using DataFrames, Distributions, GLM

n = 10000;

female = rand(Normal(), n) .> 0
ability = rand(Normal(), n)
discrimination = female

occupation = 1 .+ 2 .* ability + 0 .* female - 2 .* discrimination + rand(Normal(), n)
wage = 1 .- discrimination + occupation + 2 .* ability + rand(Normal(), n)

dat = DataFrame(female = female,ability = ability,discrimination = discrimination, occupation = occupation, wage = wage)



lm1 = lm(@formula(wage ~ female), dat)
lm2 = lm(@formula(wage ~ female + occupation), dat)
lm3 = lm(@formula(wage ~ female + occupation + ability), dat)