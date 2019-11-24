# get_instance_json_by_name: retrieve the aws cli json for a specific instance
function get_instance_json_by_name() {
    local function_name="get_instance_json_by_name" instance_name vpc_id target_variable_name;
    import_args "$@";
    check_required_arguments $function_name instance_name vpc_id;
    local json="$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$instance_name" "Name=vpc-id,Values=$vpc_id")";
    local instance_json="$(echo "$json" | jq -r '.Reservations[0] .Instances[0]')";
    if [ -n "$target_variable_name" ]; then
        eval "$target_variable_name='$instance_json'";
    else
        echo "$instance_json";
    fi;
}

# get_instance_private_ip: Get the private ip address of the instance with name '$instance_name' in vpc with id '$vpc_id'
function get_instance_private_ip() {
    local function_name="get_instance_private_ip" instance_name vpc_id target_variable_name tmp_instance_json;
    import_args "$@";
    check_required_arguments $function_name instance_name vpc_id;

    get_instance_json_by_name --instance_name "$instance_name" --vpc_id "$vpc_id" --target_variable_name tmp_instance_json;
    local result="$(echo "$tmp_instance_json" | jq -r '.PrivateIpAddress')";
    if [ -n "$target_variable_name" ]; then
        eval "$target_variable_name='$result'";
    else
        echo "$result";
    fi;
}

# get_instance_public_dns: Get the public dns address of the instance with name '$instance_name' in vpc with id '$vpc_id'
function get_instance_public_dns() {
    local function_name="get_instance_public_dns" instance_name vpc_id target_variable_name tmp_instance_json;
    import_args "$@";
    check_required_arguments $function_name instance_name vpc_id;

    get_instance_json_by_name --instance_name "$instance_name" --vpc_id "$vpc_id" --target_variable_name tmp_instance_json;
    local result="$(echo "$tmp_instance_json" | jq -r '.PublicDnsName')";
    [[ "$result" == "null" ]] && result="";

    if [ -n "$target_variable_name" ]; then
        eval "$target_variable_name='$result'";
    else
        echo "$result";
    fi;
}

# get_ami: retrieve the ami with the specified name or prefix
function get_ami() {
    local function_name="get_ami" ami_name ami_name_prefix owners="self" target_variable_name;
    import_args "$@";
    check_required_argument "$function_name" ami_name ami_name_prefix;

    if [ -n "$ami_name" -a -n "$ami_name_prefix" ]; then
        log_fatal "Either ami_name or ami_name_prefix should be past to function $function_name, not both.";
        exit 1;
    fi;

    if [ -n "$ami_name" ]; then
        local name_filter="Name=name,Values=$ami_name";
    else
        local name_filter="Name=name,Values=$ami_name_prefix"'*';
    fi;

    local ami_json="$(aws ec2 describe-images --owners $owners --filters "$name_filter" "Name=state,Values=available")";
    local ami="$(echo "$ami_json" | jq -r '.Images | sort_by(.CreationDate) | last(.[]).ImageId')";
    if [ -n "$target_variable_name" ]; then
        eval "$target_variable_name='$ami'";
    else
        echo "$ami";
    fi;
}

function get_security_group_id() {
    local function_name="get_security_group_id" security_group_name vpc_id target_variable_name tmp_security_group_id;
    import_args "$@";
    check_required_arguments "$function_name" security_group_name vpc_id;

    local json="$(aws ec2 describe-security-groups --filters "Name=group-name,Values=$security_group_name" "Name=vpc-id,Values=$vpc_id")";
    local tmp_security_group_id="$(echo "$json" | jq -r '.SecurityGroups[0].GroupId')";
    [[ "$tmp_security_group_id" == "null" ]] && tmp_security_group_id="";
    if [ -n "$target_variable_name" ]; then
        eval "$target_variable_name='$tmp_security_group_id'";
    else
        echo "$security_group_id";
    fi;
}
