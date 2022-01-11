#!/bin/bash




########################################################

## Shell Script to Build Docker Image for View Area

#########     #        #######       ###
    #        # #       #               #
    #       #####      #######         #
    #      #     #     #         #     #
    #     #       #    #         #######

########################################################


DATE=`date +%Y.%m.%d.%H.%M`
username=manikandan59131
password=Mani@59131
DIR=/root/opt/docker
FILE=/root/opt/docker
container_name=TAFJ_VIEW_AREA
if [ -d "$DIR" ];
then
printf '%s\n' "viewarea ($DIR)"
rm -rf "$DIR"
else
echo "now no viewarea"
fi
echo "cloning a viewarea dir"
sudo git clone https://github.com/manikandan59131/view-area.git
result=$( sudo docker images -q viewarea )
if [[ -n "$result" ]]; then
echo "image exists"
sudo docker rmi -f viewarea
else
echo "No such image"
fi
echo "change the dir"

echo "delete output file"
cd /opt/docker
echo "build the docker image"
sudo docker build -t viewarea:$DATE . >> /root/opt/docker
echo "built docker images and proceeding to delete existing container"
result=$( docker ps -q -f name=viewarea )
if [[ $? -eq 0 ]]; then
echo "Container exists"
sudo docker container rm -f viewarea
echo "Deleted the existing docker container"
else
echo "No such container"
fi
echo "Deploying the updated container"
sudo docker run -itd  --name viewarea $OUTPUT
echo "Deploying the container"
