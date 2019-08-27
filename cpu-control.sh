#!/bin/bash


EXPECTED_ENABLED_FRACTION=${1:-1} #TODO: validate input, should be 0..1

ENABLED_CPU_COUNT=$(nproc)
TOTAL_CPU_COUNT=$(nproc --all)

echo "Enabled CPU count: ${ENABLED_CPU_COUNT}"
echo "Total CPU count ${TOTAL_CPU_COUNT}"
echo "Enabled fraction: ${EXPECTED_ENABLED_FRACTION}"

EXPECTED_ENABLED_CPU_COUNT=$(echo "$TOTAL_CPU_COUNT * $EXPECTED_ENABLED_FRACTION / 1" | bc)

if [ "$EXPECTED_ENABLED_CPU_COUNT" -lt 1 ]
then
  EXPECTED_ENABLED_CPU_COUNT=1
fi

echo "Expected enabled CPUs ${EXPECTED_ENABLED_CPU_COUNT}"

CPU_COUNT_TO_DISABLE=0
CPU_COUNT_TO_ENABLE=0

#
# Count if script should enable or disable CPUs based on input and available CPUs
#
if [ "$ENABLED_CPU_COUNT" -eq "$EXPECTED_ENABLED_CPU_COUNT" ]
then
  echo "Enabled CPU count matches expected enabled CPU count, not doing anything"
elif [ "$ENABLED_CPU_COUNT" -gt "$EXPECTED_ENABLED_CPU_COUNT" ]
then
  CPU_COUNT_TO_DISABLE=$(($ENABLED_CPU_COUNT - $EXPECTED_ENABLED_CPU_COUNT))
  echo "Enabled CPU count is greater than expected, disabling CPUs, CPUs to disable: ${CPU_COUNT_TO_DISABLE}"
else
  CPU_COUNT_TO_ENABLE=$(($EXPECTED_ENABLED_CPU_COUNT - $ENABLED_CPU_COUNT))
  echo "Enabled CPU count is lower than expected, enabling CPUs, CPUs to enable: ${CPU_COUNT_TO_ENABLE}"
fi

echo "CPU id 0 is always enabled, you cannot disable it"

for CPU_ID in $(seq 1 $(($TOTAL_CPU_COUNT -1))); do
  #
  # Modify CPU status
  #
  CPU_PATH="/sys/devices/system/cpu/cpu${CPU_ID}/online"
  CPU_ENABLED=`cat $CPU_PATH`
  CPU_STATUS="unknown"
  if [ "$CPU_ENABLED" -eq 1 ]
  then
    CPU_STATUS="enabled"
    if [ "$CPU_COUNT_TO_DISABLE" -gt 0 ]
    then
      CPU_COUNT_TO_DISABLE=$((CPU_COUNT_TO_DISABLE - 1))
      echo 0 > "$CPU_PATH"
    fi
  else
    CPU_STATUS="disabled"
     if [ "$CPU_COUNT_TO_ENABLE" -gt 0 ]
    then
      CPU_COUNT_TO_ENABLE=$((CPU_COUNT_TO_ENABLE - 1))
      echo 1 > "$CPU_PATH"
    fi
  fi

  #
  # Report statuses after script did the work
  #
  NEW_CPU_STATUS="unknown"
  NEW_CPU_ENABLED=`cat "$CPU_PATH"`
  if [ "$NEW_CPU_ENABLED" -eq 1 ]
  then
    NEW_CPU_STATUS="enabled"
  else
    NEW_CPU_STATUS="disabled"
  fi

  echo "CPU id ${CPU_ID} was ${CPU_STATUS} and now is now ${NEW_CPU_STATUS}"
done


ENABLED_CPU_COUNT=$(nproc)
echo "Enabled CPU count after script run: ${ENABLED_CPU_COUNT}"
echo "Done"
