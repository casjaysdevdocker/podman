#!/usr/bin/env bash
# shellcheck shell=bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version           :  202210131502-git
# @@Author           :  Jason Hempstead
# @@Contact          :  jason@casjaysdev.com
# @@License          :  WTFPL
# @@ReadME           :  entrypoint-podman.sh --help
# @@Copyright        :  Copyright: (c) 2022 Jason Hempstead, Casjays Developments
# @@Created          :  Thursday, Oct 13, 2022 15:02 EDT
# @@File             :  entrypoint-podman.sh
# @@Description      :
# @@Changelog        :  New script
# @@TODO             :  Better documentation
# @@Other            :
# @@Resource         :
# @@Terminal App     :  no
# @@sudo/root        :  no
# @@Template         :  other/docker-entrypoint
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set bash options
[ -n "$DEBUG" ] && set -x
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
APPNAME="$(basename "$0" 2>/dev/null)"
VERSION="202210131502-git"
HOME="${USER_HOME:-$HOME}"
USER="${SUDO_USER:-$USER}"
RUN_USER="${SUDO_USER:-$USER}"
SCRIPT_SRC_DIR="${BASH_SOURCE%/*}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set functions
__find() { find "$1" -mindepth 1 -type f,d 2>/dev/null | grep '^' || return 10; }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
__start_shell() {
  local l="$(which zsh || which bash || which sh || echo 'false')"
  echo "$shell"
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
__exec_command() {
  local exitCode=0
  local cmd="${*:-$(__start_shell) -l}"
  echo "Executing command: $cmd"
  eval $cmd || exitCode=10
  [ "$exitCode" = 0 ] || exitCode=10
  return ${exitCode:-$?}
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Functions
__heath_check() {
  local status=0
  #curl -q -LSsf -o /dev/null -s -w "200" "http://localhost/server-health" || status=$(($status + 1))
  echo "$(uname -s) $(uname -m) is running"
  return ${status:-$?}
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Define default variables - do not change these - redifine with -e or set under Additional
LANG="${LANG:-C.UTF-8}"
TZ="${TZ:-America/New_York}"
DOMANNAME="${DOMANNAME:-}"
HOSTNAME="${HOSTNAME:-casjaysdev-bin}"
HOSTADMIN="${HOSTADMIN:-root@${DOMANNAME:-$HOSTNAME}}"
SSL_ENABLED="${SSL_ENABLED:-false}"
SSL_DIR="${SSL_DIR:-/config/ssl}"
SSL_CA="${SSL_CA:-$SSL_DIR/ca.crt}"
SSL_KEY="${SSL_KEY:-$SSL_DIR/server.key}"
SSL_CERT="${SSL_CERT:-$SSL_DIR/server.crt}"
HTTP_PORT="${HTTP_PORT:-80}"
HTTPS_PORT="${HTTPS_PORT:-443}"
SERVICE_PORT="${SERVICE_PORT:-}"
LOCAL_BIN_DIR="${LOCAL_BIN_DIR:-/usr/local/bin}"
DEFAULT_CONF_DIR="${DEFAULT_CONF_DIR:-/usr/local/share/template-files/config/defaults}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Additional variables and variable overrides

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# export variables
export MY_VAR
export LANG TZ DOMANNAME HOSTNAME HOSTADMIN SSL_ENABLED SSL_DIR SSL_CA
export SSL_KEY SSL_DIR HTTP_PORT HTTPS_PORT LOCAL_BIN_DIR DEFAULT_CONF_DIR
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# import variables from file
[ -f "/root/env.sh" ] && . "/root/env.sh"
[ -f "/config/env.sh" ] && "/config/env.sh"
[ -f "/config/.env.sh" ] && . "/config/.env.sh"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set timezone
[ -n "${TZ}" ] && echo "${TZ}" >"/etc/timezone"
[ -f "/usr/share/zoneinfo/${TZ}" ] && ln -sf "/usr/share/zoneinfo/${TZ}" "/etc/localtime"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set hostname
if [ -n "${HOSTNAME}" ]; then
  echo "${HOSTNAME}" >"/etc/hostname"
  echo "127.0.0.1 ${HOSTNAME} localhost ${HOSTNAME}.local" >"/etc/hosts"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Delete any gitkeep files
[ -d "/data" ] && rm -Rf "/data/.gitkeep" "/data"/*/*.gitkeep
[ -d "/config" ] && rm -Rf "/config/.gitkeep" "/data"/*/*.gitkeep
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Setup bin directory
if [ -d "/config/bin" ]; then
  for bin in /config/bin/*; do
    name="$(basename "$bin")"
    ln -sf "$bin" "/usr/local/bin/$name"
  done
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Create directories
[ -d "/etc/ssl" ] || mkdir -p "/etc/ssl"
[ -d "/usr/local/bin" ] && rm -Rf "/usr/local/bin/.gitkeep"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ "$SSL_ENABLED" = "true" ] || [ "$SSL_ENABLED" = "yes" ]; then
  if [ -f "/config/ssl/server.crt" ] && [ -f "/config/ssl/server.key" ]; then
    export SSL_ENABLED="true"
    if [ -n "$SSL_CA" ] && [ -f "$SSL_CA" ]; then
      mkdir -p "/etc/ssl/certs"
      cat "$SSL_CA" >>"/etc/ssl/certs/ca-certificates.crt"
    fi
  else
    [ -d "$SSL_DIR" ] || mkdir -p "$SSL_DIR"
    create-ssl-cert
  fi
  type update-ca-certificates &>/dev/null && update-ca-certificates
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ -f "$SSL_CA" ] && cp -Rfv "$SSL_CA" "/etc/ssl/ca.crt"
[ -f "$SSL_KEY" ] && cp -Rfv "$SSL_KEY" "/etc/ssl/server.key"
[ -f "$SSL_CERT" ] && cp -Rfv "$SSL_CERT" "/etc/ssl/server.crt"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Create default config
if [ ! -e "/config/$APPNAME" ] && [ -e "$DEFAULT_CONF_DIR/$APPNAME" ]; then
  cp -Rf "$DEFAULT_CONF_DIR/$APPNAME" "/config/$APPNAME"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Create config symlinks
if [ -d "/config" ] || [ -n "$(__find "/config" 2>/dev/null)" ]; then
  for conf in /config/*; do
    if [ -e "/etc/$conf" ]; then
      rm -Rf "/etc/${conf:?}"
      ln -sf "/config/$conf" "/etc/$conf"
    fi
  done
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Additional commands

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
case "$1" in
--help) # Help message
  echo 'Docker container for '$APPNAME''
  echo "Usage: $APPNAME [healthcheck, bash, command]"
  echo "Failed command will have exit code 10"
  echo ""
  exit ${exitCode:-$?}
  ;;

healthcheck) # Docker healthcheck
  __heath_check || exitCode=10
  exit ${exitCode:-$?}
  ;;

*/bin/sh | */bin/bash | bash | shell | sh) # Launch shell
  shift 1
  __exec_command "${@:-/bin/bash}"
  exit ${exitCode:-$?}
  ;;

podman | docker)
  shift 1
  podman "$@"
  ;;

*) # Execute primary command
  if [ $# -eq 0 ]; then
    podman-tui
    exit ${exitCode:-$?}
  else
    __exec_command "$@"
    exitCode=$?
  fi
  ;;
esac
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# end of entrypoint
exit ${exitCode:-$?}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
