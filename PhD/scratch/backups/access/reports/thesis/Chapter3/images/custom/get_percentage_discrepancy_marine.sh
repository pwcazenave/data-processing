awk -F, '{if ($3>2 && $15==1) print $5/(0.06088*$3^0.6891),$5/0.510743}' ./raw_data/relationships/jibs_350m_subset_results_errors_asymm.csv > ./raw_data/discrepancies_marine.txt
awk -F, '{if ($3>2 && $15==1) print $5/(0.06088*$3^0.6891),$5/1.89377}' ./raw_data/relationships/jibs_2500m_subset_results_errors_asymm.csv >> ./raw_data/discrepancies_marine.txt
awk -F, '{if ($3>2 && $15==1) print $5/(0.06088*$3^0.6891),$5/0.229101}' ./raw_data/relationships/hsb_300m_subset_results_errors_asymm.csv >> ./raw_data/discrepancies_marine.txt
awk -F, '{if ($3>2 && $15==1) print $5/(0.06088*$3^0.6891),$5/0.236206}' ./raw_data/relationships/ws_200m_subset_results_errors_asymm.csv >> ./raw_data/discrepancies_marine.txt
awk -F, '{if ($3>2 && $15==1) print $5/(0.06088*$3^0.6891),$5/0.888083}' ./raw_data/relationships/area481_500-1500m_subset_results_errors_asymm.csv >> ./raw_data/discrepancies_marine.txt
awk -F, '{if ($3>2 && $2>=5907500 && $2<=5909300 && $1>=344500 && $1<=345800) print $5/(0.06088*$3^0.6891),$5/0.317708}' ./raw_data/relationships/area481_200m_subset_results_errors_asymm.csv >> ./raw_data/discrepancies_marine.txt
awk -F, '{if ($3>40 && $15==1) print $5/(0.06088*$3^0.6891),$5/3.01432}' ./raw_data/relationships/seazone_1500-4000m_subset_results_errors_asymm.csv >> ./raw_data/discrepancies_marine.txt
awk -F, '{if ($3>4 && $15==1) print $5/(0.06088*$3^0.6891),$5/0.209335}' ./raw_data/relationships/culver_sands_200m_subset_results_errors_asymm_2009.csv >> ./raw_data/discrepancies_marine.txt
awk -F, '{if ($3>400 && $15==1) print $5/(0.06088*$3^0.6891),$5/6.21983}' ./raw_data/relationships/britned_50000-20000m_subset_results_errors_asymm.csv >> ./raw_data/discrepancies_marine.txt

awk '{if ($1<1) lt1+=1}END{printf "Less than one: %.2f\n", (lt1/NR)*100}' ./raw_data/discrepancies_marine.txt
awk '{if ($1>0.5 && $1<2) wtn2+=1}END{printf "Within double or half: %.2f\n", (wtn2/NR)*100}' ./raw_data/discrepancies_marine.txt

