custom_sim=`xcrun simctl list | grep ‘MultySimulator’ | awk -F’[()]’ ‘{print $2}’`
if [ ! -z “${custom_sim}” ] && [ “${TARGET_DEVICE_IDENTIFIER}” = “${custom_sim}” ]; then
/bin/sh multipleSimulatorsStartup.sh &
fi