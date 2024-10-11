from os.path import realpath, dirname, join
from time import time

from matplotlib import pyplot as plt

#
## Constants
#

# Get the directory holding this script
SCRIPT_DIR = dirname(realpath(__file__))
# Get the JuliaWorkshop Path
BASE_DIR = realpath(join(SCRIPT_DIR, "../../../../../"))
# Get the directory of the data
DATA_DIR = join(BASE_DIR, "Data")
# Get the data file
DATA_FILE = join(DATA_DIR, "data.csv")
# Define the output file
OUTPUT_FILE = join(SCRIPT_DIR, "output_py.txt")
# Define the plot file
PLOT_FILE = join(SCRIPT_DIR, "Supernova Lightcurve")


def get_data():
    """
    get_data()

        Read data from DATA_FILE into a dictionary
    """

    # Read file lines into an array
    with open(DATA_FILE, "r") as io:
        raw_data = io.readlines()

    # Headers are the first line
    headers = raw_data[0].split(",")

    # Initialise data dictionary
    data = {header: [] for header in headers}

    # Go row-by-row to read in data
    for row in raw_data[1:]:
        values = row.split(",")
        for col, header in enumerate(headers):
            value = values[col]
            data[header].append(value)

    return data


def analyse_data(data):
    """
    analyse_data(data)

        Peform some simple data analysis, and write the result to a file
    """
    output = []

    # Get headers
    headers = list(data.keys())
    output.append(f"Data has Headers: {headers}")

    # Get number of elements
    num_elems = len(data[headers[0]])
    output.append(f"Data has {num_elems} elements")

    output = "\n".join(output)
    with open(OUTPUT_FILE, "w") as io:
        io.write(output)


def plot_data(data):
    """
    plot_data(data)

        Create a lightcurve plot of the data
    """
    raw_bands = data["band"]
    raw_times = [float(t) for t in data["time"]]
    raw_fluxes = [float(f) for f in data["flux"]]
    raw_flux_errors = [float(e) for e in data["e_flux"]]

    bands = set(raw_bands)
    masks = {band: [b == band for b in raw_bands] for band in bands}
    times = {
        band: [t for (i, t) in enumerate(raw_times) if masks[band][i]] for band in bands
    }
    fluxes = {
        band: [f for (i, f) in enumerate(raw_fluxes) if masks[band][i]]
        for band in bands
    }
    flux_errors = {
        band: [e for (i, e) in enumerate(raw_flux_errors) if masks[band][i]]
        for band in bands
    }

    f = plt.figure()
    ax = f.add_subplot(
        1, 1, 1, xlabel="Time", ylabel="Flux", title="Supernova Lightcurve"
    )

    for band in bands:
        time = times[band]
        flux = fluxes[band]
        flux_error = flux_errors[band]

        scatter_plot = ax.scatter(time, flux, label=band)
        color = scatter_plot.get_facecolor()
        errorbars_plot = ax.errorbar(
            time, flux, yerr=flux_error, fmt="none", ecolor=color
        )

        # Special case for `K` band to make it less visible
        if band == "K":
            # Move to bottom of figure
            scatter_plot.set_zorder(-10)
            # Shrink marker size
            scatter_plot.set_sizes([0.5 * size for size in scatter_plot.get_sizes()])
            # Make colour transparent
            scatter_plot.set_alpha(0.5)
            for child in errorbars_plot.get_children():
                # Move to bottom of figure
                child.set_zorder(-10)
                # Shrink errorbar size
                child.set_linewidth = 0.5 * child.get_linewidth()
                # Make colour transparent
                child.set_alpha(0.5)

    ax.legend(
        title="Bands",
        loc="center left",
        bbox_to_anchor=(1.0, 0.5),
    )
    f.savefig(f"{PLOT_FILE}.svg", bbox_inches="tight")
    f.savefig(f"{PLOT_FILE}.png", bbox_inches="tight")


def main():
    start = time()
    data = get_data()
    analyse_data(data)
    plot_data(data)
    end = time()
    print(f"script.py took {end - start} seconds")


if __name__ == "__main__":
    main()
