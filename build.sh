#!/bin/bash
#
# Description:
#	This is a workaround for managing common content and merging them with the
#	microsite before doing a hugo build. The hugo modules should be used instead
#	but the theme "docsy" is not compatible with it at the moment. Once "docsy"
#	have been updated by the devs to work with hugo modules then we can abandon this
#	and use hugo modules instead.
#

DEBUG=${DEBUG:-false}
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
    IFS_SAVE="${IFS}"
    IFS=$'\n'
    local axway_common_name="axway-open-docs-common"
    local _c_context
    local _c_path
    local _c_name
    local _ln_opt='-sf'
    cd ${PROJECT_DIR}
    echo "[INFO] Put all [${axway_common_name}] content into [build] directory."
    rsync -a ${axway_common_name}/ build --exclude .git
    if [[ $? -ne 0 ]];then
        echo "[ERROR] Looks like rsync failed!"
        exit 1
    fi

    if [[ "$DEBUG" == "true" ]];then
        _ln_opt='-vsf'
    fi

    # static can't be a symlink
    echo "[INFO] Merging [static] folder with [build/static/]!"
    cp -rf static ${BUILD_DIR}
    echo "[INFO] Creating symlinks for dynamic content!"
    for xxx in `ls -1 | grep -v "^build$\|^build.sh$\|^${axway_common_name}$\|^static$"`;do
        #echo "[INFO]    - processing [${xxx}]"
        # takes care of any top level files/folder only in micro site and not in axway-open-docs-common
        if [[ ! -e "${axway_common_name}/${xxx}" ]];then
            ln ${_ln_opt} $(pwd)/${xxx} ${BUILD_DIR}/${xxx}
        # takes care of all directories and files inside sub folders
        elif [[ -d "${xxx}" ]];then
            for sub_xxx in `diff -qr ${axway_common_name}/$xxx $xxx | grep -v "^Only in ${axway_common_name}[/\|:]"`;do

                _c_context=`echo ${sub_xxx} | awk '{ print $1 }'`
                if [[ "${_c_context}" == "Only" ]];then
                    _c_path=`echo ${sub_xxx} | awk '{ print $3 }' | sed -e "s|:||g"`
                    _c_name=`echo ${sub_xxx} | awk '{ print $4 }'`
                    ln ${_ln_opt} $(pwd)/${_c_path}/${_c_name} ${BUILD_DIR}/${_c_path}/${_c_name}
                else
                    #echo "[DEBUG]   - ${sub_xxx}"
                    #echo "[DEBUG]   - _c_context = ${_c_context}"
                    #exit 1
                    _c_path=`echo ${sub_xxx} | awk '{ print $4 }'`
                    ln ${_ln_opt} $(pwd)/${_c_path} ${BUILD_DIR}/${_c_path}
                fi
            done
        else
            # takes care of all top level files
            ln ${_ln_opt} $(pwd)/${xxx} ${BUILD_DIR}/${xxx}
        fi
    done
    echo "[INFO] Following symlinks were created:"
    for xxx in `find $(basename ${BUILD_DIR}) -type l`;do
        echo "[INFO]    |- ${xxx}"
    done
    echo "[INFO]"
    IFS="${IFS_SAVE}"
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