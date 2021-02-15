#=
The hypothesis, properly stated, is that, given a cup of tea with milk, a woman can discern whether milk or tea was first added to the cup. To test her claim, eight cups of tea were prepared; in four the milk was added first, and in four the tea was added first. How many cups does she have to correctly identify to convince us of her uncanny ability?
=#

using StatsBase,Plots

function choose_tea()
    teas = [ones(4)...,zeros(4)...] # 1 => milk first, 0 => tea first 
    choice = sample(1:8,4,replace = false)
    teas_chosen = getindex(teas,choice)
    return teas_chosen
end

function simulate(N)
    milk_first = 0
    tea_first = 0
    for _ in 1:N
        a = choose_tea()
        #println(a)
        if all(a .== 1)
            milk_first += 1
        else
            tea_first += 1
        end
    end
    return milk_first/N,tea_first/N
end


sim = simulate(100_000)

bar(["milk first","tea first"],[sim[1],sim[2]],bar_width = 0.3,color = [:green,:red],label = false,ylabel = "probability")

