using Plots,DataFrames,KernelDensity
tb = DataFrame(d = [zeros(20)...,ones(20)...],y = [0.22, -0.87, -2.39, -1.79, 0.37, -1.54,1.28, -0.31, -0.74, 1.72,0.38, -0.17, -0.62, -1.10, 0.30,0.15, 2.30, 0.19, -0.50, -0.9,-5.13, -2.19, 2.43, -3.83, 0.5,-3.25, 4.32, 1.63, 5.18, -0.43,7.11, 4.87, -3.10, -5.81, 3.76,6.31, 2.58, 0.07, 5.76, 3.50])

kdensity_d1 = filter(x -> x.d == 1,tb).y |> kde
kdensity_d0 = filter(x -> x.d == 0,tb).y |> kde

kdensity_d0 = DataFrame(x = kdensity_d0.x,y = kdensity_d0.density)
kdensity_d1 = DataFrame(x = kdensity_d1.x,y = kdensity_d1.density)

# the book has only a part of control.
plot(kdensity_d0.x[400:1600],kdensity_d0.y[400:1600],label = "control",linestyle = :dash,linecolor = :blue,xlabel = "x",ylabel = "kdensity",legend = :outerbottom)
# plot(kdensity_d0.x,kdensity_d0.y,label = "control",linestyle = :dash,linecolor = :blue,xlabel = "x",ylabel = "kdensity") for full plot use this
plot!(kdensity_d1.x,kdensity_d1.y,label = "treatment",linecolor = :black)