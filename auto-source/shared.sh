
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

function get_bastion_ssh_proxy_command() {
    local function_name="get_bastion_ssh_proxy_command" private_ip;
    import_args "$@";
    export bastion_dns="$(get_bastion_public_dns)";
    check_required_variables bastion_ssh_username bastion_dns private_ip;
    bastion_ssh_proxy_command="ssh -k -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ServerAliveInterval=60 -o LogLevel=ERROR -o PreferredAuthentications=publickey -i /tmp/bastion_ssh_key.pem $bastion_ssh_username@$bastion_dns -W $private_ip:22"
    echo "$bastion_ssh_proxy_command"
}

function get_bastion_public_dns() {
    check_required_variable --variable_name bastion_name;

    local cache_variable_name="bastion_public_dns_${vpc_name//-/_}";
    local cached_value="${!cache_variable_name}";

    if [ -n "$cached_value" ]; then
        log_error "Returning cached bastion_public_dns value '$cached_value'.";
        return "$cached_value";
    fi;
    local instance_json="$(get_instance_json_by_name --instance_name "$bastion_name" --vpc_id "$(get_vpc_id)")";
    local dns="$(echo "$instance_json" | jq -r '.PublicDnsName')";
    log_info_to_std_err "Using bastion host $dns";
    echo "$dns";
}


