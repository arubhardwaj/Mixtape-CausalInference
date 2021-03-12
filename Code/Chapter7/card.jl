using StatFiles,DataFrames,GLM

card = load("data\\Chapter7\\card.dta") |> DataFrame
card.X .= [card.exper,card.black,card.south,card.married,card.smsa] |> transpose
ols_reg = lm(@formula(lwage ~ educ + ),card)
