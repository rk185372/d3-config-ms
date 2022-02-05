#!/bin/bash

#  copy_site_css.sh
#  D3 Banking
#
#  Created by Andrew Watt on 7/6/18.
#  Copyright © 2018 D3 Banking. All rights reserved.
#
#  Copies site.css into each webComponent's assets directory as part of the build process.
#
#  Parameters:
#  SCRIPT_INPUT_FILE_0: the path of site.css
#  SCRIPT_INPUT_FILE_1: the path of webComponents

for WEB_COMPONENT in `ls "${SCRIPT_INPUT_FILE_1}"` ; do
    echo "Copying site.css into ${WEB_COMPONENT}"
    DEST_DIR="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/webComponents/${WEB_COMPONENT}/assets/css"
    mkdir -p "${DEST_DIR}"
    cp "${SCRIPT_INPUT_FILE_0}" "${DEST_DIR}/site.css"
done
