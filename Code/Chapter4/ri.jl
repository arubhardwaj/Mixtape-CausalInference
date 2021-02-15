using StatFiles,DataFrames

function make_sharp_null()
    df = DataFrame(load("data\\Chapter4\\ri.dta"))
    y0 = df.y0
    y1 = df.y1

    for i in 1:length(y0)
        if i <= 4
            y0[i] = y1[i]
        else
            y1[i] = y0[i]
        end
    end
    df.y0 = y0
    df.y1 = y1
    return df
end

df = make_sharp_null()

function randomize(df::DataFrame)
    df.d = shuffle(df.d)
    return df
end

function test_statistic(df::DataFrame)
    treatment = filter(x -> x.d == 1,df).y
    control = filter(x -> x.d == 0,df).y
    return abs(mean(treatment) - mean(control))
end


function simulate(N)
    return [test_statistic(randomize(df)) for _ in 1:N]
end

sim = simulate(10)




