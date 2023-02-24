#! /bin/bash
source paper-start.cfg
if [ $delete_world -eq 1 ]
then
    echo "delete_world = " $delete_world ", link = " $new_world_link
fi

echo "done"