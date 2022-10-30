drop table if exists test_db.raw_data_table;
create external table if not exists test_db.raw_data_table(
    yyyymmdd int,
    item_num int,
    unit_price int
)
row format delimited fields terminated by ','
location '/test_dir/practice/raw/'
;
select count(*) from test_db.raw_data_table;
select yyyymmdd, count(*)  from test_db.raw_data_table group by yyyymmdd order by yyyymmdd;
