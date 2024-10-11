from os.path import realpath, dirname, join
from time import time

#
## Constants
#

# Get the directory holding this script
SCRIPT_DIR = dirname(realpath(__file__))
# Get the JuliaWorkshop Path
BASE_DIR = realpath(join(SCRIPT_DIR, "../../"))
# Get the directory of the data
DATA_DIR = join(BASE_DIR, "Data")
# Get the data file
DATA_FILE = join(DATA_DIR, "data.csv")
# Define the output file
OUTPUT_FILE = join(SCRIPT_DIR, "output_py.txt")


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


def main():
    start = time()
    data = get_data()
    analyse_data(data)
    end = time()
    print(f"script.py took {end - start} seconds")


if __name__ == "__main__":
    main()
