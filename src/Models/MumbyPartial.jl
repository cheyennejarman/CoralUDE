module MumbyPartial

using UniversalDiffEq

export build_model

function build_model(df_model)

    NN, params = UniversalDiffEq.SimpleNeuralNetwork(2, 1)

    init_parameters = (
        NN = params,
        r1 = 0.8,
        r2 = 0.3,
        r3 = 0.1,
        r4 = 0.5
    )

    function dudt(u, p, t)
        r = exp.(NN(u, p.NN))   # positive rates
        Coral, MacroAlg = u
        Turf = 1 - Coral - MacroAlg

        dC = p.r1*Coral*Turf - p.r2*Coral - p.r3*Coral*MacroAlg
        dM = p.r3*Coral*MacroAlg + p.r4*MacroAlg*Turf - r[1]*MacroAlg

        return [dC, dM]
    end

    model = CustomDerivatives(df_model, dudt, init_parameters)
    return model
end

end