#!/bin/bash

# 02_removePtc.sh #
# This script removes sequences from your loci files #
# which contain premature termination codons in frame 1 #

# Create a help function which will print if arguments are empty #

helpFunction()
{
	echo ""
	echo "Usage: $0 -h /PATH/TO/HYBPIPER/DIRECTORY -o /PATH/TO/OUTPUT/DIRECTORY"
	echo -e "\t-h Path to your hybpiper directory"
	echo -e "\t-o Path to your preferred output directory"
	exit 1
}

# Create arguments #

while getopts "h:o:" opt
do
	case "$opt" in
		h ) HYBPIPER_PATH="$OPTARG" ;;
		o ) OUTPUT_PATH="$OPTARG" ;;
		? ) helpFunction ;;
	esac
done

# Print helpFunction if arguments are empty #

if [ -z "$HYBPIPER_PATH" ] || [ -z "$OUTPUT_PATH" ]
then
	echo "You must supply values for all arguments";
	helpFunction
fi

# If all arguments are provided, begin the analysis #

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

# Identify sequences containing premature termination codons in frame 1 #

cd "$HYBPIPER_PATH"/FAA/

for i in $(ls *.FAA | sed 's/.FAA//g')
do
	awk '/^>/ { printf("\n%s\n", $0); next; } { printf("%s", $0); } END { printf("\n", $0); }' "$i".FAA | \
		awk '{ RS=">" } { print(">"$1"\t"$2);}' | \
		awk 'NR > 2' | \
		grep "\*" | \
		sed -e 's/>//g' -e 's/\t.*//g' > "$OUTPUT_PATH"/IDS/"$i"_removePTC.ids
done

# Remove amino acid sequences containing premature termination codons in frame 1 #

cd "$HYBPIPER_PATH"/FAA/

for i in $(ls *.FAA | sed 's/.FAA//g')
do
	awk '/^>/ { printf("\n%s\n", $0); next; } { printf("%s", $0); } END { printf("\n", $0); }' "$i".FAA | \
		awk '{ RS=">" } { print(">"$1"\t"$2);}' | \
		awk 'NR > 2' | \
		grep -v -f "$OUTPUT_PATH"/IDS/"$i"_removePTC.ids | \
		tr "\t" "\n" > "$OUTPUT_PATH"/FAA/"$i"_pR.FAA
done

# Remove nucleotide sequences containing premature termination codons in frame 1 #

cd "$HYBPIPER_PATH"/FNA/

for i in $(ls *.FNA | sed 's/.FNA//g')
do
	awk '/^>/ { printf("\n%s\n", $0); next; } { printf("%s", $0); } END { printf("\n", $0); }' "$i".FNA | \
		awk '{ RS=">" } { print(">"$1"\t"$2);}' | \
		awk 'NR > 2' | \
		grep -v -f "$OUTPUT_PATH"/IDS/"$i"_removePTC.ids | \
		tr "\t" "\n" > "$OUTPUT_PATH"/FNA/"$i"_pR.FNA
done
