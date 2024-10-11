module AnalyseLightcurve

using CairoMakie

#
## Constants
#

# Get the directory holding this script
const SCRIPT_DIR = dirname(abspath(@__FILE__))
# Get the JuliaWorkshop Path
const BASE_DIR = abspath(joinpath(SCRIPT_DIR, "../../../../"))
# Get the directory of the data
const DATA_DIR = joinpath(BASE_DIR, "Data")
# Get the data file
const DATA_FILE = joinpath(DATA_DIR, "data.csv")
# Define the output file
const OUTPUT_FILE = joinpath(SCRIPT_DIR, "output_jl.txt")
# Define the plot file
const PLOT_FILE = joinpath(SCRIPT_DIR, "Supernova Lightcurve")

"""
get_data()

    Read data from DATA_FILE into a dictionary
"""
function get_data()
    # Read file lines into an array
    raw_data = open(DATA_FILE, "r") do io
        return readlines(io)
    end

    # Headers are the first line
    headers = split(raw_data[1], ",")

    # Initialise data dictionary
    data = Dict(header => [] for header in headers)

    # Go row-by-row to read in data
    for row in raw_data[2:end]
        values = split(row, ",")
        for (col, header) in enumerate(headers)
            value = values[col]
            push!(data[header], value)
        end
    end

    return data
end

"""
analyse_data(data)

    Peform some simple data analysis, and write the result to a file
"""
function analyse_data(data)
    output = []

    # Get headers
    headers = collect(keys(data))
    push!(output, "Data has Headers: $headers")

    # Get number of elements
    num_elems = length(data[headers[1]])
    push!(output, "Data has $num_elems elements")

    output = join(output, "\n")
    open(OUTPUT_FILE, "w") do io
        write(io, output)
    end
end

"""
plot_data(data)

    Create a lightcurve plot of the data
"""
function plot_data(data)
    raw_bands = data["band"]
    raw_times = parse.(Float64, data["time"])
    raw_fluxes = parse.(Float64, data["flux"])
    raw_flux_errors = parse.(Float64, data["e_flux"])

    # Order of magnitude of the data
    oom = floor(log10(maximum(raw_fluxes)))

    bands = Set(raw_bands)
    masks = Dict(band => raw_bands .== band for band in bands)
    times = Dict(band => raw_times[masks[band]] for band in bands)
    fluxes = Dict(band => raw_fluxes[masks[band]] for band in bands)
    flux_errors = Dict(band => raw_flux_errors[masks[band]] for band in bands)

    f = Figure()
    ax = Axis(
        f[1, 1],
        xlabel="Time",
        ylabel="Flux",
        title="Supernova Lightcurves",
        yticks=MultiplesTicks(5, 10^oom, "e$oom"; strip_zero=true),
    )

    for band in bands
        time = times[band]
        flux = fluxes[band]
        flux_error = flux_errors[band]

        scatter_plot = scatter!(ax, time, flux, label=band)
        errorbars_plot = errorbars!(ax, time, flux, flux_error)

        # Special case for `K` band to make it less visible
        if band == "K"
            # Move to bottom of figure
            translate!(scatter_plot, 0, 0, -10)
            translate!(errorbars_plot, 0, 0, -10)
            # Shrink marker size
            scatter_plot.markersize = 0.5 * scatter_plot.markersize[]
            # Make colour transparent
            scatter_plot.color = (scatter_plot.color[], 0.5)
            # Shrink errorbar size
            errorbars_plot.linewidth = 0.5 * errorbars_plot.linewidth[]
            # Make colour transparent
            errorbars_plot.color = (errorbars_plot.color[], 0.5)
        end
    end

    Legend(f[1, 2], ax, "Bands")
    save("$PLOT_FILE.svg", f)
    save("$PLOT_FILE.png", f)
end

function main()
    @time begin
        data = get_data()
        analyse_data(data)
        plot_data(data)
    end
end

function (@main)(ARGS)
    main()
end

end # module AnalyseLightcurve

