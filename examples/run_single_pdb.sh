#!/bin/bash

# Script to run ProteinMPNN on a single PDB file

# Default values
NUM_SEQ_PER_TARGET=2
SAMPLING_TEMP="0.1"
CHAINS_TO_DESIGN="" # Empty means all chains will be processed by default logic in protein_mpnn_run.py

# Help message
usage() {
  echo "Usage: $0 -p <pdb_file> -o <output_dir> [-c <chains_to_design>] [-n <num_seq_per_target>] [-t <sampling_temp>]"
  echo ""
  echo "Options:"
  echo "  -p <pdb_file>             : Path to the input PDB file (required)."
  echo "  -o <output_dir>           : Path to the output directory (required)."
  echo "  -c <chains_to_design>     : Chains to design (e.g., \"A B\"). If not specified, attempts to design all chains."
  echo "  -n <num_seq_per_target>   : Number of sequences to generate per target (default: ${NUM_SEQ_PER_TARGET})."
  echo "  -t <sampling_temp>        : Sampling temperature (default: ${SAMPLING_TEMP})."
  echo "  -h                        : Display this help message."
  exit 1
}

# Parse command-line arguments
while getopts ":p:o:c:n:t:h" opt; do
  case ${opt} in
    p )
      PDB_FILE=$OPTARG
      ;;
    o )
      OUTPUT_DIR=$OPTARG
      ;;
    c )
      CHAINS_TO_DESIGN=$OPTARG
      ;;
    n )
      NUM_SEQ_PER_TARGET=$OPTARG
      ;;
    t )
      SAMPLING_TEMP=$OPTARG
      ;;
    h )
      usage
      ;;
    ? )
      echo "Invalid option: $OPTARG" 1>&2
      usage
      ;;
    : )
      echo "Invalid option: $OPTARG requires an argument" 1>&2
      usage
      ;;
  esac
done
shift $((OPTIND -1))

# Check if required arguments are provided
if [ -z "${PDB_FILE}" ] || [ -z "${OUTPUT_DIR}" ]; then
    echo "Error: Missing required arguments."
    usage
fi

# Create output directory if it doesn't exist
if [ ! -d "${OUTPUT_DIR}" ]; then
    mkdir -p "${OUTPUT_DIR}"
    echo "Created output directory: ${OUTPUT_DIR}"
fi

# Construct the command
CMD_ARGS=(
    "--pdb_path" "${PDB_FILE}"
    "--out_folder" "${OUTPUT_DIR}"
    "--num_seq_per_target" "${NUM_SEQ_PER_TARGET}"
    "--sampling_temp" "${SAMPLING_TEMP}"
    "--seed" "37"  # Or make this an argument
    "--batch_size" "1" # Or make this an argument
)

if [ -n "${CHAINS_TO_DESIGN}" ]; then
    CMD_ARGS+=("--pdb_path_chains" "${CHAINS_TO_DESIGN}")
fi

# Activate conda environment if needed - assuming it's already active or sourced in .bashrc/.zshrc for simplicity
# source activate mlfold 

echo "Running ProteinMPNN with the following command:"
echo "python ../protein_mpnn_run.py ${CMD_ARGS[@]}"

# Execute the command
python ../protein_mpnn_run.py "${CMD_ARGS[@]}"

echo "ProteinMPNN run finished. Check ${OUTPUT_DIR} for results." 