import Random
using Plots

println("Pool Testing Optimization\nMonte Carlo Simulation")

min_total = 1
total_step = 1
max_total = 100
prob_step = 0.01
iterations = 1000

function run(total, prob, n_groups)
	# Trivial cases
	# No one is infected or testing everybody
	if prob==0 || n_groups==total
		return n_groups
	# Only 1 group (there is only 1 grouping step)
	elseif n_groups==1
		return total+1
	end
	
	# Calculate infected from probability using stochastic rounding
	infected = prob*total
	if rand(Float32)<(infected-floor(infected))
		infected = Int(ceil(infected))
	else
		infected = Int(floor(infected))
	end
	
	# No one is infected
	if infected==0
		return n_groups
	end

	people = zeros(Bool, total)
	people[1:infected] .= true
	Random.shuffle!(people)

	n_per_group = total ÷ n_groups
	n_plus_groups = total % n_groups

	#groups = zeros(UInt, n_groups)
	groups = zeros(Bool, n_groups)

	for i in 1:infected
		j = 1+(Random.rand(UInt) % n_groups)
		#groups[j] += 1
		groups[j] = true
	end

	#infected_groups = count(g -> g>0, groups)
	#infected_groups = count(groups)

	tests = n_groups
	tests += count(groups[1:n_plus_groups]) * (n_per_group+1)
	tests += count(groups[n_plus_groups+1:end]) * n_per_group

	#=
	println("Total   \t", total)
	println("Infected\t", infected)
	println("People\t", people)
	println("People per group\t", n_per_group)
	println("# groups with 1 more\t", n_plus_groups)
	println("Infected per group\t", groups)
	println("Number of infected groups\t", infected_groups)
	println("Number of tests\t", tests)
	=#

	return tests
end

n_total = Int(floor((max_total-min_total)/total_step)+1)
n_prob = Int(floor(1/prob_step))+1 
results = Array{Float32, 2}(undef, n_total*n_prob, 3)

i = 1
for total in min_total:total_step:max_total
	for prob in 0:prob_step:1
		println("total ", total, "  probability ", prob)

		optimum_n_groups = total
		previous_sum_tests = iterations*total

		for n_groups in 1:total
			sum_tests = 0

			for iteration in 1:iterations
				tests = run(total, prob, n_groups)
				sum_tests += tests
				#println("total ", total, "  prob ", prob, "  n_groups ", n_groups, "  iteration ", iteration, "  tests ", tests)
			end

			if sum_tests<previous_sum_tests
				optimum_n_groups = n_groups
			end
		end

		global i
		results[i, :] = [total, prob, optimum_n_groups]
		i += 1
	end
end

println("Calculated")

matrix = results[:, 3]./results[:, 1]
matrix = reshape(matrix, n_prob, n_total)'

#println("results ", results, '\n')
#println("matrix ", matrix, '\n')

heatmap(min_total:total_step:max_total, 0:prob_step:1, matrix',
		xlabel="Total", ylabel="% Infected",
		title="Optimal number of groups / Total",
		show=true)
println("Plotted")
savefig("./result.png")
println("Saved")

#=
gui()
scatter(results[:, 2], results[:, 3]./results[:, 1], show=true)
x = prob_step:prob_step:1
y = x.^(-0.5)
plot!(x, y)
=#

readline()

println("End")
