
function clear_if_null() {
    if [ "$1" == "null" ]; then
        echo "";
    else
        echo "$1";
    fi;
}

function get_bastion_ssh_proxy_command() {
    local function_name="get_bastion_ssh_proxy_command" private_ip;
    import_args "$@";
    export bastion_dns="$(get_bastion_public_dns)";
    check_required_variables bastion_ssh_username bastion_dns private_ip;
    bastion_ssh_proxy_command="ssh -k -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ServerAliveInterval=60 -o LogLevel=ERROR -o PreferredAuthentications=publickey -i /tmp/bastion_ssh_key.pem $bastion_ssh_username@$bastion_dns -W $private_ip:22"
    echo "$bastion_ssh_proxy_command"
}

# Adding the proxy-command here makes executing functions remote fail
function get_instance_ssh_command_with_proxy_command() {
    local function_name="get_instance_ssh_command" private_ip ssh_connect_username;
    import_args "$@";
    check_required_variables ssh_connect_username private_ip;
    local proxy_command="$(get_bastion_ssh_proxy_command --private_ip $private_ip)";
    echo "ssh -i /tmp/${private_ip}.pem -t $ssh_connect_username@$private_ip -k -o ProxyCommand=\"$proxy_command -W $private_ip:22\" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ServerAliveInterval=60 -o LogLevel=ERROR -o PreferredAuthentications=publickey";
}

function get_instance_ssh_command() {
    local function_name="get_instance_ssh_command" private_ip ssh_connect_username;
    import_args "$@";
    check_required_variables ssh_connect_username private_ip;
    echo "ssh -i /tmp/${private_ip}.pem -t $ssh_connect_username@$private_ip -k -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ServerAliveInterval=60 -o LogLevel=ERROR -o PreferredAuthentications=publickey";
}