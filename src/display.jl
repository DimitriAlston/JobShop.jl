"""
$(TYPEDSIGNATURES)

Displays the statistics for each iteration.
"""
function display_iteration(j::JobShopProblem, i::Int)
    @unpack maxest, estimate, penalty, current_iteration, time_start, time_solve_subprob, 
            time_solve_stepsize, current_norm, current_step = j.status
    total_time = time() - time_start
    qual = (estimate - current_lower_bound(j)) / estimate*100
    if j.parameter.verbosity > 0
        if current_iteration == 1
            println("--------------------------------------------------------------------------------------------------------------------------------")
            println("|  Iteration #  |    Group #    |  Lower Bound  |  Upper Bound  |      Gap      |     Qual.     |     Timer     |     Norm     |")
            println("--------------------------------------------------------------------------------------------------------------------------------")
        end
        # Print start
        print_str = "| "

        # Print iteration number
        max_len = 13
        temp_str = string(current_iteration)
        len_str = length(temp_str)
        print_str *= (" "^(max_len - len_str))*temp_str*" | "

        # Print subproblem number
        max_len = 13
        temp_str = string(i)
        len_str = length(temp_str)
        print_str *= (" "^(max_len - len_str))*temp_str*" | "

        # Print lower bound
        max_len = 13
        temp_str = @sprintf "%.3E" current_lower_bound(j)
        len_str = length(temp_str)
        print_str *= (" "^(max_len - len_str))*temp_str*" | "

        # Print upper bound
        max_len = 13
        temp_str = @sprintf "%.3E" current_upper_bound(j)
        len_str = length(temp_str)
        print_str *= (" "^(max_len - len_str))*temp_str*" | "

        # Print absolute gap between lower and upper bound
        max_len = 13
        temp_str = @sprintf "%.3E" current_abs_gap(j)
        len_str = length(temp_str)
        print_str *= (" "^(max_len - len_str))*temp_str*" | "

        # Print qual
        max_len = 13
        temp_str = @sprintf "%.3E" qual
        len_str = length(temp_str)
        print_str *= (" "^(max_len - len_str))*temp_str*" | "

        # Print run time
        max_len = 13
        temp_str = @sprintf "%.2F" total_time
        len_str = length(temp_str)
        print_str *= (" "^(max_len - len_str))*temp_str*" | "

        # Print norm
        max_len = 12
        temp_str = @sprintf "%.3E" current_norm
        len_str = length(temp_str)
        print_str *= (" "^(max_len - len_str))*temp_str*" |"

        println(print_str)

        # outstring = @sprintf("Iteration:  %4i, (S):  %4i  ", current_iteration, i)
        # outstring *= @sprintf("SDV:  %.3e  FC:  %.3e  ", current_lower_bound(j), current_upper_bound(j))
        # outstring *= @sprintf("GAP:  %.3e  Qual.:  %.3e  ", current_abs_gap(j), qual)
        # outstring *= @sprintf("Total Time:  %.1f  %.1f  %.1f ", total_time, time_solve_subprob, time_solve_stepsize)
        # outstring *= @sprintf("Norm:  %.3e  %.3e  %.3e  %.3e  %.3e	", current_norm, maxest, estimate, current_step, penalty)
        # println(outstring)
    end
end