import os
import re
from prettytable import PrettyTable
import matplotlib.pyplot as plt

# Define the directory containing performance files
perf_dir = "./2024-07-11_perf_11_July_data_analysis_files"

# Check if the perf directory exists
if not os.path.isdir(perf_dir):
    print(f"Error: Directory {perf_dir} does not exist.")
    exit(1)

# Initialize PrettyTable
table = PrettyTable()
table.field_names = ["Filename", "CFG File", "Sample Interval", "Aggregate Interval", "Update Interval", "Min Regions", "Max Regions", "Elapsed - wo DAMO", "Elapsed - w DAMO", "Elapsed - w DAMO Default", "Overhead %", "Overhead-w-default %"]

# Initialize dictionaries to store times for plotting and calculations
times_wo_damo = {}
times_w_damo = {}
times_default_damo = {}

# Regex to extract parameters and time elapsed
param_regex = re.compile(r'(.*)_s(\d+)_a(\d+)_u(\d+)_n(\d+)_m(\d+)-')
time_regex = re.compile(r'\s+(\d+\.\d+) seconds time elapsed')

# Loop through each .perf file in the perf directory
for perf_file in os.listdir(perf_dir):
    if perf_file.endswith(".perf"):
        with open(os.path.join(perf_dir, perf_file), 'r') as f:
            content = f.read()

            # Extract parameters
            params_match = param_regex.search(perf_file)
            if not params_match:
                continue
            cfg_file, s, a, u, n, m = params_match.groups()

            # Extract time elapsed
            time_match = time_regex.search(content)
            if not time_match:
                continue
            time_elapsed = float(time_match.group(1))

            # Store times in dictionaries
            key = (cfg_file, s, a, u, n, m)
            if 'wo-damo' in perf_file:
                times_wo_damo[key] = time_elapsed
            elif 'w-damo' in perf_file:
                times_w_damo[key] = time_elapsed
            else:
                times_default_damo[key] = time_elapsed

# Calculate overhead and populate the table
overheads = {}
overheads_w_default = {}
for key in times_wo_damo:
    if key in times_w_damo:
        cfg_file, s, a, u, n, m = key
        time_wo_damo = times_wo_damo[key]
        time_w_damo = times_w_damo[key]
        time_default_damo =  times_default_damo[key]
        overhead = ((time_w_damo - time_wo_damo) / time_wo_damo) * 100.0
        overhead2 = ((time_default_damo - time_wo_damo) / time_wo_damo) * 100.0
        filename = f"{cfg_file}_s{s}_a{a}_u{u}_n{n}_m{m}"
        table.add_row([filename, cfg_file, s, a, u, n, m, time_wo_damo, time_w_damo, time_default_damo, overhead, overhead2])
        overheads[key] = overhead
        overheads_w_default[key] = overhead2

# Sort the table by CFG File, Sample Interval, Aggregate Interval, Update Interval, Min Regions, Max Regions
table.sortby = "Filename"

# Print the table
print(table)

# Plot the overhead for each parameter variation
def plot_overhead(fixed_params, param_index, param_name, param_values):
    fixed_keys = [key for key in overheads.keys() if all(key[i] == fixed_params[i] for i in range(6) if i != param_index)]
    fixed_overheads = [overheads[key] for key in fixed_keys]
    varying_values = [int(key[param_index]) for key in fixed_keys]

    plt.figure()
    plt.plot(varying_values, fixed_overheads, marker='o')
    plt.xlabel(param_name)
    plt.ylabel('Overhead %')
    plt.title(f'Overhead % by varying {param_name}')
    plt.grid(True)
    plt.show()

# Choose a fixed set of parameters
fixed_cfg_file = '200mb'
fixed_s, fixed_a, fixed_u, fixed_n, fixed_m = 1000, 1000, 1000, 16, 16

# Plot overheads by varying one parameter at a time
plot_overhead((fixed_cfg_file, fixed_s, fixed_a, fixed_u, fixed_n, fixed_m), 1, 'Sample Interval', [1000, 10000, 100000, 1000000])
plot_overhead((fixed_cfg_file, fixed_s, fixed_a, fixed_u, fixed_n, fixed_m), 2, 'Aggregate Interval', [1000, 10000, 100000, 1000000])
plot_overhead((fixed_cfg_file, fixed_s, fixed_a, fixed_u, fixed_n, fixed_m), 3, 'Update Interval', [1000, 10000, 100000, 1000000])
plot_overhead((fixed_cfg_file, fixed_s, fixed_a, fixed_u, fixed_n, fixed_m), 4, 'Min Regions', [16, 64, 512, 1024, 2048])
plot_overhead((fixed_cfg_file, fixed_s, fixed_a, fixed_u, fixed_n, fixed_m), 5, 'Max Regions', [16, 64, 512, 1024, 2048])
