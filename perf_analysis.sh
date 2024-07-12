#!/bin/bash

# Define the directory containing .cfg files
configs_dir="./configs"

# Check if the configs directory exists
if [ ! -d "$configs_dir" ]; then
  echo "Error: Directory $configs_dir does not exist."
  exit 1
fi

current_datetime=$(date +"%Y-%m-%d")
# Create the output directory if it doesn't exist
output_dir="./${current_datetime}_perf_damo_masim_files"
mkdir -p "$output_dir"


perf_dir="./${current_datetime}_perf_11_July_data_analysis_files"
mkdir -p "$perf_dir"


# Define ranges for parameters
sample_intervals=(1000 10000 100000 1000000)
aggregate_intervals=(1000000 2000000 4000000)
update_intervals=(1000000 2000000 4000000 8000000)
min_regions=(1024 2048)
max_regions=(1024 2048)

# Loop through each .cfg file in the configs directory
for cfg_file in "$configs_dir"/*.cfg; do
  if [ -f "$cfg_file" ]; then
    filename=$(basename "$cfg_file")
    filename_no_ext="${filename%.*}"  # Get filename without extension
    echo "prr $cfg_file "
    # Loop through parameter combinations
    for s in "${sample_intervals[@]}"; do
      for a in "${aggregate_intervals[@]}"; do
        if [ "$a" -ge "$s" ]; then
          for u in "${update_intervals[@]}"; do
            if [ "$u" -ge "$a" ]; then
              for n in "${min_regions[@]}"; do
                for m in "${max_regions[@]}"; do
                  if [ "$m" -ge "$n" ]; then
                    output_data_file="$output_dir/${filename_no_ext}_s${s}_a${a}_u${u}_n${n}_m${m}.data"
                    output_data_file_default="$output_dir/${filename_no_ext}_s${s}_a${a}_u${u}_n${n}_m${m}_default.data"
                    perf_file_wo_damo="$perf_dir/${filename_no_ext}_s${s}_a${a}_u${u}_n${n}_m${m}-wo-damo.perf"
                    perf_file_w_damo="$perf_dir/${filename_no_ext}_s${s}_a${a}_u${u}_n${n}_m${m}-w-damo.perf"
                    perf_file_default_damo="$perf_dir/${filename_no_ext}_s${s}_a${a}_u${u}_n${n}_m${m}-default-damo.perf"
                    # Run the command with sudo
                    # sudo ../damo/damo record -s "$s" -a "$a" -u "$u" -n "$n" -m "$m" -o "$output_data_file" "./masim $cfg_file"
                    
                    perf stat -o $perf_file_wo_damo -d ./masim $cfg_file --silent

                    perf stat -o $perf_file_w_damo -d ../damo/damo record -o $output_data_file -s ${s} -a ${a} -u ${u} -n ${n} -m ${m} "./masim $cfg_file --silent"

                    perf stat -o $perf_file_default_damo -d ../damo/damo record -o $output_data_file_default "./masim $cfg_file --silent"
                    # # plot heatmap
                    # sudo ../damo/damo report heats -i "$output_data_file" --heatmap "$heatmap_image_file" --stdout_heatmap_color emotion

                    # # Optionally, print a message for each file processed
                    echo "Processed $cfg_file with s=$s, a=$a, u=$u, n=$n, m=$m"
                  fi
                done
              done
            fi
          done
        fi
      done
    done
  fi
done