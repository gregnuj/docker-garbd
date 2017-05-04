#!/bin/bash -e

if [[ -n "$DEBUG" ]]; then
  set -x
fi

# Defaults to /var/lib/mysql
function mysql_datadir(){
    if [[ -z "$1" ]]; then
        DATADIR="${DATADIR:="/var/lib/mysql"}"
    else
        DATADIR="$1"
    fi
    echo "${DATADIR}"
}

function mysql_auth(){
    USER="$(mysql_user $1)"
    PASSWORD="$(mysql_password $1)"
    echo "$USER:$PASSWORD"
}

function mysql_user(){
    if [[ -z "$1" ]]; then
        USER=${MYSQL_USER:="root"}
    else
        USER="$1"
    fi
    echo "$USER"
}

function mysql_password(){
    USER="$(mysql_user $1)"
    if [[ $USER == "root" ]]; then
        PASSWORD="${MYSQL_ROOT_PASSWORD:="${MYSQL_ROOT_PASSWORD_FILE}"}"
    elif [[ $USER == "${MYSQL_USER}" ]]; then
        PASSWORD="${MYSQL_PASSWORD:="${MYSQL_PASSWORD_FILE}"}"
    fi

    if [[ -r "$PASSWORD" ]]; then
        PASSWORD="$(cat "$PASSWORD")"        
    elif [[ -z "$PASSWORD" && -r "/var/run/secrets/$USER" ]]; then
        PASSWORD="$(cat "/var/run/secrets/${USER}")"
    elif [[ -z "$PASSWORD" ]]; then
        PASSWORD="$(echo "$USER:$MYSQL_ROOT_PASSWORD" | sha256sum | awk '{print $1}')"
    fi

    echo "${PASSWORD}"
}

function mysql_client(){
    MYSQL_CLIENT=( "mysql" )
    MYSQL_CLIENT+=( "--protocol=socket" )
    MYSQL_CLIENT+=( "--socket=/var/run/mysqld/mysqld.sock" )
    MYSQL_CLIENT+=( "-hlocalhost" )
    MYSQL_CLIENT+=( "-u$(mysql_user root)" )
    MYSQL_CLIENT+=( "-p$(mysql_password root)" )
    echo "${MYSQL_CLIENT[@]}"
}

function main(){
    case "$1" in
        -a|--auth)
            echo "$(mysql_auth $2)"
            ;;
        -d|--dir)
            echo "$(mysql_datadir $2)"
            ;;
        -p|--password)
            echo "$(mysql_password $2)"
            ;;
        -u|--user)
            echo "$(mysql_user $2)"
            ;;
    esac
}

main "$@"
