
# Get the json for the vpc with tag Name=<value of variable 'vpc_name'>.
#   if the <vpc_name> was already retrieved, then get the json from the cached variable
#   otherwise get the json using the AWS CLI and cache the result
function get_vpc() {
    local function_name="get_vpc";
    check_required_variable --variable_name vpc_name;

    local cache_variable_name="vpc_json_${vpc_name//-/_}";
    local cached_value="${!cache_variable_name}";

    if [ -n "$cached_value" ]; then
        #log_error "Returning cached vpc_id value '$cached_value'.";
        echo "$cached_value";
        return;
    fi;

    local vpc_json="$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$vpc_name" | jq -r ".Vpcs[0]")";
    eval "$cache_variable_name='$vpc_json'";
    echo "$vpc_json";
}

# Get the vpc_id for VPC <vpc_name> using function get_vpc()
function get_vpc_id() {
    local vpc_id="$(get_vpc | jq -r ".VpcId")";
    echo "$vpc_id"; 
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

function get_security_group_id() {
    local function_name="get_security_group_id";
    import_args "$@";
    check_required_arguments "$function_name" security_group_name;

    local json="$(aws ec2 describe-security-groups --filters "Name=group-name,Values=$security_group_name" "Name=vpc-id,Values=$(get_vpc_id)")";
    local security_group_id="$(echo "$json" | jq -r '.SecurityGroups[0].GroupId')";
    echo "$(clear_if_null $security_group_id)";
}

function get_subnet_id() {
    local function_name="get_subnet_id" subnet_name;
    import_args "$@";
    check_required_arguments "$function_name" subnet_name;
    local vpc_id="$(get_vpc_id)";
    local json="$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=$subnet_name" "Name=vpc-id,Values=$vpc_id")";
    local subnet_id="$(echo "$json" | jq -r '.Subnets[0].SubnetId')";
    echo "$(clear_if_null $subnet_id)";
}


