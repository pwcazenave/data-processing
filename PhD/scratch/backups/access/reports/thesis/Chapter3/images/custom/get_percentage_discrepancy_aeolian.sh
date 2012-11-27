mean=$(awk -F, '{sum+=$5}END{print sum/NR}' ./raw_data/relationships/srtm_15000m_subset_results_errors_asymm.csv)
awk -F, '{if ($3>2 && $15==1) print $5/(0.001001*$3^1.349),$5/'$mean'}' ./raw_data/relationships/srtm_15000m_subset_results_errors_asymm.csv > ./raw_data/discrepancies_aeolian.txt

mean=$(awk -F, '{sum+=$5}END{print sum/NR}' ./raw_data/relationships/srtm_30000m_subset_results_errors_asymm.csv)
awk -F, '{if ($3>2 && $15==1) print $5/(0.001001*$3^1.349),$5/'$mean'}' ./raw_data/relationships/srtm_30000m_subset_results_errors_asymm.csv >> ./raw_data/discrepancies_aeolian.txt

mean=$(awk -F, '{sum+=$5}END{print sum/NR}' ./raw_data/relationships/srtm_40000m_subset_results_errors_asymm.csv)
awk -F, '{if ($3>2 && $15==1) print $5/(0.001001*$3^1.349),$5/'$mean'}' ./raw_data/relationships/srtm_40000m_subset_results_errors_asymm.csv >> ./raw_data/discrepancies_aeolian.txt

mean=$(awk -F, '{sum+=$5}END{print sum/NR}' ./raw_data/relationships/srtm_45000m_subset_results_errors_asymm.csv)
awk -F, '{if ($3>2 && $15==1) print $5/(0.001001*$3^1.349),$5/'$mean'}' ./raw_data/relationships/srtm_45000m_subset_results_errors_asymm.csv >> ./raw_data/discrepancies_aeolian.txt

awk '{if ($1<1) lt1+=1}END{printf "Less than one: %.2f\n", (lt1/NR)*100}' ./raw_data/discrepancies_aeolian.txt
awk '{if ($1>0.5 && $1<2) wtn2+=1}END{printf "Within double or half: %.2f\n", (wtn2/NR)*100}' ./raw_data/discrepancies_aeolian.txt

