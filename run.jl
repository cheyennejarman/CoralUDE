using Serialization, CSV, Plots

include("src/DataUtils.jl")
include("src/Models/MumbyFull.jl")
include("src/Training.jl")
include("src/Analysis.jl")
include("src/Visualization.jl")

using .DataUtils
using .MumbyFull
using .Training
using .Analysis
using .Visualization

# ===============================
# USER SPECIFICATION
# ===============================
data_file   = "data/Mumby_coralIC005_model_output_nonoise_g03.csv"
results_dir = "results/MumbyFull/experiment_001"
mkpath(results_dir)

# ===============================
# LOAD DATA
# ===============================
df, df_model, times, observations = load_training_data(data_file)

# ===============================
# BUILD & TRAIN MODEL
# ===============================
model = build_model(df_model)
train_model!(model)

# ===============================
# SAVE TRAINED MODEL
# ===============================
serialize(joinpath(results_dir, "trained_model.ser"), model)

# ===============================
# EQUILIBRIA & STABILITY
# ===============================
eq_df, eig_df = compute_equilibria(model)

CSV.write(joinpath(results_dir, "equilibria.csv"), eq_df)
CSV.write(joinpath(results_dir, "eigenvalues.csv"), eig_df)

# ===============================
# PHASE PLANE
# ===============================
plt = phase_plane_plot(model)
plot!(plt, df.Macro, df.Coral,
      color = :black,
      linewidth = 3,
      label = "Training trajectory")

colors = [
    s == "stable" ? :green : :red
    for s in eq_df.Stability
]

scatter!(
    plt,
    eq_df.Macro,
    eq_df.Coral,
    color = colors,
    markersize = 6,
    label = ""
)
scatter!([], [], color=:green, label="Stable", markersize=6)
scatter!([], [], color=:red, label="Unstable", markersize=6)

savefig(plt, joinpath(results_dir, "phase_plane.pdf"))