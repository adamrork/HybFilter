#!/bin/bash

# 04_removeSamples.sh #
# This script removes sequences belonging to samples which are #
# represented by less than a certain proportion of your total loci #

# Create a help function which will print if arguments are empty #

helpFunction()
{
	echo ""
	echo "Usage: $0 -i /PATH/TO/INPUT/DIRECTORY -o /PATH/TO/OUTPUT/DIRECTORY -n /PATH/TO/namelist.txt -p FLOAT"
	echo -e "\t-i Path to the directory containing your FAA and FNA data subdirectories"
	echo -e "\t-o Path to your preferred output directory"
	echo -e "\t-n Namelist file used by hybpiper"
	echo -e "\t-p Samples containing less than this proportion of total loci will be discarded (0.00 - 1.00)"
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

# Obtain the number of loci in the input directory #

LOCI=$(ls "$INPUT_PATH"/FAA/*.FAA | wc -l)

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

# Identify samples represented by too few loci #

cd "$INPUT_PATH"/FAA/

for i in $(cat "$NAMELIST")
do
	grep ""$i"" *.FAA | \
		sed -e 's/.*>//g' -e 's/ .*//g' | \
		sort | \
		uniq -c | \
		awk -v LOCI="$LOCI" 'FS=OFS="\t" { print($2, $1, LOCI) }' | \
		awk -v PROPORTION="$PROPORTION" 'FS=OFS="\t" { $4 = sprintf("%.2f", $2 / $3) } 1 && ($4 >= PROPORTION)' | \
		awk '{ print($1) }'
done > "$OUTPUT_PATH"/IDS/PASSING_SAMPLES.ids

# Remove amino acid sequences belonging to samples represented by too few loci #

cd "$INPUT_PATH"/FAA/

for i in $(ls *.FAA | sed 's/.FAA//g')
do
	awk '/^>/ { printf("\n%s\n", $0); next; } { printf("%s", $0); } END { printf("\n", $0); }' "$i".FAA | \
		awk '{ RS=">" } { print(">"$1"\t"$2);}' | \
		awk 'NR > 2' | \
		grep -f "$OUTPUT_PATH"/IDS/PASSING_SAMPLES.ids | \
		tr "\t" "\n" > "$OUTPUT_PATH"/FAA/"$i"_sR.FAA
done

# Remove nucleotide sequences belonging to samples represented by too few loci #

cd "$INPUT_PATH"/FNA/

for i in $(ls *.FNA | sed 's/.FNA//g')
do
	awk '/^>/ { printf("\n%s\n", $0); next; } { printf("%s", $0); } END { printf("\n", $0); }' "$i".FNA | \
		awk '{ RS=">" } { print(">"$1"\t"$2);}' | \
		awk 'NR > 2' | \
		grep -f "$OUTPUT_PATH"/IDS/PASSING_SAMPLES.ids | \
		tr "\t" "\n" > "$OUTPUT_PATH"/FNA/"$i"_sR.FNA
done
