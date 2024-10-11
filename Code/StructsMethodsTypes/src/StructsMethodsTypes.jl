module StructsMethodsTypes


using CairoMakie
using Unitful

#
## Constants
#

# Get the directory holding this script
const SCRIPT_DIR = dirname(abspath(@__FILE__))
# Get the JuliaWorkshop Path
const BASE_DIR = abspath(joinpath(SCRIPT_DIR, "../../../"))
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

    data["time"] = parse.(Float64, data["time"])
    data["flux"] = parse.(Float64, data["flux"])
    data["e_flux"] = parse.(Float64, data["e_flux"])

    return data
end

"""
plot_data(data)

    Create a lightcurve plot of the data
"""
function plot_data(data::Dict; name)
    plot_data(data["band"], data["time"], data["flux"], data["e_flux"]; name)
end

function plot_data(raw_bands, raw_times, raw_fluxes, raw_flux_errors; name)
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
        title="Supernova Lightcurve - $name",
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
    save("$(PLOT_FILE)_$name.svg", f)
    save("$(PLOT_FILE)_$name.png", f)
end


#
# Defining an Abstract Lightcurve Type
#

abstract type AbstractLightcurve end

for attribute in (:bands, :times, :fluxes, :flux_errors)
    @eval $attribute(lc::AbstractLightcurve) = lc.$attribute
end

function plot_data(lightcurve::AbstractLightcurve; name)
    plot_data(
        bands(lightcurve),
        times(lightcurve),
        fluxes(lightcurve),
        flux_errors(lightcurve);
        name
    )
end

#
# Defining a Lightcurve Type
#

struct SNLightcurve <: AbstractLightcurve
    bands
    times
    fluxes
    flux_errors
end

function SNLightcurve(data::Dict)
    return SNLightcurve(data["band"], data["time"], data["flux"], data["e_flux"])
end

#
# Defining an Observation type
#

abstract type AbstractObservation end

struct SNObservation <: AbstractObservation
    band
    time
    flux
    flux_error
end

struct Observations <: AbstractLightcurve
    observations::Vector{AbstractObservation}
end

function Observations(data::Dict)
    bands = data["band"]
    times = data["time"]
    fluxes = data["flux"]
    flux_errors = data["e_flux"]
    observations = [SNObservation(bands[i], times[i], fluxes[i], flux_errors[i]) for i in eachindex(bands)]
    return Observations(observations)
end

for (attributes, attribute) in (
    (:bands, :band),
    (:times, :time),
    (:fluxes, :flux),
    (:flux_errors, :flux_error)
)
    @eval $attributes(lc::Observations) = [obs.$attribute for obs in lc.observations]
end
#
# Testing it out
#

export main
function main()
    data = get_data()
    plot_data(data; name="Data")
    snlightcurve = SNLightcurve(data)
    plot_data(snlightcurve; name="SNLightcurve")
    observations = Observations(data)
    plot_data(observations; name="Observations")

    data["time"] .*= u"d"
    data["flux"] .*= u"erg / s / cm^2 / Hz"
    data["e_flux"] .*= u"erg / s / cm^2 / Hz"
    plot_data(data; name="Unitful Data")
    snlightcurve = SNLightcurve(data)
    plot_data(snlightcurve; name="Unitful SNLightcurve")
    observations = Observations(data)
    plot_data(observations; name="Unitful Observations")
end

function (@main)(ARGS)
    main()
end

end # module StructsMethodsTypes
