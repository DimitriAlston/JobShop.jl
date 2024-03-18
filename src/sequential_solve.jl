
"""
$(TYPEDSIGNATURES)

Checks termination of the main algorithm.
"""
function terminated(j::JobShopProblem)
    if j.status.current_iteration > j.parameter.iteration_limit
        println("Terminated as current_iteration $(j.status.current_iteration) > iteration limit $(j.parameter.iteration_limit).")
        return true
    elseif j.status.feasible_problem_found
        println("Feasible problem found.")
        return true
    end
    return false
end

function stepsize_condition(jsp::JobShopProblem)
    @unpack current_iteration = jsp.status
    iszero(mod(current_iteration, jsp.parameter.stepsize_interval)) && (current_iteration > 37)
end

"""
$(TYPEDSIGNATURES)

Update the stepsize.
"""
function update_stepsize!(jsp::JobShopProblem)
    @unpack prior_norm, current_norm, prior_step, current_iteration, estimate = jsp.status
    if jsp.parameter.use_stepsize_program && stepsize_condition(jsp)
        solve_problem(StepsizeProblem(), jsp)
    end
    if jsp.parameter.use_stepsize_program
        if (current_iteration > 20) && (current_norm > 0.0)
            MM = 50
            r = 0.05
            coeff = 1 - 1/MM/current_iteration^(1 - 1/current_iteration^r)
            term = prior_step*sqrt(prior_norm/current_norm)
            if term > 0.0
                jsp.status.current_step = coeff*term
            end
        end
    else
        LB = current_lower_bound(jsp)
        if (estimate < 100000) && (estimate - LB > 0) && (current_norm > 0.0)
            jsp.status.current_step = jsp.parameter.alpha_step/5*(estimate - LB)/current_norm
        end
    end
    return nothing
end

function update_multiplier!(jsp::JobShopProblem)
    @unpack mult, sslackk, MachineType, T = jsp
    @unpack current_step = jsp.status
    for mi in MachineType, t in T
        jsp.mult[mi,t] = max(mult[mi,t] + current_step*sslackk[mi,t], 0.0)
    end
    return nothing
end

function update_penalty!(jsp::JobShopProblem)
    @unpack penalty_iteration, penalty_factor = jsp.parameter
    if jsp.status.current_iteration > 50
        if mod(jsp.status.current_iteration - 1, penalty_iteration) == 0
            jsp.status.penalty *= penalty_factor
        end
    end
    return nothing
end

function sequential_solve!(jsp::JobShopProblem)
    initialize!(jsp)
    k = 0
    while !terminated(jsp)
        valid_subproblem = solve_subproblem(jsp, jsp.Ii[k + 1], k + 1)
        if valid_subproblem
            update_stepsize!(jsp)
            update_multiplier!(jsp)
            update_penalty!(jsp)
            if use_problem(FeasibilityProblem(), jsp)
                solve_problem(FeasibilityProblem(), jsp)
            end
            jsp.status.prior_norm = jsp.status.current_norm
            jsp.status.prior_step = jsp.status.current_step
            display_iteration(jsp, k + 1)
            k = mod(k + 1, length(jsp.Ii))
            jsp.status.current_iteration += 1
        else
            error("Invalid Subproblem")
        end
    end
    df = DataFrame(part=Int[], op=Int[], start=Int[])
    sdf = DataFrame(part=Int[], op=Int[], start=Int[])
    for i in jsp.I, j in jsp.Jop[i]
        push!(df, (i, j, round(Int, jsp.feasible_bTime1[i,j])))
        push!(sdf, (i, j, round(Int, jsp.sbTime1[i,j])))
    end
    return df, sdf
end
