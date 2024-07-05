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

# Loop through each .cfg file in the configs directory
for cfg_file in "$configs_dir"/*.cfg; do
  if [ -f "$cfg_file" ]; then
    filename=$(basename "$cfg_file")
    filename_no_ext="${filename%.*}"  # Get filename without extension

    # Run the command with sudo
    sudo ../damo/damo record -s 1000000 -n 1024 -m 1024 -o "$output_dir/$filename_no_ext.data" "./masim $cfg_file"
    
    # plot heatmap
    sudo ../damo/damo report heats -i "$output_dir/$filename_no_ext.data" --heatmap "$image_dir/$filename_no_ext.png" --stdout_heatmap_color emotion

    # sudo ../damo/damo report wss -i "$output_dir/$filename_no_ext.data" --plot "$image_dir/$filename_no_ext-wss-time.png" --sortby time

    # sudo ../damo/damo report wss -i "$output_dir/$filename_no_ext.data" --plot "$image_dir/$filename_no_ext-wss-size.png" --sortby size
    # # Optionally, print a message for each file processed
    echo "Processed $cfg_file"
  fi
done