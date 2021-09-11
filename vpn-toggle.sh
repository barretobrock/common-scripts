#!/usr/bin/env bash
# Description:
#   Wireguard/Generic VPN toggle script - If connected, disconnects & v.v.
# Usage:
#   vpn-toggle wg0
#   vpn-toggle "My VPN Connection"

# Name of the config file. Defaults to wg0
CONF_NAME="${1:-wg0}"

process_ret() {
  # Processes a response from nmcli, strips whitespace
  local ret_input=${@}
  output=$(echo ${ret_input} | grep -Po '(?<=\:)\s+\w+' | sed -e 's/^[ \t]*//')
  echo ${output}
}

grab_con_info() {
  # Returns specific info relating to the connection in question
  local con_param=${1}
  echo $(process_ret $(nmcli -f ${con_param} con show "${CONF_NAME}"))
}

# Get the VPN connection type & status
CON_TYPE=$(grab_con_info connection.type)
CON_STATUS=$(grab_con_info GENERAL.STATE)

echo "Connection type: ${CON_TYPE}. Status: ${CON_STATUS}"

if [[ "${CON_STATUS}" == "activated" ]];
then
  echo "VPN already activated. Turning off..."
  if [[ "${CON_TYPE}" == "wireguard" || "${CON_TYPE}" == "" ]];
  then
    echo "Using wg-quick"
    sudo wg-quick down ${CONF_NAME}
  else
    echo "Using nmcli"
    nmcli con down id "${CONF_NAME}"
  fi
else
  echo "VPN deactivated. Turning on..."
  if [[ "${CON_TYPE}" == "wireguard" || "${CON_TYPE}" == "" ]];
  then
    echo "Using wg-quick"
    sudo wg-quick up ${CONF_NAME}
  else
    echo "Using nmcli"
    nmcli con up id "${CONF_NAME}"
  fi
fi

