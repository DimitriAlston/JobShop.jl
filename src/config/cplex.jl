
"""
    configure!(::Subproblem, v::Val{:CPLEX}, j::JobShopProblem, m::Model)

Set parameters used by CPLEX when solving subproblems.
"""
function configure!(::Subproblem, v::Val{:CPLEX}, j::JobShopProblem, m::Model)
    if current_iteration(j) == 1
        set_optimizer_attribute(m, "CPX_PARAM_RANDOMSEED", j.parameter.random_seed)
        set_optimizer_attribute(m, "CPX_PARAM_THREADS", Threads.nthreads())
        set_optimizer_attribute(m, "CPX_PARAM_REPAIRTRIES", 200000)
        set_optimizer_attribute(m, "CPX_PARAM_RINSHEUR", 200000)
        set_optimizer_attribute(m, "CPX_PARAM_HEURFREQ", 200000)
        set_time_limit_sec(m, 30)
        set_optimizer_attribute(m, "CPX_PARAM_EPGAP", 0.1)
        if j.parameter.verbosity > 0
            println("Set parameter RandomSeed to value $(j.parameter.random_seed)")
            println("Set parameter Threads to value $(Threads.nthreads())")
            println("Set parameter RepairTries to value 200000")
            println("Set parameter RINSHeur to value 200000")
            println("Set parameter HeurFreq to value 200000")
            println("Set parameter TimeLimit to value 30")
            println("Set parameter EpGap to value 0.1")
        end
    elseif current_iteration(j) == 30
        set_optimizer_attribute(m, "CPX_PARAM_INTSOLLIM", 5)
        set_optimizer_attribute(m, "CPX_PARAM_CUTUP", 0.0001)
        if j.parameter.verbosity > 0
            println("Set parameter IntSolLim to value 5")
            println("Set parameter CutUp to value 0.0001")
        end
    end
    # elseif current_iteration(j) == 41
    #    set_time_limit_sec(m, 30)
    #    println("Set parameter TimeLimit to value 30")
    # end
    return nothing
end

"""
    configure!(::FeasibilityProblem, v::Val{:CPLEX}, j::JobShopProblem, m::Model)

Set parameters used by CPLEX when solving the feasibility problem.
"""
function configure!(::FeasibilityProblem, v::Val{:CPLEX}, j::JobShopProblem, m::Model)
    set_optimizer_attribute(m, "CPX_PARAM_RANDOMSEED", j.parameter.random_seed)
    set_optimizer_attribute(m, "CPX_PARAM_THREADS", Threads.nthreads())
    set_optimizer_attribute(m, "CPX_PARAM_CUTUP", current_upper_bound(j))
    set_optimizer_attribute(m, "CPX_PARAM_EPGAP", 0.1)
    set_optimizer_attribute(m, "CPX_PARAM_REPAIRTRIES", 1000000)
    set_optimizer_attribute(m, "CPX_PARAM_RINSHEUR", 1000000)
    set_optimizer_attribute(m, "CPX_PARAM_HEURFREQ", 1000000)
    if j.parameter.verbosity > 0
        println("Set parameter RandomSeed to value $(j.parameter.random_seed)")
        println("Set parameter Threads to value $(Threads.nthreads())")
        println("Set parameter CutUp to value $(current_upper_bound(j))")
        println("Set parameter EpGap to value 0.1")
        println("Set parameter RepairTries to value 1000000")
        println("Set parameter RINSHeur to value 1000000")
        println("Set parameter HeurFreq to value 1000000")
    end
    return nothing
end

configure!(::StepsizeProblem, v::Val{:CPLEX}, j::JobShopProblem, m::Model) = nothing