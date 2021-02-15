### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ dbce8820-6d57-11eb-07b3-197703b56513
using StatFiles,DataFrames,GLM,Distributions,Plots,Random,Statistics,KernelDensity

# ╔═╡ cc07b960-6d58-11eb-3e6f-1362a4e4054f
md"Yule"

# ╔═╡ aa5949a0-6d58-11eb-0efb-1d971d643df0
begin
	df = DataFrame(load("E:\\Causal_Inference\\Chapter4\\yule.dta"))
	
	linearfit = lm(@formula(paup ~ outrelief + old + pop),df)
end

# ╔═╡ 38746080-6d59-11eb-0659-4d9a3b179467
md"independence"

# ╔═╡ 07d48fe0-6d59-11eb-38af-2ddd3d773388
begin
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

	sim_independence = [gap() for _ in 1:10_000] |> mean
end

# ╔═╡ 705b2330-6d59-11eb-16c0-43b7be44bac9
md"tea"

# ╔═╡ 70450320-6d59-11eb-3ccb-117099a77fe2
begin
	function choose_tea()
		teas = [ones(4)...,zeros(4)...] # 1 => milk first, 0 => tea first 
		choice = sample(1:8,4,replace = false)
		teas_chosen = getindex(teas,choice)
		return teas_chosen
	end

	function simulate_tea(N)
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


	sim_tea = simulate_tea(100_000)

	bar(["milk first","tea first"],[sim_tea[1],sim_tea[2]],bar_width = 0.3,color = [:green,:red],label = false,ylabel = "probability")


end

# ╔═╡ 702c9920-6d59-11eb-2787-275fbd2baa2f
md"ri"

# ╔═╡ 70142f22-6d59-11eb-08db-f1415344518e
begin
	function make_sharp_null()
		df = DataFrame(load("E:\\Causal_Inference\\Chapter4\\ri.dta"))
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

	df_ri = make_sharp_null()

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
		return [test_statistic(randomize(df_ri)) for _ in 1:N]
	end

	sim_ri = simulate(10)
end

# ╔═╡ d27ca380-6d5a-11eb-3cd3-89a9f705a4a6
md"Kolmogorov-Smirnov test"

# ╔═╡ 65ec47c0-6d5a-11eb-2bab-89398d8beb13
begin
	tb = DataFrame(d = [zeros(20)...,ones(20)...],y = [0.22, -0.87, -2.39, -1.79, 0.37, -1.54,1.28, -0.31, -0.74, 1.72,0.38, -0.17, -0.62, -1.10, 0.30,0.15, 2.30, 0.19, -0.50, -0.9,-5.13, -2.19, 2.43, -3.83, 0.5,-3.25, 4.32, 1.63, 5.18, -0.43,7.11, 4.87, -3.10, -5.81, 3.76,6.31, 2.58, 0.07, 5.76, 3.50])

	kdensity_d1 = filter(x -> x.d == 1,tb).y |> kde
	kdensity_d0 = filter(x -> x.d == 0,tb).y |> kde

	kdensity_d0 = DataFrame(x = kdensity_d0.x,y = kdensity_d0.density)
	kdensity_d1 = DataFrame(x = kdensity_d1.x,y = kdensity_d1.density)

	# the book has only a part of control.
	plot(kdensity_d0.x[400:1600],kdensity_d0.y[400:1600],label = "control",linestyle = :dash,linecolor = :blue,xlabel = "x",ylabel = "kdensity",legend = :outerbottom,title = "Kolmogorov-Smirnov test")
	# plot(kdensity_d0.x,kdensity_d0.y,label = "control",linestyle = :dash,linecolor = :blue,xlabel = "x",ylabel = "kdensity") for full plot use this
	plot!(kdensity_d1.x,kdensity_d1.y,label = "treatment",linecolor = :black)
end

# ╔═╡ 65d27e30-6d5a-11eb-33d2-ade31cefc55f
md"thronton_ri"

# ╔═╡ 65bbc1e0-6d5a-11eb-39cb-0755276d3920
begin
	df_thronton = DataFrame(load("E:\\Causal_Inference\\Chapter4\\thornton_hiv.dta"))

	function permuteHIV(a::DataFrame,random::Bool)
		first_half = ceil(length(a.tb)/2)
		second_half = length(a.tb) - first_half

		if random
			a = a[shuffle(axes(a, 1)), :]
			a.any = [ones(Int64(first_half))...,zeros(Int64(second_half))...]
		end
		te1 = mean(skipmissing(filter(x -> x[:any] == 1,dropmissing(a,:any)).got))
		te0 = mean(skipmissing(filter(x -> x[:any] == 0,dropmissing(a,:any)).got))

		ate = te1 - te0

		return ate
	end

	iterations = 1000
	permutation = DataFrame(iteration = 1:iterations,ate = [permuteHIV(df_thronton,false),[permuteHIV(df_thronton,true) for _ in 2:iterations]...])

	permutation = sort(permutation,[:ate],rev = true)
	permutation.rank = 1:iterations
	P_value = filter(x -> x.iteration == 1,permutation).rank/iterations
end

# ╔═╡ Cell order:
# ╠═dbce8820-6d57-11eb-07b3-197703b56513
# ╟─cc07b960-6d58-11eb-3e6f-1362a4e4054f
# ╠═aa5949a0-6d58-11eb-0efb-1d971d643df0
# ╟─38746080-6d59-11eb-0659-4d9a3b179467
# ╠═07d48fe0-6d59-11eb-38af-2ddd3d773388
# ╟─705b2330-6d59-11eb-16c0-43b7be44bac9
# ╠═70450320-6d59-11eb-3ccb-117099a77fe2
# ╟─702c9920-6d59-11eb-2787-275fbd2baa2f
# ╠═70142f22-6d59-11eb-08db-f1415344518e
# ╟─d27ca380-6d5a-11eb-3cd3-89a9f705a4a6
# ╠═65ec47c0-6d5a-11eb-2bab-89398d8beb13
# ╟─65d27e30-6d5a-11eb-33d2-ade31cefc55f
# ╠═65bbc1e0-6d5a-11eb-39cb-0755276d3920
