#!/bin/sh


usage() {
    echo "Usage:"
    #echo "$0 build [service]  - build docker images"
    echo "$0 start            - start services defined in docker-util.conf"
    echo "$0 stop             - stop all services"
    #echo "$0 clean-network    - remove networks with name epa-*"
    #echo "$0 clean-volume     - remove volumes with name epa-*"
}




_get_enabled_stack() {
    compose_files=$(find . -name docker-compose.yaml)
    for f in $compose_files
    do
        enabled=$(yq read $f x-settings.deploy.enable)
        priority=$(yq read $f x-settings.deploy.priority)
        if $enabled
        then
            echo "$priority:$f"
        fi
    done | sort -n $@
}


start_services() {
    DEPLOY=${1:-"staging"}
    
    echo "Start stacks for [[ ${DEPLOY} ]] ..."
    echo

    stacks=$(_get_enabled_stack)
    for line in $stacks
    do
        compose_file=$(echo $line | cut -f 2 -d ":")
        stack_name=$(yq read $compose_file x-settings.deploy.stack_name)
        echo "Starting ${stack_name}"
        if [ $DEPLOY = "dev" ]
        then
            echo "no dev option...."
            #d=$(dirname $compose_file)
            #f=$(basename -s .yaml $compose_file)
            #dev_file="$d/$f.override.yml"
            #docker stack deploy -c $compose_file -c $dev_file $stack_name
        else
            docker stack deploy -c $compose_file $stack_name && echo "...ok"
        fi
        echo
    done
}

stop_services() {
    DEPLOY=${1:-"staging"}
    echo "Stop stacks for [[ ${DEPLOY} ]] ..."
    echo

    stacks=$(_get_enabled_stack -r)
    for line in $stacks
    do
        compose_file=$(echo $line | cut -f 2 -d ":")
        stack_name=$(yq read $compose_file x-settings.deploy.stack_name)
        echo "Stoping ${stack_name}"
        docker stack rm $stack_name && echo "...ok"
        echo
    done
}



key="$1"

case $key in
#build)
#    shift
#    build_docker_image $@
#    exit
#    ;;
start)
    shift
    start_services $@
    exit
    ;;
stop)
    shift
    stop_services
    exit
    ;;
restart)
    shift
    stop_services
    sleep 30s 
    start_services $@
    exit
    ;;
#clean-network)
#    clean_network
#    exit
#    ;;
#clean-volume)
#    clean_volume
#    exit
#    ;;
*)    # unknown option
    usage
    exit 1
    ;;
esac

usage

