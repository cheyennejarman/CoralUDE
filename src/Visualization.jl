module Visualization

using UniversalDiffEq, Plots

export phase_plane_plot

function phase_plane_plot(model;
    start = 0.05,
    stop = 1.0,
    step = 0.1,
    max_T = 250,
    xlabel = "Macroalgae Cover",
    ylabel = "Coral Cover"
)

    u0_array = Vector{Vector{Float64}}()

    for macroalgae in start:step:stop
        for coral in start:step:stop
            coral + macroalgae > 1 && continue
            push!(u0_array, [coral, macroalgae])
        end
    end

    plt = UniversalDiffEq.phase_plane(
        model,
        u0_array,
        T = max_T,
        idx = [2, 1]
    )

    Plots.xlabel!(plt, xlabel)
    Plots.ylabel!(plt, ylabel)

    return plt
end

end