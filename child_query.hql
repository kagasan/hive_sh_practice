insert overwrite table test_db.part_data_table
partition(yyyymmdd=${log_date})
select
item_num,
unit_price,
item_num * unit_price * 1.1
from test_db.raw_data_table
where yyyymmdd = ${log_date}
;
show partitions test_db.part_data_table;
select * from test_db.part_data_table where yyyymmdd = ${log_date} limit 5;