#/usr/bin/env bash

set -e

#trap 'pkill codeml' SIGINT SIGKILL ERR exit

usage() { echo "Usage: $0 -i [input_dir] -o [output_dir] -n [threads]" 1>&2; exit 1; }
help="p-codeml.sh is a script for automating CodeML in parallel for the branch-site model over many genes.

Usage: ./p-codeml.sh -i [input_dir] -o [output_dir] -n [threads]

Option        Description
-i [string] : required; input directory containing PAML formated files (must have .pml suffix)
-o [string] : optional; output directory, default is 'output'
-n [int]    : optional; number of threads/processes to run simulatenously, default is 1
"

while [[ $# -gt 0 ]]
do
	key="$1"
	case $key in
		-i) #input directory
		input=$PWD/"$2"
		shift;shift
		;;
		
		-o) #output directory
		output=$PWD/"$2"
		shift;shift
		;;
		
		-n|--threads) #number of instances
		threads="$2"
		shift;shift
		;;
		
		-h|--help) #print help message
		echo "$help"
		exit 0
		;;
		
		*) #exits out if unknown option
		echo "ERROR: unknown option "$1""
		usage
		;;
		
	esac
done

#check variables parsed correctly
if [[ -z $input ]];then
	echo "ERROR: Please specify an input directory."
	usage
fi

if [[ -z $output ]];then
	output=$PWD/output
fi

if [[ -z "$threads" ]];then
	threads=1
fi

#create list of input files
basename -s .pml `ls $input` > fofn.txt

#generate CTL files
echo "Setting up directories and generating CTL files"
./src/generate_ctl.sh $input $output

#run codeml
echo "Running CodeML"
echo

mkdir -p logs
if [[ "$threads" -eq 1 ]];then
	./src/codeml.sh fofn.txt $output | tee ./logs/codeml.log

else
	split --numeric-suffixes=1 -n l/$threads -a 1 fofn.txt fofn.txt
	for N in $(seq 1 $threads);do
		./src/codeml.sh fofn.txt"$N" $output > ./logs/codeml"$N".log 2>&1 &
	done
fi

loop=1
while [[ $(grep "complete" ./logs/codeml*log | wc -l) -lt $(wc -l fofn.txt | cut -d " " -f1) ]];do
if [[ "$loop" -eq 1 ]];then
	tail -n6 ./logs/codeml*log | grep "Processing"
	sleep 10
	loop=2
else
	tput cuu $threads
	tail -n6 ./logs/codeml*log | grep "Processing"
	sleep 10
fi
done

#for N in $(seq 1 $threads);do
#	echo
#done

echo -e "\nFinished running CodeML"

wait

#Find significant groups
./src/parse_psg.sh $output

if [[ ! -f "final_table.txt" ]];then
	echo -e "\nERROR: Program exited without completing!"
else
	rm fofn.txt*
fi
