drop table if exists test_db.copy_table;
create external table if not exists test_db.copy_table(
    item_num int,
    unit_price int,
    total_price_tax int
)
partitioned by (yyyymmdd int)
row format delimited fields terminated by ','
location '/test_dir/practice/copy/'
;

MSCK REPAIR TABLE test_db.copy_table;

show partitions test_db.copy_table;
select yyyymmdd, count(*) from test_db.copy_table group by yyyymmdd order by yyyymmdd;
select * from test_db.copy_table where yyyymmdd = 20220926 limit 5;