#!/usr/local/bin/bash

set -eu

#PROJECT=google-compute-engine-oslogin
PROJECT=py-google-compute-engine

PORT_PATH=/usr/ports/sysutils/${PROJECT}
PROJECT_PATH=/home/koike/compute-image-packages

if [[ $PROJECT == "google-compute-engine-oslogin" ]]; then
	PROJECT_PATH=${PROJECT_PATH}/google_compute_engine_oslogin
fi

cd ${PROJECT_PATH}
GTAG=$(git describe --abbrev=0 --tags)
echo "Update patches against git tag ${GTAG}"
CHANGES=$(git diff --relative --name-only ${GTAG} HEAD)
echo "Modified files:"
echo "${CHANGES}"
echo ""

if [[ $PROJECT == "google-compute-engine-oslogin" ]]; then
	V_MAJOR=$(grep MAJOR ${PROJECT_PATH}/Makefile | grep -o [0-9])
	V_MINOR=$(grep MINOR ${PROJECT_PATH}/Makefile | grep -o [0-9])
	V_REVISION=$(grep REVISION ${PROJECT_PATH}/Makefile | grep -o [0-9])
	PORT_VERSION=${V_MAJOR}.${V_MINOR}.${V_REVISION}
else
	PORT_VERSION=$(grep -o [0-9].[0-9].[0-9] ${PROJECT_PATH}/setup.py)
fi

echo "Updating to version ${PORT_VERSION}"
sed -i -e "s/[0-9]\.[0-9]\.[0-9]/${PORT_VERSION}/" ${PORT_PATH}/Makefile

echo "Updating distinfo"
cd ${PORT_PATH}
make makesum

echo "Removing old patches"
rm -f ${PORT_PATH}/files/patch-*

echo "Generating new patches"
make clean
make extract
make patch
WORK_DIR=$(make -V WRKSRC)
echo $WORK_DIR

for file in ${CHANGES}; do
	mv ${WORK_DIR}/${file} ${WORK_DIR}/${file}.orig
	cp ${PROJECT_PATH}/${file} ${WORK_DIR}/${file}
done
make makepatch

echo ""
echo "DONE"
