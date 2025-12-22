module Analysis

using UniversalDiffEq, DataFrames

export compute_equilibria

function compute_equilibria(model;
    lower_bounds = [0.0, 0.0],
    upper_bounds = [1.0, 1.0],
    Ntrials = 1000
)

    eqbm, eigen = equilibrium_and_stability(
        model,
        lower_bounds,
        upper_bounds;
        Ntrials = Ntrials
    )

    stability = [
        all(real.(eig) .< 0) ? "stable" : "unstable"
        for eig in eigen
    ]

    eq_df = DataFrame(
        Coral = first.(eqbm),
        Macro = last.(eqbm),
        Stability = stability
    )

    eig_df = DataFrame(
        eigenvalues = eigen
    )

    return eq_df, eig_df
end

end