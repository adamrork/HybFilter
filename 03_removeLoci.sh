#!/bin/bash

# 03_removeGenes.sh #
# This script removes gene files which are represented by #
# less than a certain proportion of your total samples #

# Create a help function which will print if arguments are empty #

helpFunction()
{
	echo ""
	echo "Usage: $0 -i /PATH/TO/INPUT/DIRECTORY -o /PATH/TO/OUTPUT/DIRECTORY -n /PATH/TO/namelist.txt -p FLOAT"
	echo -e "\t-i Path to the directory containing your FAA and FNA data subdirectories"
	echo -e "\t-o Path to your preferred output directory"
	echo -e "\t-n Namelist file used by hybpiper"
	echo -e "\t-p Genes containing less than this proportion of total samples will be discarded (0.00 - 1.00)"
	exit 1
}

# Create arguments #

while getopts "i:o:n:p:" opt
do
	case "$opt" in
		i ) INPUT_PATH="$OPTARG" ;;
		o ) OUTPUT_PATH="$OPTARG" ;;
		n ) NAMELIST="$OPTARG" ;;
		p ) PROPORTION="$OPTARG" ;;
		? ) helpFunction ;;
	esac
done

# Print helpFunction if arguments are empty #

if [ -z "$INPUT_PATH" ] || [ -z "$OUTPUT_PATH" ] || [ -z "$NAMELIST" ] || [ -z "$PROPORTION" ]
then
	echo "You must supply values for all arguments";
	helpFunction
fi

# If all arguments are provided, begin the analysis #

# Obtain the number of samples examined in the original hybpiper analysis #

SAMPLES=$(wc -l "$NAMELIST" | sed 's/ .*//g')

# Create output subdirectories if not present already #

cd "$OUTPUT_PATH"

if [[ ! -e FAA ]]
then
	mkdir FAA
fi

if [[ ! -e FNA ]]
then
	mkdir FNA
fi

if [[ ! -e IDS ]]
then
	mkdir IDS
fi

# Identify genes represented by too few samples #

cd "$INPUT_PATH"/FAA/

grep -c ">" *.FAA | \
	sed -e 's/:/\t/g' -e 's/.FAA//g' | \
	awk -v SAMPLES="$SAMPLES" '{ $3 = sprintf("%.2f", $2 / SAMPLES) } 1' | \
	awk -v PROPORTION="$PROPORTION" '(NR > 1) && ($3 >= PROPORTION)' | \
	awk '{print $1}' > "$OUTPUT_PATH"/IDS/PASSING_GENES.ids

# Remove amino acid gene files represented by too few samples #

cd "$INPUT_PATH"/FAA/

for i in $(cat "$OUTPUT_PATH"/IDS/PASSING_GENES.ids)
do
	cat "$i".FAA > "$OUTPUT_PATH"/FAA/"$i"_gR.FAA
done

# Remove nucleotide gene files represented by too few samples #

cd "$INPUT_PATH"/FNA/

for i in $(cat "$OUTPUT_PATH"/IDS/PASSING_GENES.ids)
do
	cat "$i".FNA > "$OUTPUT_PATH"/FNA/"$i"_gR.FNA
done
