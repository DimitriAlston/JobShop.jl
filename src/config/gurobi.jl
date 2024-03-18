
const GUROBI_SEED = 12
function gurobi_config!(m::Model)
    set_optimizer_attribute(m, "OutputFlag", 0)
    set_optimizer_attribute(m, "Seed", GUROBI_SEED)
    set_optimizer_attribute(m, "Threads", Threads.nthreads())
    return nothing
end

"""
$(TYPEDSIGNATURES)

Set parameters used by Gurobi when solving subproblems.
"""
function configure!(::Subproblem, v::Val{:Gurobi}, j::JobShopProblem, m::Model)
    gurobi_config!(m)
    if current_iteration(j) == 1
        set_time_limit_sec(m, 60)
        set_optimizer_attribute(m, "MIPGap", 0.1)
        if j.parameter.verbosity > 0
            println("Set parameter Seed to value $GUROBI_SEED")
            println("Set parameter Threads to value $(Threads.nthreads())")
            println("Set parameter TimeLimit to value 60")
            println("Set parameter MIPGap to value 0.1")
        end
    elseif current_iteration(j) == 30
        set_optimizer_attribute(m, "SolutionLimit", 3)
        set_optimizer_attribute(m, "Cutoff", 0.0001)
        if j.parameter.verbosity > 0
            println("Set parameter SolutionLimit to value 3")
            println("Set parameter Cutoff to value 0.0001")
        end
    elseif current_iteration(j) == 41
        set_time_limit_sec(m, 120)
        if j.parameter.verbosity > 0
            println("Set parameter TimeLimit to value 120")
        end
    end
    return
end

"""
$(TYPEDSIGNATURES)

Set parameters used by Gurobi when solving the feasibility problem.
"""
function configure!(::FeasibilityProblem, v::Val{:Gurobi}, j::JobShopProblem, m::Model)
    gurobi_config!(m)
    set_time_limit_sec(m, 60)
    set_optimizer_attribute(m, "Cutoff", current_upper_bound(j))
    set_optimizer_attribute(m, "MIPGap", 0.1)
    if j.parameter.verbosity > 0
        println("Set parameter TimeLimit to value 60")
        println("Set parameter Cutoff to value $(current_upper_bound(j))")
        println("Set parameter MIPGap to value 0.1")
    end
    return
end

configure!(::StepsizeProblem, v::Val{:Gurobi}, j::JobShopProblem, m::Model) = nothing