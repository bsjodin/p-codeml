#!/usr/bin/env bash

set -e

#reinitialize pvalue.txt if necessary
if [[ -f "pvalues.txt" ]];then
rm pvalues.txt
fi

#parse pvalues for all groups

echo "Parsing p-values."

while read line;do

prob=`grep "prob" $1/$line/"$line"_chi2.txt | cut -d "=" -f3 | awk 'gsub("[ ]+","")'`
echo $line $prob >> pvalues.txt

done < fofn.txt

#apply bonferroni correction
echo "Applying Bonferonni correction."
Rscript ./src/pvalue_correct.R >& /dev/null

#parse out significant corrected pvalues
echo "Detecting significant corrected p-values."
awk '$3<=0.01' pvalues-correct.txt > high-p.txt

#detect groups with >=1 positively selected sites
echo "Parsing significant sites."

pass=0

if [[ -f "significant_groups.txt" ]];then
rm significant_groups.txt
fi

while read line;do

name=`echo $line | cut -d " " -f1`

sed -n -e "/^Bayes/,/^$/ p" $1/$name/ModelA/A_mlc | tail -n +3 | awk '$3>=0.99' > $1/$name/positive_sites.txt
pos=`wc -l $1/$name/positive_sites.txt | awk '{print $1}'`

if [[ "$pos" -gt 0 ]];then
echo $name >> significant_groups.txt
((++pass))
fi

done < high-p.txt

#create final table
echo "Generating final output."

printf "Group\tAlt_lnL\tNull_lnL\tpvalue\tcorrected_pvalue\t#pos_sites\tsite_names\n" > final_table.txt

while read line;do
ln1=`grep "ModelA lnL" $1/"$line"/"$line"_chi2.txt | awk '{print $3}'`
ln2=`grep "ModelAnull lnL" $1/"$line"/"$line"_chi2.txt | awk '{print $3}'`
p1=`grep "$line" pvalues-correct.txt | awk '{print $1}'`
p2=`grep "$line" pvalues-correct.txt | awk '{print $3}'`
sites=`wc -l $1/"$line"/positive_sites.txt | awk '{print $1}'`
sites2=`awk '{print $1}' $1/"$line"/positive_sites.txt | datamash transpose -t ","`

printf "$line\t$ln1\t$ln2\t$p1\t$p2\t$sites\t$sites2\n" >> final_table.txt

done < significant_groups.txt

rm significant_groups.txt pvalues.txt high-p.txt

echo ""
echo "$pass PSGs detected."