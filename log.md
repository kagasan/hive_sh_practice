# 練習ログ

## 環境
```
hadoopコマンドを実行可能, test_dirディレクトリを用意してある
$ hadoop fs -ls -h /test_dir/

hiveにはtest_dbスキーマを用意してある

hqlをbeelineで実行可能, run_query.shを用意してある
$ . run_query.sh {query.hql}
```

## 元データ用意
```
まずraw_data.csvを用意（gen_raw_data.cpp）
yyyymmdd,個数,単価の形式で500行ヘッダなし, 終端改行なし
- yyyymmdd：20220926 - 20221005の範囲でランダム
- 個数：1 - 10の範囲でランダム
- 単価：100-50000の範囲でランダム
```

## 元データテーブル化
```
csvを元にraw_data_tableを作成する。
$ hadoop fs -mkdir -p /test_dir/practice/raw
$ hadoop fs -put raw_data.csv /test_dir/practice/raw
$ . run_query.sh raw_create.hql && cat out.txt
```
実行結果
```
+------+
| _c0  |
+------+
| 500  |
+------+

+-----------+------+
| yyyymmdd  | _c1  |
+-----------+------+
| 20220926  | 46   |
| 20220927  | 53   |
| 20220928  | 49   |
| 20220929  | 51   |
| 20220930  | 50   |
| 20221001  | 52   |
| 20221002  | 49   |
| 20221003  | 55   |
| 20221004  | 37   |
| 20221005  | 58   |
+-----------+------+
```

## 連携先テーブル作成
```
part_data_tableのガワを作成する。
item_num 個数
unit_price 単価
total_price_tax 税込合計
yyyymmdd パーティション
$ . run_query.sh part_create.hql && cat out.txt
```
実行結果
```
+------------+
| partition  |
+------------+
+------------+
```

## 連携クエリ
```
20220926対象にraw to partのetlを実行してみる
$ . run_query.sh etl_1.hql && cat out.txt
$ hadoop fs -cat /test_dir/practice/part_data_table/yyyymmdd=20220926/000000_0 | head -n 5
```
実行結果
```
+--------------------+
|     partition      |
+--------------------+
| yyyymmdd=20220926  |
+--------------------+

+---------------------------+-----------------------------+----------------------------------+---------------------------+
| part_data_table.item_num  | part_data_table.unit_price  | part_data_table.total_price_tax  | part_data_table.yyyymmdd  |
+---------------------------+-----------------------------+----------------------------------+---------------------------+
| 10                        | 24774                       | 272514                           | 20220926                  |
| 6                         | 39272                       | 259195                           | 20220926                  |
| 8                         | 4761                        | 41896                            | 20220926                  |
| 4                         | 38631                       | 169976                           | 20220926                  |
| 3                         | 21631                       | 71382                            | 20220926                  |
+---------------------------+-----------------------------+----------------------------------+---------------------------+

10,24774,272514
6,39272,259195
8,4761,41896
4,38631,169976
3,21631,71382
```

## 日付実行スクリプト
```
上のクエリは日付埋め込みなので、日付を指定して処理できるようにする
$ . etl_child.sh child_query.hql 20221001 && cat out.txt
$ hadoop fs -ls -R /test_dir/practice/part_data_table/
```
実行結果
```
+--------------------+
|     partition      |
+--------------------+
| yyyymmdd=20220926  |
| yyyymmdd=20221001  |
+--------------------+

+---------------------------+-----------------------------+----------------------------------+---------------------------+
| part_data_table.item_num  | part_data_table.unit_price  | part_data_table.total_price_tax  | part_data_table.yyyymmdd  |
+---------------------------+-----------------------------+----------------------------------+---------------------------+
| 6                         | 31047                       | 204910                           | 20221001                  |
| 2                         | 39185                       | 86207                            | 20221001                  |
| 1                         | 36580                       | 40238                            | 20221001                  |
| 6                         | 37700                       | 248820                           | 20221001                  |
| 3                         | 12682                       | 41850                            | 20221001                  |
+---------------------------+-----------------------------+----------------------------------+---------------------------+
drwxr-xr-x   - kagasan supergroup          0 2022-10-30 14:53 /test_dir/practice/part_data_table/yyyymmdd=20220926
-rwxr-xr-x   1 kagasan supergroup        666 2022-10-30 14:53 /test_dir/practice/part_data_table/yyyymmdd=20220926/000000_0
drwxr-xr-x   - kagasan supergroup          0 2022-10-30 14:54 /test_dir/practice/part_data_table/yyyymmdd=20221001
-rwxr-xr-x   1 kagasan supergroup        757 2022-10-30 14:54 /test_dir/practice/part_data_table/yyyymmdd=20221001/000000_0
```

## 期間実行スクリプト
```
上のスクリプトは1日だけなので、期間で指定できるようにする
$ . etl_parent.sh child_query.hql 20220926 20221005 && cat out.txt
$ hadoop fs -ls -h /test_dir/practice/part_data_table/

```
実行結果
```
child_query.hql
20220926 2022年 10月 30日 日曜日 14:11:32 JST
20220927 2022年 10月 30日 日曜日 14:11:39 JST
20220928 2022年 10月 30日 日曜日 14:11:46 JST
20220929 2022年 10月 30日 日曜日 14:11:53 JST
20220930 2022年 10月 30日 日曜日 14:12:00 JST
20221001 2022年 10月 30日 日曜日 14:12:06 JST
20221002 2022年 10月 30日 日曜日 14:12:13 JST
20221003 2022年 10月 30日 日曜日 14:12:20 JST
20221004 2022年 10月 30日 日曜日 14:12:27 JST
20221005 2022年 10月 30日 日曜日 14:12:34 JST

+--------------------+
|     partition      |
+--------------------+
| yyyymmdd=20220926  |
| yyyymmdd=20220927  |
| yyyymmdd=20220928  |
| yyyymmdd=20220929  |
| yyyymmdd=20220930  |
| yyyymmdd=20221001  |
| yyyymmdd=20221002  |
| yyyymmdd=20221003  |
| yyyymmdd=20221004  |
| yyyymmdd=20221005  |
+--------------------+

+---------------------------+-----------------------------+----------------------------------+---------------------------+
| part_data_table.item_num  | part_data_table.unit_price  | part_data_table.total_price_tax  | part_data_table.yyyymmdd  |
+---------------------------+-----------------------------+----------------------------------+---------------------------+
| 5                         | 40736                       | 224048                           | 20221005                  |
| 5                         | 34143                       | 187786                           | 20221005                  |
| 1                         | 19459                       | 21404                            | 20221005                  |
| 2                         | 13564                       | 29840                            | 20221005                  |
| 5                         | 286                         | 1573                             | 20221005                  |
+---------------------------+-----------------------------+----------------------------------+---------------------------+

drwxr-xr-x   - kagasan supergroup          0 2022-10-30 14:11 /test_dir/practice/part_data_table/yyyymmdd=20220926
drwxr-xr-x   - kagasan supergroup          0 2022-10-30 14:11 /test_dir/practice/part_data_table/yyyymmdd=20220927
drwxr-xr-x   - kagasan supergroup          0 2022-10-30 14:11 /test_dir/practice/part_data_table/yyyymmdd=20220928
drwxr-xr-x   - kagasan supergroup          0 2022-10-30 14:11 /test_dir/practice/part_data_table/yyyymmdd=20220929
drwxr-xr-x   - kagasan supergroup          0 2022-10-30 14:12 /test_dir/practice/part_data_table/yyyymmdd=20220930
drwxr-xr-x   - kagasan supergroup          0 2022-10-30 14:12 /test_dir/practice/part_data_table/yyyymmdd=20221001
drwxr-xr-x   - kagasan supergroup          0 2022-10-30 14:12 /test_dir/practice/part_data_table/yyyymmdd=20221002
drwxr-xr-x   - kagasan supergroup          0 2022-10-30 14:12 /test_dir/practice/part_data_table/yyyymmdd=20221003
drwxr-xr-x   - kagasan supergroup          0 2022-10-30 14:12 /test_dir/practice/part_data_table/yyyymmdd=20221004
drwxr-xr-x   - kagasan supergroup          0 2022-10-30 14:12 /test_dir/practice/part_data_table/yyyymmdd=20221005
```



## その他検証
```
hdfs上のファイルをコピーしてテーブルコピーしてみる
重要：https://cwiki.apache.org/confluence/display/Hive/LanguageManual+DDL#LanguageManualDDL-RecoverPartitions(MSCKREPAIRTABLE)
hiveストアは各テーブルのメタストアにパーティション一覧情報を持っている。
ただしhdfs putやrmなどでパーティションファイルを操作した場合、メタストアはこの更新を認識しない。
ユーザーはコマンドでメタストアに修復を要求できる。
MSCK [REPAIR] TABLE table_name [ADD/DROP/SYNC PARTITIONS];

[REPAIR]オプション：
- オプションを付けて実行した場合、メタストア情報とHDFS間の不一致を修正できる
- オプションを付けずに実行した場合、メタストア情報とHDFS間の不一致を確認できる（？）

[ADD/DROP/SYNC PARTITIONS]オプション：
デフォルトはADD PARTITIONS
- ADD PARTITIONS、追加されたパーティションが対象となる
- DROP PARTITIONS、消されたパーティションが対象となる
- SYNC PARTITIONS、ADDとDROPの両方が対象となる

上記より、クエリ内にMSCK REPAIR TABLE test_db.copy_table;を入れてやればよい。

$ . range_copy.sh
$ . run_query.sh copy_table.hql && cat out.txt
```

実行結果
```
20220926 2022年 10月 30日 日曜日 14:59:52 JST
20220927 2022年 10月 30日 日曜日 14:59:56 JST
20220928 2022年 10月 30日 日曜日 15:00:00 JST
20220929 2022年 10月 30日 日曜日 15:00:04 JST
20220930 2022年 10月 30日 日曜日 15:00:09 JST
20221001 2022年 10月 30日 日曜日 15:00:13 JST
20221002 2022年 10月 30日 日曜日 15:00:17 JST
20221003 2022年 10月 30日 日曜日 15:00:21 JST
20221004 2022年 10月 30日 日曜日 15:00:25 JST
20221005 2022年 10月 30日 日曜日 15:00:30 JST
drwxr-xr-x   - kagasan supergroup          0 2022-10-30 14:59 /test_dir/practice/copy/yyyymmdd=20220926
-rw-r--r--   1 kagasan supergroup        666 2022-10-30 14:59 /test_dir/practice/copy/yyyymmdd=20220926/000000_0
drwxr-xr-x   - kagasan supergroup          0 2022-10-30 15:00 /test_dir/practice/copy/yyyymmdd=20220927
-rw-r--r--   1 kagasan supergroup        755 2022-10-30 15:00 /test_dir/practice/copy/yyyymmdd=20220927/000000_0
drwxr-xr-x   - kagasan supergroup          0 2022-10-30 15:00 /test_dir/practice/copy/yyyymmdd=20220928
-rw-r--r--   1 kagasan supergroup        707 2022-10-30 15:00 /test_dir/practice/copy/yyyymmdd=20220928/000000_0
drwxr-xr-x   - kagasan supergroup          0 2022-10-30 15:00 /test_dir/practice/copy/yyyymmdd=20220929
-rw-r--r--   1 kagasan supergroup        728 2022-10-30 15:00 /test_dir/practice/copy/yyyymmdd=20220929/000000_0
drwxr-xr-x   - kagasan supergroup          0 2022-10-30 15:00 /test_dir/practice/copy/yyyymmdd=20220930
-rw-r--r--   1 kagasan supergroup        712 2022-10-30 15:00 /test_dir/practice/copy/yyyymmdd=20220930/000000_0
drwxr-xr-x   - kagasan supergroup          0 2022-10-30 15:00 /test_dir/practice/copy/yyyymmdd=20221001
-rw-r--r--   1 kagasan supergroup        757 2022-10-30 15:00 /test_dir/practice/copy/yyyymmdd=20221001/000000_0
drwxr-xr-x   - kagasan supergroup          0 2022-10-30 15:00 /test_dir/practice/copy/yyyymmdd=20221002
-rw-r--r--   1 kagasan supergroup        710 2022-10-30 15:00 /test_dir/practice/copy/yyyymmdd=20221002/000000_0
drwxr-xr-x   - kagasan supergroup          0 2022-10-30 15:00 /test_dir/practice/copy/yyyymmdd=20221003
-rw-r--r--   1 kagasan supergroup        792 2022-10-30 15:00 /test_dir/practice/copy/yyyymmdd=20221003/000000_0
drwxr-xr-x   - kagasan supergroup          0 2022-10-30 15:00 /test_dir/practice/copy/yyyymmdd=20221004
-rw-r--r--   1 kagasan supergroup        530 2022-10-30 15:00 /test_dir/practice/copy/yyyymmdd=20221004/000000_0
drwxr-xr-x   - kagasan supergroup          0 2022-10-30 15:00 /test_dir/practice/copy/yyyymmdd=20221005
-rw-r--r--   1 kagasan supergroup        822 2022-10-30 15:00 /test_dir/practice/copy/yyyymmdd=20221005/000000_0
```
```
+--------------------+
|     partition      |
+--------------------+
| yyyymmdd=20220926  |
| yyyymmdd=20220927  |
| yyyymmdd=20220928  |
| yyyymmdd=20220929  |
| yyyymmdd=20220930  |
| yyyymmdd=20221001  |
| yyyymmdd=20221002  |
| yyyymmdd=20221003  |
| yyyymmdd=20221004  |
| yyyymmdd=20221005  |
+--------------------+

+-----------+------+
| yyyymmdd  | _c1  |
+-----------+------+
| 20220926  | 46   |
| 20220927  | 53   |
| 20220928  | 49   |
| 20220929  | 51   |
| 20220930  | 50   |
| 20221001  | 52   |
| 20221002  | 49   |
| 20221003  | 55   |
| 20221004  | 37   |
| 20221005  | 58   |
+-----------+------+

+----------------------+------------------------+-----------------------------+----------------------+
| copy_table.item_num  | copy_table.unit_price  | copy_table.total_price_tax  | copy_table.yyyymmdd  |
+----------------------+------------------------+-----------------------------+----------------------+
| 10                   | 24774                  | 272514                      | 20220926             |
| 6                    | 39272                  | 259195                      | 20220926             |
| 8                    | 4761                   | 41896                       | 20220926             |
| 4                    | 38631                  | 169976                      | 20220926             |
| 3                    | 21631                  | 71382                       | 20220926             |
+----------------------+------------------------+-----------------------------+----------------------+
```
