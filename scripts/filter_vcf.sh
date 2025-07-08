#!/bin/bash
directorio_vcf="/home/juanlu/tfm/benchmark/assemblers_comparation/SNV"

cd "$directorio_vcf"

rm *tbi
rm *vcf

for file in *_original_copy
do
	file2="${file/.vcf_original_copy/.vcf}"
	mv "$file" "$file2"
done

echo -e "\n"
ls
echo -e "\n"

cd "$directorio_vcf"

for file in *.vcf
do
	cp "$file" "$file"_original_copy
	echo -e "\nVCF FILE COPIADO\n"
	bgzip -c "$file" > "$file".gz
	echo -e "\nVCF FILE COMPRIMIDO Y POSTERIOR INDEXADO\n"
	tabix -p vcf "$file".gz
	if [[ "$file" = *vpipe.vcf ]]
	then
		echo -e "\nFILTRADO DEL VCF FILE\n"
		bcftools filter -e 'QUAL<100' -o "$file".filtered.vcf "$file"
	else
		echo -e "\nFILTRADO DEL VCF FILE\n"
                bcftools filter -e 'QUAL<20 && INFO/DP<10' -o "$file".filtered.vcf "$file"
	fi
	rm "$file"
	mv "$file".filtered.vcf "$file"
done

rm  *gz
