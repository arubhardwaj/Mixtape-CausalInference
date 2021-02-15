using DataFrames,Distributions

function sort_sdo(d::DataFrame)
    sort!(d,[:r])
    return d
end

function add_d(df::DataFrame)
    df.d = [ones(5)...,zeros(5)...]
    return df
end

function add_y(df::DataFrame)
    df.y = df.d .* df.y1 + (1 .- df.d) .* df.y0
    return df
end

function pull_y(df::DataFrame)
    return df.y
end

function gap()

    sdo = DataFrame(y1 = [7,5,5,7,4,10,1,5,3,9],y0 = [1,6,1,8,2,1,10,6,7,8],r = rand(Normal(),10)) |> sort_sdo |> add_d |> add_y |> pull_y
    sdo = mean(sdo[1:5] .- sdo[6:10])
    return sdo
end

sim = [gap() for _ in 1:10_000] |> mean


















