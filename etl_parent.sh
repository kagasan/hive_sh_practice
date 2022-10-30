hql=$1
st=$2
en=$3

echo $hql

dt=$st
while [ $dt -le $en ]
do
    echo $dt `date`
    . etl_child.sh $hql $dt
    dt=`date -d "$dt 1 day" '+%Y%m%d'`
done
