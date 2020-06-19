#!/bin/bash
#
# Description:
#	This is a workaround for managing common content and merging them with the
#	microsite before doing a hugo build. The hugo modules should be used instead
#	but the theme "docsy" is not compatible with it at the moment. Once "docsy"
#	have been updated by the devs to work with hugo modules then we can abandon this
#	and use hugo modules instead.
#

MODE=dev
while getopts ":np" opt; do
    case ${opt} in
        n ) MODE=nelify
             ;;
        p ) MODE=nelify-preview
             ;;
        * ) exit 1
            ;;
    esac
done

PROJECT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )
BUILD_DIR=${PROJECT_DIR}/build

function fCheckout() {
    echo "[INFO] Makes sure [themes/docsy] submodule is checked out."
	cd ${PROJECT_DIR}/themes/docsy
	git submodule update -f --init --recursive
	cd ${PROJECT_DIR}
    # the npm packages doesn't seem to be need on the netify build server...must be pre-installed globally
    if [[ "${MODE}" == "dev" ]];then
        echo "[INFO] Check out required npm packages."
    	if [[ ! -d "node_modules" ]];then
    		sudo npm install -D --save autoprefixer
    		sudo npm install -D --save postcss-cli
    	fi
    fi
    echo "[INFO] Makes sure [axway-open-docs-common] submodule is checked out."
    cd ${PROJECT_DIR}/axway-open-docs-common
    git submodule update -f --init
}

function fMergeContent() {
    cd ${PROJECT_DIR}
    echo "[INFO] Put all [axway-open-docs-common] content into [build] directory."
    rsync -a axway-open-docs-common/ build --exclude .git
    if [[ $? -ne 0 ]];then
        echo "[ERROR] Looks like rsync failed!"
        exit 1
    fi
    echo "[INFO] Merging local content with the [axway-open-docs-common] files."
    echo "[INFO] Note that local content will override common content!"
    for xxx in `ls -1 | grep -v "^build$\|^build.sh$\|^axway-open-docs-common$"`;do
        echo "[INFO]    - copying [${xxx}]"
        cp -rf $xxx ${BUILD_DIR}
    done
}

function fRunHugo() {
    cd ${BUILD_DIR}
    mkdir public
    case "${MODE}" in
        "dev") 
            hugo server
            ;;
        "nelify") 
            hugo
            # Moving the "publish" directory to the ROOT of the workspace. Netlify can't publish a
            # different directory even if the "Publish directory" is changed to specify a different directory.
            mv -f ${BUILD_DIR}/public ${PROJECT_DIR}
            ;;
        "nelify-preview") 
            hugo -b $DEPLOY_PRIME_URL
            mv -f ${BUILD_DIR}/public ${PROJECT_DIR}
            ;;
    esac
}

fCheckout
fMergeContent
fRunHugo