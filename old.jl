import Random
using Plots

println("Pool Testing Optimization\nMonte Carlo Simulation")

min_total = 1
max_total = 100
min_infected = 0
iterations = 100

function run(total, infected, n_groups)
	# Trivial cases
	# No one is infected or testing everybody
	if infected==0 || n_groups==total
		return n_groups
	# Only 1 group (there is only 1 grouping step)
	elseif n_groups==1
		return total+1
	end

	people = zeros(Bool, total)
	people[1:infected] .= true
	Random.shuffle!(people)

	n_per_group = total ÷ n_groups
	n_plus_groups = total % n_groups

	groups = zeros(UInt, n_groups)

	for i in 1:infected
		j = 1+(Random.rand(UInt) % n_groups)
		groups[j] += 1
	end

	infected_groups = count(g -> g>0, groups)

	tests = n_groups

	for (index, value) in enumerate(groups)
		if value>0
			if index<=n_plus_groups
				tests += n_per_group+1
			else
				tests += n_per_group
			end
		end
	end

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

n = binomial(max_total+2-min_infected, 2) - binomial(min_total+1-min_infected, 2)
results = Array{UInt, 2}(undef, n, 3)

i = 1
for total in min_total:max_total
	for infected in min_infected:total
		println("total ", total, "  infected ", infected)

		optimum_n_groups = total
		previous_sum_tests = iterations*total

		for n_groups in 1:total
			sum_tests = 0

			for iteration in 1:iterations
				tests = run(total, infected, n_groups)
				sum_tests += tests
				#println("total ", total, "  infected ", infected, "  n_groups ", n_groups, "  iteration ", iteration, "  tests ", tests)
			end

			if sum_tests<previous_sum_tests
				optimum_n_groups = n_groups
			end
		end

		global i
		results[i, :] = [total, infected, optimum_n_groups]
		i += 1
	end
end

println("Calculated")

matrix = zeros(Float32, (max_total+1-min_total, max_total+1-min_infected))
for k = 1:size(results, 1)
	local i = results[k, 1] + 1 - min_total
	local j = results[k, 2] + 1 - min_infected
	matrix[i, j] = results[k, 3]/results[k, 1]
end

#println("results ", results)
#println("matrix ", matrix)

heatmap(min_total:max_total, min_infected:max_total, matrix',
		xlabel="Total", ylabel="Infected",
		title="Optimal number of groups / Total",
		aspect_ratio=:equal,
		show=true)
println("Plotted")
readline()

println("End")
