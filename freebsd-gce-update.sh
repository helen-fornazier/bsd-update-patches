#!/usr/local/bin/bash

set -eu

PORT_PATH=/usr/ports/sysutils/py-google-compute-engine
PROJECT_PATH=/home/koike/compute-image-packages

cd ${PROJECT_PATH}
GTAG=$(git describe --abbrev=0 --tags)
echo "Update patches against git tag ${GTAG}"
CHANGES=$(git diff --name-only ${GTAG} HEAD)
echo "Modified files:"
echo "${CHANGES}"
echo ""

PORT_VERSION=$(grep -o [0-9].[0-9].[0-9] ${PROJECT_PATH}/setup.py)
echo "Updating to version ${PORT_VERSION}"
sed -i -e "s/[0-9].[0-9].[0-9]/${PORT_VERSION}/" ${PORT_PATH}/Makefile

echo "Updating distinfo"
cd ${PORT_PATH}
make makesum

echo "Removing old patches"
rm ${PORT_PATH}/files/patch-*

echo "Generating new patches"
make clean
make extract
make patch
WORK_DIR=${PORT_PATH}/work/google-compute-engine-${PORT_VERSION}

for file in ${CHANGES}; do
	mv ${WORK_DIR}/${file} ${WORK_DIR}/${file}.orig
	cp ${PROJECT_PATH}/${file} ${WORK_DIR}/${file}
done
make makepatch

echo ""
echo "DONE"
