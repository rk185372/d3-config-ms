#!/bin/sh

if [ $CONFIGURATION = "Debug" ] && [ $COPY_LOCAL_TRANSLATION_LAYER = "YES" ] ; then
    echo "Building Local Translation Layer"
    bash Scripts/fetch_translation_layer.sh
fi