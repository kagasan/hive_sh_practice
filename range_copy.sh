st=20220926
en=20221005

dt=$st
while [ $dt -le $en ]
do
echo $dt `date`
hadoop fs -mkdir -p /test_dir/practice/copy/yyyymmdd=$dt/
hadoop fs -cp -f \
/test_dir/practice/part_data_table/yyyymmdd=$dt/000000_0 \
/test_dir/practice/copy/yyyymmdd=$dt/
dt=`date -d "$dt 1 day" '+%Y%m%d'`
done
hadoop fs -ls -R /test_dir/practice/copy/
