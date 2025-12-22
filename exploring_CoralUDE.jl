#using CoralUDE
#model, test_data = CoralUDE.ude_model()
#CoralUDE.state_estimates(model)

#model, test_data = CoralUDE.ude_model(σ1 = 2.5)
#CoralUDE.state_estimates(model)


using UniversalDiffEq, DataFrames, CSV, Plots, Serialization


# Read in data
df = CSV.read("data/Mumby_coral_dominant_model_output_noiseong.csv", DataFrame)

# Extract the columns you want as the state variables 
times = df.Time
observations = Array(df[:, ["Coral", "Macro"]])'

# Prepare data for model: DataFrame with all relevant columns
df_model = df[:, ["Time", "Coral", "Macro"]]

# Define neural network and model
#=NN, params = UniversalDiffEq.SimpleNeuralNetwork(2, 2)
init_parameters = (NN = params, )

# use nerual network for all rates 
function dudt(u, p, t)
    #r = NN(u, p.NN)
    r = exp.(NN(u,p.NN)) # bounding rates to positive values
	Coral,MacroAlg = u
    Turf = 1 - Coral - MacroAlg
    dC = r[1]*Coral*Turf - r[2]*Coral*MacroAlg
    dM = [2]*Coral*MacroAlg + r[3]*MacroAlg*Turf - r[4]*MacroAlg
    return [dC,dM]
end=#

# Estiamte some rates as constants
NN, params = UniversalDiffEq.SimpleNeuralNetwork(2, 1)
init_parameters = (NN = params, r1 = 0.8, r2 = 0.3, r3 = 0.1, r4 =0.5)
function dudt(u, p, t)
    #r = NN(u, p.NN)
    r = exp.(NN(u,p.NN)) # bounding rates to positive values
	Coral,MacroAlg = u
    Turf = 1 - Coral - MacroAlg
    dC = p.r1*Coral*Turf - p.r2*Coral - p.r3*Coral*MacroAlg
    #dM = p.r3*Coral*MacroAlg + p.r4*MacroAlg*Turf - ((r[1]*MacroAlg)/(MacroAlg+Turf))
    dM = p.r3*Coral*MacroAlg + p.r4*MacroAlg*Turf - r[1]*MacroAlg
    return [dC,dM]
end

# fixing r1
#=NN, params = UniversalDiffEq.SimpleNeuralNetwork(2, 1)
init_parameters = (NN = params, r2 = 0.1, r3 = 0.1)
function dudt(u, p, t)
    Coral, MacroAlg = u
    Turf = 1 - Coral - MacroAlg
    r1 = 10.0                          # fixed high value
    r2 = p.r2                          # still fixed from parameter struct
    r3 = p.r3                          # still fixed from parameter struct
    r_decay = exp(NN(u, p.NN)[1])      # you could still learn r_decay (formerly r[2])
    
    dC = r1 * Coral * Turf - r2 * Coral * MacroAlg
    dM = r2 * Coral * MacroAlg + r3 * MacroAlg * Turf - r_decay * MacroAlg
    return [dC, dM]
end=#

model = CustomDerivatives(df_model, dudt, init_parameters)

#=# Exploring fit for d value
train!(model; 
    loss_function = "derivative matching",
    loss_options = (d=2), 
    optimizer = "ADAM",
    regularization_weight = 1e-4,#0.0,
    verbose = true,
    optim_options = (maxiter = 1, step_size = 0.05)
)
plot_state_estimates(model)=#

train!(model; 
    loss_function = "derivative matching",
    loss_options = (d=2),  
    optimizer = "ADAM",
    regularization_weight = 1e-4,#0.0,
    verbose = true,
    optim_options = (maxiter = 1000, step_size = 0.001)
)

plot_state_estimates(model)


# visualize 2 variables (e.g., Coral vs Macro) by fixing the third variable (e.g., Turf) to be 1 - Coral - Macro
function phase_plane(model; start = 0.05, stop = 1.0, step = 0.1, max_T = 250, 
                     title = "Plot Title", xlabel = "Macroalgae Cover", ylabel = "Coral Cover")
    
    u0_array = Vector{Vector{Float64}}()
    for macro_ in start:step:stop
        for coral in start:step:stop
            if (coral + macro_ > 1)
                continue 
            end
            turf = 1.0 - coral - macro_
            #push!(u0_array, [coral, macro_, turf]) 
            push!(u0_array, [coral, macro_])
        end 
    end 

    plt = UniversalDiffEq.phase_plane(model, u0_array, T = max_T, idx = [2, 1])
    title!(plt, title)
    xlabel!(plt, xlabel)
    ylabel!(plt, ylabel)
    return plt 
end


plot = phase_plane(model;
    title = "Macro vs Coral Phase Plane",
    xlabel = "Macroalgae Cover",
    ylabel = "Coral Cover"
)
display(plot)
