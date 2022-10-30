drop table if exists test_db.part_data_table;
create external table if not exists test_db.part_data_table(
    item_num int,
    unit_price int,
    total_price_tax int
)
partitioned by (yyyymmdd int)
row format delimited fields terminated by ','
location '/test_dir/practice/raw/part_data_table/'
;
show partitions test_db.part_data_table;
