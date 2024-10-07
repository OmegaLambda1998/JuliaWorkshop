import os
from time import time


def read_data(data_path):
    with open(data_path, "r") as io:
        rows = io.readlines()
    headers = rows[0].split(",")
    data = {header: [] for header in headers}
    for row in rows[1:]:
        vals = row.split(",")
        for i, val in enumerate(vals):
            header = headers[i]
            data[header].append(val)
    return data


def main():
    base_dir = "../../"  # JuliaWorkshop
    data_dir = os.path.join(base_dir, "Data")
    data_path = os.path.join(data_dir, "data.csv")
    data = read_data(data_path)
    print(f"Headers: {data.keys()}")
    print(f"Number of Observations: {len(data["zp"])}")


if __name__ == "__main__":
    start = time()
    main()
    elapsed = time() - start
    print(f"{elapsed} seconds")
