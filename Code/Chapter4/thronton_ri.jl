using StatFiles,DataFrames,Random,Statistics

df = DataFrame(load("data\\Chapter4\\thornton_hiv.dta"))

function permuteHIV(a::DataFrame,random::Bool)
    first_half = ceil(length(a.tb)/2)
    second_half = length(a.tb) - first_half
    
    if random
        a = a[shuffle(axes(df, 1)), :]
        a.any = [ones(Int64(first_half))...,zeros(Int64(second_half))...]
    end
    te1 = mean(skipmissing(filter(x -> x[:any] == 1,dropmissing(a,:any)).got))
    te0 = mean(skipmissing(filter(x -> x[:any] == 0,dropmissing(a,:any)).got))

    ate = te1 - te0
    
    return ate
end

iterations = 1000
permutation = DataFrame(iteration = 1:iterations,ate = [permuteHIV(df,false),[permuteHIV(df,true) for _ in 1:(N -1 )]...])

permutation = sort(permutation, [:ate],rev = true)
permutation.rank = 1:N
P_value = filter(x -> x.iteration == 1,permutation).rank/N