function read_data(data_path)
    rows = open(data_path, "r") do io
        readlines(io)
    end
    headers = split(rows[1], ",")
    data = Dict(header => [] for header in headers)
    for row in rows[2:end]
        vals = split(row, ",")
        for (i, val) in enumerate(vals)
            header = headers[i]
            push!(data[header], val)
        end
    end
    return data
end

function analyse_data(data)
    headers = keys(data)
    bands = data["band"]
    redshifts = data["z"]
end

function main()
    base_dir = "../../"
    data_dir = joinpath(base_dir, "Data")
    data_path = joinpath(data_dir, "data.csv")
    data = read_data(data_path)
    analyse_data(data)
end

if abspath(PROGRAM_FILE) == @__FILE__
    @time main()
end

