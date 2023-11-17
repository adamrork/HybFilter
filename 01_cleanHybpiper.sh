#!/bin/bash

# 01_cleanHybpiper.sh #
# This script removes individual sample directories, removes empty fasta files, #
# cleans up sequence names, and reorganizes the remaining files and directories #

# Create a help function which will print if arguments are empty #

helpFunction()
{
	echo ""
	echo "Usage: $0 -h /PATH/TO/HYBPIPER/DIRECTORY -n /PATH/TO/namelist.txt"
	echo -e "\t-h Path to your hybpiper directory"
	echo -e "\t-n Namelist file used by hybpiper"
	exit 1
}

# Create arguments #

while getopts "h:n:" opt
do
	case "$opt" in
		h ) HYBPIPER_PATH="$OPTARG" ;;
		n ) NAMELIST="$OPTARG" ;;
		? ) helpFunction ;;
	esac
done

# Print helpFunction if arguments are empty #

if [ -z "$HYBPIPER_PATH" ] || [ -z "$NAMELIST" ]
then
	echo "You must supply values for all arguments";
	helpFunction
fi

# If all arguments are provided, begin the analysis #

# Remove superfluous directories #

cd "$HYBPIPER_PATH"

for i in $(cat "$NAMELIST")
do
	rm -r "$i"/
done

# Remove empty FASTA files #

find . -maxdepth 1 -type f -name '*.FAA' -empty -delete -print
find . -maxdepth 1 -type f -name '*.FNA' -empty -delete -print

# Reorganize the Hybpiper directory #

mkdir FAA FNA FILES PARALOGS

for i in $(ls *.F[A\|N]A | sed 's/.F[A|N]A//g' | sort -u)
do
	sed -i 's/ .*//g' "$i".FAA
	mv -v "$i".FAA FAA/

	sed -i 's/ .*//g' "$i".FNA
	mv -v "$i".FNA FNA/
done

find . -maxdepth 1 -type f -print -exec mv {} FILES/ \;

mv -v paralogs_all PARALOGS/
mv -v paralogs_no_chimeras PARALOGS/
