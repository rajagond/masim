#!/bin/bash

# Define the directory containing .cfg files
configs_dir="./configs"

# Check if the configs directory exists
if [ ! -d "$configs_dir" ]; then
  echo "Error: Directory $configs_dir does not exist."
  exit 1
fi

# Create the output directory if it doesn't exist
output_dir="./damo_masim_data_files"
mkdir -p "$output_dir"

image_dir="./damo_masim_image_files"
mkdir -p "$image_dir"

# Define ranges for parameters
sample_intervals=(100 1000 10000 20000 50000 100000 200000 500000 1000000)
aggregate_intervals=(100 1000 10000 20000 50000 100000 200000 500000 1000000)
update_intervals=(100 1000 10000 20000 50000 100000 200000 500000 1000000)
min_regions=(1 2 4 8 16 32 64 128 512 1024 2048)
max_regions=(1 2 4 8 16 32 64 128 512 1024 2048)

# Loop through each .cfg file in the configs directory
for cfg_file in "$configs_dir"/*.cfg; do
  if [ -f "$cfg_file" ]; then
    filename=$(basename "$cfg_file")
    filename_no_ext="${filename%.*}"  # Get filename without extension

    # Loop through parameter combinations
    for s in "${sample_intervals[@]}"; do
      for a in "${aggregate_intervals[@]}"; do
        if [ "$a" -ge "$s" ]; then
          for u in "${update_intervals[@]}"; do
            for n in "${min_regions[@]}"; do
              for m in "${max_regions[@]}"; do
                if [ "$m" -ge "$n" ]; then
                  output_data_file="$output_dir/${filename_no_ext}_s${s}_a${a}_u${u}_n${n}_m${m}.data"
                  heatmap_image_file="$image_dir/${filename_no_ext}_s${s}_a${a}_u${u}_n${n}_m${m}.png"

                  # Run the command with sudo
                  sudo ../damo/damo record -s "$s" -a "$a" -u "$u" -n "$n" -m "$m" -o "$output_data_file" "./masim $cfg_file"
                  
                  # plot heatmap
                  sudo ../damo/damo report heats -i "$output_data_file" --heatmap "$heatmap_image_file" --stdout_heatmap_color emotion

                  # Optionally, print a message for each file processed
                  echo "Processed $cfg_file with s=$s, a=$a, u=$u, n=$n, m=$m"
                fi
              done
            done
          done
        fi
      done
    done
  fi
done
