#!/bin/bash

########################################################

# Shell Script to Build Docker container for View Area #

########################################################

export RELEASE=$1

export VERTICAL=$2

export V_TAR=${RELEASE}_${VERTICAL}

export C_NAME="$1_$2_viewarea"

#export C_IMAGE="$1_$2_viewimage"

export DATE=`date +%b%d`

export HOME=/root/

export SRC=http://172.31.43.78:8080/BACKUP/VIEWAREA/${V_TAR}_view.tar.gz

export DST=/root/view_tar

portlist=`for p in $(shuf -i 2000-9999); do ss -tlnH | tr -s ' ' | cut -d" " -sf4 | grep -q "${p}$" || echo "${p}"; done | head -n 3`

export HPORT=$( echo $portlist | awk '{print $1}' )

export TPORT=$( echo $portlist | awk '{print $2}' )

export LPORT=$( echo $portlist | awk '{print $3}' )

echo "$HPORT"

echo "$TPORT"

echo "$LPORT"

if [[ $1 = "r15" || $1 = "r16" || $1 = "r17" || $1 = "r18" || $1 = "r19" || $1 = "r20" || $1 = "r21" || $1 = "201605" || $1 = "201608" || $1 = "201708" || $1 = "201711" || $1 = "201712" || $1 = "201801" || $1 = "201809" || $1 = "201812" || $1 = "201906" || $1 = "201908" || $1 = "201912" || $1 = "202001" || $1 = "202006" || $1 = "202008" || $1 = "202009" || $1 = "202011" || $1 = "202012" || $1 = "202101" || $1 = "202102" || $1 = "202103" || $1 = "202107" || $1 = "202108" || $1 = "202112" || $1 = "202202" ]];

then

cd $DST

if [[ -f "${V_TAR}_view.tar.gz" ]]

then

rm -r ${V_TAR}_view.tar.gz

else

echo "no viewtar available to remove"

fi

echo "copying a view tar from $SRC"

cd $DST

wget -q $SRC

chmod +777 ${V_TAR}_view.tar.gz

export file=`ls -l $DST/${V_TAR}_view.tar.gz`

export filedate=`echo $file | awk '{print $6$7}'`

if [[ "$filedate" -eq "$DATE" ]];

then

echo "VIEW AREA PREPARATION STARTED"

eval "$(echo "pwd")"

else

echo "Viewtar not available in current date"

rm -r ${V_TAR}_view.tar.gz

exit

fi

export tar_check=$( ls $DST | wc -l )

if [[ $tar_check -eq 1 ]]

then

chmod -R +777 $DST

echo "tar has been copied to $DST "

else

echo "no tar available"

exit

fi

export CONTAINER="$( sudo docker ps --all --quiet --filter=name="$C_NAME" )"

if [[ -n "$CONTAINER" ]];

then

echo "container exixts"

sudo docker rm -f $C_NAME

elif [[ -z "$CONTAINER" ]];

then

echo " no old conatiners available to remove"

else

exit

fi

export DANGLING=$( docker images -f "dangling=true" -q )

if [[ -n "$DANGLING" ]];

then

sudo docker rmi -f $DANGLING

elif [[ -z "$DANGLING" ]];

then

echo "No dangling images to remove"

else

exit

fi

echo "Stoping the Expired Containers"

export E_CNAME="$( docker container ls  --format "{{.ID}} {{.Status}}" | grep hours | awk -F: '{if($1 -ge 2) print $1}' | awk 'BEGIN { ORS=" " }; {print $1}' )"

echo "$E_CNAME"

if [[ -n "$E_CNAME" ]];

then

echo "expired containers to remove"

sudo docker stop $E_CNAME

elif [[ -z "$E_CNAME" ]];

then

echo "No expired containers to remove"

fi

if [[ $1 = "r18" || $1 = "r19" || $1 = "r20" || $1 = "201712" || $1 = "201801" || $1 = "201809" || $1 = "201812" || $1 = "201906" || $1 = "201908" || $1 = "201912" || $1 = "202001" || $1 = "202006" || $1 = "202008" || $1 = "202009" || $1 = "202011" || $1 = "202012" ]];

then

echo "Deploying the new container"

sudo docker run -d  --privileged=true --memory="8g" --memory-swap="8g" --name=$C_NAME -p 22 base:v2 /sbin/init

echo "New container deployed"

eval "$( echo " docker ps -as " )"

elif [[ $1 = "202101" || $1 = "202102" || $1 = "202103" || $1 = "202107" || $1 = "202108" || $1 = "202112" || $1 = "r21" || $1 = "202202" ]];

then

echo "Deploying the new container"

sudo docker run -d  --privileged=true --memory="8g" --memory-swap="8g" --name=$C_NAME -p 22 base:v3 /sbin/init

echo "New container deployed"

eval "$( echo " docker ps -as " )"

elif [[ $1 = "r15" || $1 = "r16" || $1 = "r17" || $1 = "201605" || $1 = "201608" || $1 = "201708" || $1 = "201711" ]];

then

echo "Deploying the new container"

sudo docker run -d  --privileged=true --memory="8g" --memory-swap="8g" --name=$C_NAME -p 22 base:v1 /sbin/init

echo "New container deployed"

eval "$( echo " docker ps -as " )"

else

exit

fi

echo "copying viewtar to the Running container"

sudo docker cp /$DST/${V_TAR}_view.tar.gz $C_NAME:/root

cd $DST

echo " Removing the ${V_TAR}_view.tar.gz "

sudo rm -r ${V_TAR}_view.tar.gz

echo "uncompressing the view tar"

sudo docker container exec -i -w /root $C_NAME tar -zxf /root/${V_TAR}_view.tar.gz -C /root

echo "Removing the viewtar"

sudo docker container exec -d $C_NAME sudo rm -r /root/${V_TAR}_view.tar.gz

echo "assiging a open port for H2-TRAFIX-LOCKING"

sudo docker container exec -d $1_$2_viewarea sh /root/port.sh $HPORT $TPORT $LPORT

sleep 5s

sudo docker container exec $1_$2_viewarea bash -c 'cd /root/h2/bin ; sh StopH2'

sleep 10s

sudo docker container exec $1_$2_viewarea bash -c 'cd /root/h2/bin ; sh StartH2'

sleep 10s

eval "$(echo " docker ps -as ")"

echo "VIEW_AREA PREPARATION COMPLETED"

else

exit

fi
