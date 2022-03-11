#!/usr/bin/env bash

input=$1
output=$2
tree=$3

mkdir -p $output

while read file;do
mkdir -p $output/$file
mkdir -p $output/$file/ModelA $output/$file/ModelAnull

echo "seqfile = ${input}/${file}.pml" > $output/$file/ModelA/codemlModelA.ctl
echo "treefile = ${tree}" >> $output/$file/ModelA/codemlModelA.ctl
echo "outfile = A_mlc" >> $output/$file/ModelA/codemlModelA.ctl
less $PWD/src/codemlModelA.ctl >> $output/$file/ModelA/codemlModelA.ctl

echo "seqfile = ${input}/${file}.pml" >> $output/$file/ModelAnull/codemlModelAnull.ctl
echo "treefile = ${tree}" >> $output/$file/ModelAnull/codemlModelAnull.ctl
echo "outfile = Anull_mlc" >> $output/$file/ModelAnull/codemlModelAnull.ctl
less $PWD/src/codemlModelAnull.ctl >> $output/$file/ModelAnull/codemlModelAnull.ctl

done < fofn.txt
