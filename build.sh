#!/bin/bash

PWIZ_PACKAGE_NAME=${PWIZ_PACKAGE_NAME:-pwiz}
PWIZ_VERSION=${PWIZ_VERSION:-"2.0.1905"}
PWIZ_DOWNLOAD_NAME="pwiz-bin-windows-x86-vc90-release-${PWIZ_VERSION//./_}.tar.bz2"
PWIZ_LINK="http://downloads.sourceforge.net/project/proteowizard/proteowizard/Archived%20releases/$PWIZ_VERSION/$PWIZ_DOWNLOAD_NAME"
if [ ! -e $PWIZ_DOWNLOAD_NAME ];
then
    wget $PWIZ_LINK
fi

echo "Checking for fpm..."
type fpm 
if [ "$?" != "0" ];
then 
    echo "fpm is required. Please install ruby and then fpm via `gem install fpm`"
    exit 1
fi

SCRIPT_DIR=$(readlink -f `dirname $0`)
PWIZ_PACKAGE_TYPE=${PWIZ_PACKAGE_TYPE:-deb}  # Consult fpm documentation for other options
CONTENTS_DIR=$SCRIPT_DIR/contents
mkdir -p $CONTENTS_DIR/usr/bin
PWIZ_SHARE=$CONTENTS_DIR/usr/share/pwiz
mkdir -p $PWIZ_SHARE
WINEPREFIX=${WINEPREFIX:-$HOME/.wine}
echo "Compressing wine directory - $WINEPREFIX"
tar czf $PWIZ_SHARE/wine-bundle.tar.gz -C $WINEPREFIX .
echo "Extracting proteowizard contents"
tar jxf $SCRIPT_DIR/$PWIZ_DOWNLOAD_NAME -C $PWIZ_SHARE
echo "Copying scripts into bin directory"
cp $SCRIPT_DIR/scripts/* $CONTENTS_DIR/usr/bin
chmod a+x $CONTENTS_DIR/usr/bin/*

# -a all
echo "Packaging proteowizard"
fpm -s dir -t $PWIZ_PACKAGE_TYPE -n "${PWIZ_PACKAGE_NAME}" -v $PWIZ_VERSION -C $SCRIPT_DIR/contents