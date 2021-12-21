

"""
$TYPEDSIGNATURES

Creates subproblem used to determine step-size
"""
function create_problem(t::StepsizeProblem, jsp::JobShopProblem)
    @unpack λp, step_size =  jsp
    @unpack feasible_lambda_max, feasible_window, feasible_interval = jsp.parameter
    model = Model()
    @variable(model, 0 <= λ[m ∈ M, t ∈ T] <= feasible_lambda_max)
    ml = size(λp,3)
    mli(i) = ml - feasible_interval*i
    for k in [mli(i) for i = 1:feasible_window if 0 < mli(i) < ml - feasible_interval]
        kn = k + feasible_interval
        c = (1 - 4*step_size)^feasible_interval
        @constraint(model, [m ∈ M, t ∈ T], c*(λ[m, T] - λp[m, T, k])^2 >= (λ[m, T] - λp[m, T, kn])^2)
    end
    return model
end
check_feasible_lambda(k, s) = iszero(mod(k, s))
check_feasible_lambda(d::JobShopProblem) = check_feasible_lambda(d.status.currrent_iteration, d.parameter.feasible_interval)