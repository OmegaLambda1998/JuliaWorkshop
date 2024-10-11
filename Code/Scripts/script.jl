#
#

#
## Constants
#

# Get the directory holding this script
const SCRIPT_DIR = dirname(abspath(@__FILE__))
# Get the JuliaWorkshop Path
const BASE_DIR = abspath(joinpath(SCRIPT_DIR, "../../"))
# Get the directory of the data
const DATA_DIR = joinpath(BASE_DIR, "Data")
# Get the data file
const DATA_FILE = joinpath(DATA_DIR, "data.csv")
# Define the output file
const OUTPUT_FILE = joinpath(SCRIPT_DIR, "output_jl.txt")


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

function main()
    @time begin
        data = get_data()
        analyse_data(data)
    end
end

function (@main)(ARGS)
    main()
end

