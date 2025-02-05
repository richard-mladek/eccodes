#!/bin/sh
# (C) Copyright 2005- ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# 
# In applying this licence, ECMWF does not waive the privileges and immunities granted to it by
# virtue of its status as an intergovernmental organisation nor does it submit to any jurisdiction.
#

. ./include.ctest.sh

label="grib_check_param_concepts_test"


if [ $ECCODES_ON_WINDOWS -eq 1 ]; then
    echo "$0: This test is currently disabled on Windows"
    exit 0
fi

check_grib_defs()
{
  CHECK_DEFS=$ECCODES_DEFINITION_PATH/check_grib_defs.pl
  if [ -x "$CHECK_DEFS" ]; then
    # Now check the name.def, paramId.def, shortName.def... files
    # in the current directory
    $CHECK_DEFS
  fi
}

#
# Do various checks on the concepts files
#

# First check the GRIB2 paramId.def and shortName.def
# ----------------------------------------------------
$EXEC ${test_dir}/grib_check_param_concepts paramId $ECCODES_DEFINITION_PATH/grib2/paramId.def
datasets="ecmf uerra cerise hydro s2s tigge era6 destine era"
for a_dataset in $datasets; do
    $EXEC ${test_dir}/grib_check_param_concepts paramId $ECCODES_DEFINITION_PATH/grib2/localConcepts/$a_dataset/paramId.def
done

$EXEC ${test_dir}/grib_check_param_concepts shortName $ECCODES_DEFINITION_PATH/grib2/shortName.def
for a_dataset in $datasets; do
    $EXEC ${test_dir}/grib_check_param_concepts shortName $ECCODES_DEFINITION_PATH/grib2/localConcepts/$a_dataset/shortName.def
done

# Check WMO name.def etc
$EXEC ${test_dir}/grib_check_param_concepts name  $ECCODES_DEFINITION_PATH/grib2/name.def
$EXEC ${test_dir}/grib_check_param_concepts units $ECCODES_DEFINITION_PATH/grib2/units.def
$EXEC ${test_dir}/grib_check_param_concepts cfVarName $ECCODES_DEFINITION_PATH/grib2/cfVarName.def
$EXEC ${test_dir}/grib_check_param_concepts cfVarName $ECCODES_DEFINITION_PATH/grib2/localConcepts/ecmf/cfVarName.def


# Check the group: name.def paramId.def shortName.def units.def
# -------------------------------------------------------------
# Check whether the Test::More Perl module is available
set +e
perl -e 'use Test::More;'
status=$?
set -e
if [ $status -ne 0 ]; then
  echo "Perl Test::More not installed. Test will be skipped"
  exit 0
fi

defs_dirs="
 $ECCODES_DEFINITION_PATH/grib1
 $ECCODES_DEFINITION_PATH/grib2
 $ECCODES_DEFINITION_PATH/grib1/localConcepts/ecmf
 $ECCODES_DEFINITION_PATH/grib2/localConcepts/ecmf

 $ECCODES_DEFINITION_PATH/grib1/localConcepts/ekmi
 $ECCODES_DEFINITION_PATH/grib1/localConcepts/enmi
 $ECCODES_DEFINITION_PATH/grib1/localConcepts/lfpw
 $ECCODES_DEFINITION_PATH/grib1/localConcepts/lowm
 $ECCODES_DEFINITION_PATH/grib1/localConcepts/rjtd

 $ECCODES_DEFINITION_PATH/grib2/localConcepts/uerra
 $ECCODES_DEFINITION_PATH/grib2/localConcepts/hydro
 $ECCODES_DEFINITION_PATH/grib2/localConcepts/cerise
 $ECCODES_DEFINITION_PATH/grib2/localConcepts/tigge
 $ECCODES_DEFINITION_PATH/grib2/localConcepts/s2s
 $ECCODES_DEFINITION_PATH/grib2/localConcepts/era6
 $ECCODES_DEFINITION_PATH/grib2/localConcepts/era
 $ECCODES_DEFINITION_PATH/grib2/localConcepts/destine

 $ECCODES_DEFINITION_PATH/grib2/localConcepts/egrr
 $ECCODES_DEFINITION_PATH/grib2/localConcepts/ekmi
 $ECCODES_DEFINITION_PATH/grib2/localConcepts/eswi
 $ECCODES_DEFINITION_PATH/grib2/localConcepts/lfpw
"

for dir in $defs_dirs; do
  cd $dir
  check_grib_defs
done

cd $test_dir

# -------------------------------
echo "WMO legacy parameters..."
# -------------------------------
ECMF_DIR=$ECCODES_DEFINITION_PATH/grib2

tempDir=temp.${label}.dir
rm -fr $tempDir
mkdir -p $tempDir
cd $tempDir

# See ECC-1886 re cfVarName files
#cp $ECMF_DIR/cfName.legacy.def    cfName.def
#cp $ECMF_DIR/cfVarName.legacy.def cfVarName.def
cp $ECMF_DIR/name.legacy.def      name.def
cp $ECMF_DIR/paramId.legacy.def   paramId.def
cp $ECMF_DIR/shortName.legacy.def shortName.def
cp $ECMF_DIR/units.legacy.def     units.def
check_grib_defs
cd $test_dir
rm -fr $tempDir

# -------------------------------
echo "ECMWF legacy parameters..."
# -------------------------------
ECMF_DIR=$ECCODES_DEFINITION_PATH/grib2/localConcepts/ecmf

tempDir=temp.${label}.dir
rm -fr $tempDir
mkdir -p $tempDir
cd $tempDir
cp $ECMF_DIR/cfName.legacy.def    cfName.def
# cp $ECMF_DIR/cfVarName.legacy.def cfVarName.def
cp $ECMF_DIR/name.legacy.def      name.def
cp $ECMF_DIR/paramId.legacy.def   paramId.def
cp $ECMF_DIR/shortName.legacy.def shortName.def
cp $ECMF_DIR/units.legacy.def     units.def
check_grib_defs
cd $test_dir
rm -fr $tempDir

# -------------------------------
echo "Check duplicates"
# -------------------------------
paramIdFile=$ECCODES_DEFINITION_PATH/grib2/paramId.def
pids=$(grep "^'" $paramIdFile | awk -F"'" '{printf "%s\n", $2}')
set +e
for p in $pids; do
    # For each paramId found in the top-level WMO file, check if it also exists
    # in the ECMWF local one
    grep "'$p'"  $ECCODES_DEFINITION_PATH/grib2/localConcepts/ecmf/paramId.def
    if [ $? -ne 1 ]; then
      echo "ERROR: check paramId $p. Is it duplicated?"
      exit 1
    fi
done
set -e


cd $test_dir
rm -fr $tempDir
