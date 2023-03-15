#! /bin/bash
source ./scripts/blz-start/paper-start.cfg
if [ $delete_world -eq 1 ]
then
    echo "delete_world = " $delete_world ", link = " $new_world_link
fi

echo "executing paper.jar"
java -Xms2G -Xmx4G -jar paper.jar --nogui

