module Training

using UniversalDiffEq

export train_model!

function train_model!(model)
    train!(model;
        loss_function = "derivative matching",
        loss_options = (d = 2,),
        optimizer = "ADAM",
        regularization_weight = 1e-4,
        verbose = true,
        optim_options = (maxiter = 100, step_size = 0.01)
    )
    return model
end

end