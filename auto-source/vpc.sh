
# Get the json for the vpc with tag Name=<value of variable 'vpc_name'>.
#   if the <vpc_name> was already retrieved, then get the json from the cached variable
#   otherwise get the json using the AWS CLI and cache the result
# Call this function with argument 'target_variable_name' to avoid the need of running it in a sub-shell.
function get_vpc() {
    local function_name="get_vpc" vpc_name target_variable_name vpc_json fail_if_not_found="true";
    import_args "$@";
    check_required_arguments $function_name vpc_name;

    if [ -n "$target_variable_name" ]; then
        local cache_variable_name="$target_variable_name";
    else
        cache_variable_name="vpc_json_${vpc_name//[-.]/_}";
    fi;
    local cached_value="${!cache_variable_name}";

    if [ -n "$cached_value" ]; then
        #log_error "Returning cached vpc_id value '$cached_value'.";
        vpc_json="$cached_value";
    else
        vpc_json="$(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$vpc_name" | jq -r ".Vpcs[0]")";
        [[ "$vpc_json" == "null" ]] && vpc_json="";
    fi;

    if [ -z "$vpc_json" -a "$fail_if_not_found" == "true" ]; then
        log_warn "No VPC with name $vpc_name found. This is normal in case the environment was not yet created.";
        return;
    fi;
    eval "$cache_variable_name='$vpc_json'";
    if [ -z "$target_variable_name" ]; then
        echo "$vpc_json";
    fi;
}

# Get the vpc_id for VPC <vpc_name> using function get_vpc()
# Call this function with argument 'target_variable_name' to avoid the need of running it in a sub-shell.
function get_vpc_id() {
    local function_name="get_vpc_id" vpc_name target_variable_name temp_var tmp_vpc_id fail_if_not_found="true";
    import_args "$@";
    check_required_arguments $function_name vpc_name;
    get_vpc --vpc_name "$vpc_name" --target_variable_name "tmp_vpc_id" --fail_if_not_found "$fail_if_not_found";

    tmp_vpc_id="$(echo "$tmp_vpc_id" | jq -r ".VpcId")";
    [[ "$tmp_vpc_id" == "null" ]] && tmp_vpc_id="";

    if [ -n "$target_variable_name" ]; then
        eval "$target_variable_name='$tmp_vpc_id'";
    else
        echo "$tmp_vpc_id";
    fi;
}

function get_subnet_id() {
    local function_name="get_subnet_id" subnet_name target_variable_name vpc_id fail_if_not_found="true" tmp_subnet_id;
    import_args "$@";
    check_required_arguments "$function_name" subnet_name vpc_id;
    local json="$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=$subnet_name" "Name=vpc-id,Values=$vpc_id")";
    tmp_subnet_id="$(echo "$json" | jq -r '.Subnets[0].SubnetId')";

    [[ "$tmp_subnet_id" == "null" ]] && tmp_subnet_id="";

    if [ -z "$tmp_subnet_id" -a "$fail_if_not_found" == "true" ]; then
        log_error "No subnet with name $subnet_name in VPC $vpc_id found.";
        exit 1;
    fi;

    if [ -n "$target_variable_name" ]; then
        eval "$target_variable_name='$tmp_subnet_id'";
    else
        echo "$subnet_id";
    fi;
}


