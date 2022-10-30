hql='query.hql'

if [ $# -eq 1 ]; then
    hql=$1
fi
echo $hql

$HIVE_HOME/bin/beeline \
-u jdbc:hive2://localhost:10000/default \
-n `whoami` \
-f $hql \
--silent \
> out.txt