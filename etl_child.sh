hql='query.hql'
log_date='20221001'
if [ $# -eq 1 ]; then
    hql=$1
fi
if [ $# -eq 2 ]; then
    hql=$1
    log_date=$2
fi

$HIVE_HOME/bin/beeline \
-u jdbc:hive2://localhost:10000/default \
-n `whoami` \
-f $hql \
--silent \
--hivevar log_date=$log_date \
> out.txt