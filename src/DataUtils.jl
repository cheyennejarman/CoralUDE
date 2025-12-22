# Loading up focal data 

module DataUtils

using CSV, DataFrames

export load_training_data

function load_training_data(filepath::String)
    df = CSV.read(filepath, DataFrame)

    df_model = df[:, ["Time", "Coral", "Macro"]]
    times = df.Time
    observations = Array(df[:, ["Coral", "Macro"]])'

    return df, df_model, times, observations
end

end