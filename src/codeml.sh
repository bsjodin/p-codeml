#!/usr/bin/env bash

set -e

len=`wc -l $1 | cut -d " " -f1`

while read -r file;do

#initialize variables
ln1=""
ln2=""
df1=""
df2=""
test=""
df=""
prob=""

((++count))

echo "Processing $file ($count of $len)"

cd $2/${file}

#run codeML

echo "Running ModelA."
cd ModelA
echo | codeml codemlModelA.ctl > log.txt
cd ../

echo "Running ModelAnull."
cd ModelAnull 
echo | codeml codemlModelAnull.ctl > log.txt
cd ../

#do chi2 test
ln1=`grep "lnL" ModelA/A_mlc | awk '{print $5}'`
ln2=`grep "lnL" ModelAnull/Anull_mlc | awk '{print $5}'`
df1=`grep "lnL" ModelA/A_mlc | awk '{gsub("):","")1} {print $4}'`
df2=`grep "lnL" ModelAnull/Anull_mlc | awk '{gsub("):","")1} {print $4}'`
if (( $(echo "$ln1 > $ln2" | bc -l) ));then
	test=`echo "(($ln1)-($ln2)) * 2" | bc`
else
	test=`echo "(($ln2)-($ln1)) * 2" | bc`
fi
df=`echo "$df1-$df2" | bc `
echo "ModelA lnL: $ln1" > ${file}_chi2.txt
echo "ModelAnull lnL: $ln2" >> ${file}_chi2.txt
echo "Test statistic: $test" >> ${file}_chi2.txt
echo "ModelA df: $df1" >> ${file}_chi2.txt
echo "ModelAnull df: $df2" >> ${file}_chi2.txt
chi2 $df $test >> ${file}_chi2.txt
prob=`tail -n2 ${file}_chi2.txt | head -n1 | awk '{print $8}'`

echo "p=$prob"

perc1=`echo "scale=3;($count)/$len*100" | bc`
perc2=`echo "scale=1;$perc1/1" | bc`
echo "$perc2% complete."
echo ""

cd ../../

done < $1
