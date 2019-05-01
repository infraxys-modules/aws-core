# get_instance_json_by_name: retrieve the aws cli json for a specific instance
function get_instance_json_by_name() {
    local function_name="get_instance_json_by_name" instance_name vpc_id 
    import_args "$@";
    check_required_arguments $function_name instance_name vpc_id;
    local json="$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$instance_name" "Name=vpc-id,Values=$vpc_id")";
    local instance_json="$(echo "$json" | jq -r '.Reservations[0] .Instances[0]')";
    echo "$instance_json";
}

# get_instance_private_ip: Get the private ip address of the instance with name '$instance_name' and in the current vpc
function get_instance_private_ip() {
    import_args "$@"; # allow to override variables
    local instance_json="$(get_instance_json_by_name --instance_name "$instance_name" --vpc_id "$(get_vpc_id)")";
    local result="$(echo "$instance_json" | jq -r '.PrivateIpAddress')";
    echo "$result";
}

# get_ami: retrieve the ami with the specified name or prefix
function get_ami() {
    local function_name="get_ami" ami_name ami_name_prefix owners="self";
    import_args "$@";
    check_required_argument "$function_name" ami_name ami_name_prefix;

    if [ -n "$ami_name" -a -n "$ami_name_prefix" ]; then
        log_fatal "Either ami_name or ami_name_prefix should be past to function $function_name, not both.";
    fi;

    if [ -n "$ami_name" ]; then
        local name_filter="Name=name,Values=$ami_name";
    else
        local name_filter="Name=name,Values=$ami_name_prefix"'*';
    fi;

    local ami_json="$(aws ec2 describe-images --owners $owners --filters "$name_filter" "Name=state,Values=available")";
    local ami="$(echo "$ami_json" | jq -r '.Images | sort_by(.CreationDate) | last(.[]).ImageId')";
    echo "$ami";
}

function get_security_group_id() {
    local function_name="get_security_group_id";
    import_args "$@";
    check_required_arguments "$function_name" security_group_name;

    local json="$(aws ec2 describe-security-groups --filters "Name=group-name,Values=$security_group_name" "Name=vpc-id,Values=$(get_vpc_id)")";
    local security_group_id="$(echo "$json" | jq -r '.SecurityGroups[0].GroupId')";
    echo "$(clear_if_null $security_group_id)";
}
