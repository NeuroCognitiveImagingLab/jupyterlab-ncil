#!/bin/bash

if [ ! -L "/home/$NB_USER/science" ] ; then
    # mkdir -p /home/$NB_USER
    ln -s /ssd-raid /home/$NB_USER/science
fi
