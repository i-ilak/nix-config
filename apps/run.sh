#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Utility Functions ---

# Print a message in a specific color with bold formatting.
function log() {
    local color=$1
    shift
    echo -e "\033[1;${color}m$*\033[0m"
}

# Run a command, automatically using sudo if necessary.
function run_command() {
    local program="$1"
    shift
    local args=("$@")

    if [ "$DEBUG" = true ]; then
        log 33 "> Executing:" "$program" "${args[@]}"
    fi

    local needs_sudo=false
    if [[ $(id -u) -ne 0 ]]; then
        # Extract the basename to handle full paths like ./result/sw/bin/darwin-rebuild
        local program_basename
        program_basename=$(basename "$program")
        case "$program_basename" in
            nixos-rebuild|darwin-rebuild|chown)
                needs_sudo=true
                ;;
        esac
    fi

    if [ "$DEBUG" = true ]; then
        # Debug mode: show all output directly
        local exit_code=0
        if "$needs_sudo"; then
            sudo "$program" "${args[@]}" || exit_code=$?
        else
            "$program" "${args[@]}" || exit_code=$?
        fi

        if [[ $exit_code -ne 0 ]]; then
            log 31 "Command failed with exit code $exit_code."
            exit $exit_code
        else
            log 32 "Command completed successfully."
        fi
    else
        # Normal mode: create temporary files for output and monitoring
        local temp_output
        temp_output=$(mktemp)
        local temp_monitor
        temp_monitor=$(mktemp)

        # Start the monitoring process in background
        {
            local last_lines_count=0
            while [[ -f "$temp_monitor" ]]; do
                if [[ -f "$temp_output" ]]; then
                    local current_content
                    current_content=$(tail -5 "$temp_output" 2>/dev/null)

                    if [[ -n "$current_content" ]]; then
                        # Clear previous lines if we had any
                        if [[ $last_lines_count -gt 0 ]]; then
                            for ((i=0; i<last_lines_count; i++)); do
                                printf "\033[A\033[K"
                            done
                        fi

                        # Print current last 5 lines in grey
                        echo -e "\033[90m$current_content\033[0m"
                        last_lines_count=$(echo "$current_content" | wc -l)
                    fi
                fi
                sleep 0.1
            done

            # Clear the last displayed lines when done
            if [[ $last_lines_count -gt 0 ]]; then
                for ((i=0; i<last_lines_count; i++)); do
                    printf "\033[A\033[K"
                done
            fi
        } &
        local monitor_pid=$!

        local exit_code=0
        if "$needs_sudo"; then
            sudo "$program" "${args[@]}" > "$temp_output" 2>&1 || exit_code=$?
        else
            "$program" "${args[@]}" > "$temp_output" 2>&1 || exit_code=$?
        fi

        # Stop the monitoring process
        rm "$temp_monitor" 2>/dev/null || true
        wait $monitor_pid 2>/dev/null || true

        # If command failed, show all output
        if [[ $exit_code -ne 0 ]]; then
            log 31 "Command failed with exit code $exit_code. Full output:"
            cat "$temp_output"
            rm "$temp_output"
            exit $exit_code
        else
            # Command succeeded, cleanup
            rm "$temp_output"
        fi
    fi
}

# Get the hostname.
function get_hostname() {
    hostname
}

# Get the operating system type.
function get_os_type() {
    case "$(uname -s)" in
        Darwin)
            echo "macos"
            ;;
        Linux)
            echo "linux"
            ;;
        *)
            echo "unsupported"
            ;;
    esac
}

# --- Command Handlers ---

function handle_local_operations() {
    local build_flag=$1
    local switch_flag=$2
    local clean_flag=$3

    local hostname
    hostname=$(get_hostname)
    local os_type
    os_type=$(get_os_type)
    local arch
    arch=$(uname -m)

    if [ "$DEBUG" = true ]; then
        log 33 "Starting local setup for" "$os_type ($arch)" "on host:" "$hostname"
    fi

    case "$os_type" in
        macos)
            if [ "$build_flag" = true ]; then
                if [ "$DEBUG" = true ]; then
                    log 33 "Building flake..."
                fi
                run_command nix "--extra-experimental-features" "nix-command flakes" "build" ".#darwinConfigurations.$hostname.system"
            fi
            if [ "$switch_flag" = true ]; then
                if [ "$DEBUG" = true ]; then
                    log 33 "Switching to new generation..."
                fi
                run_command "./result/sw/bin/darwin-rebuild" "switch" "--flake" ".#$hostname"
            fi
            if [ "$clean_flag" = true ]; then
                if [ "$DEBUG" = true ]; then
                    log 33 "Cleaning up ./result link..."
                fi
                if [ -L "./result" ]; then
                    rm "./result"
                fi
            fi
            ;;
        linux)
            if [ -f "/etc/NIXOS" ]; then
                if [ "$DEBUG" = true ]; then
                    log 33 "\nNixOS system detected. Rebuilding..."
                fi
                if [ "$switch_flag" = true ]; then
                    run_command nixos-rebuild "switch" "--flake" ".#$hostname"
                fi
            else
                if [ "$DEBUG" = true ]; then
                    log 33 "\nNon-NixOS Linux detected. Applying Home Manager..."
                fi
                if [ "$switch_flag" = true ]; then
                    run_command home-manager "switch" "--experimental-features" "nix-command flakes" "--flake" ".#$hostname"
                fi
            fi
            ;;
        *)
            log 31 "Error: Unsupported system '$os_type'. Only 'macos' and 'linux' are supported for local operations."
            exit 1
            ;;
    esac

    if [ "$DEBUG" = true ]; then
        log 32 "Local setup complete!"
    fi
}

function deploy_configuration() {
    local target_config=$1
    local secret_key_path=$2
    local ip_address=$3

    if [ "$DEBUG" = true ]; then
        log 33 "Starting remote deployment..."
    fi

    local temp_dir
    temp_dir=$(mktemp -d)
    if [ "$DEBUG" = true ]; then
        log 33 "Created temporary directory for extra files:" "$temp_dir"
    fi

    local etc_ssh_path="$temp_dir/etc/ssh"
    local persist_etc_ssh_path="$temp_dir/persist/etc/ssh"

    mkdir -p "$etc_ssh_path"
    mkdir -p "$persist_etc_ssh_path"

    if [ "$DEBUG" = true ]; then
        log 33 "\nCopying SSH host keys to temporary directory..."
    fi

    local home_dir
    home_dir=$(eval echo "~")
    local username
    username=$(whoami)

    declare -A ssh_key_map=(
        ["nixos_deploy"]="ssh_host_ed25519_key"
        ["nixos_deploy.pub"]="ssh_host_ed25519_key.pub"
    )

    for src_key in "${!ssh_key_map[@]}"; do
        local dest_key="${ssh_key_map[$src_key]}"
        local src_path="$home_dir/.ssh/$src_key"
        local dest_etc="$etc_ssh_path/$dest_key"
        local dest_persist_etc="$persist_etc_ssh_path/$dest_key"

        if [ ! -f "$src_path" ]; then
            log 31 "Error: SSH key not found at $src_path"
            exit 1
        fi

        cp "$src_path" "$dest_etc"
        cp "$src_path" "$dest_persist_etc"

        if [[ "$src_key" == *.pub ]]; then
            chmod 644 "$dest_etc" "$dest_persist_etc"
        else
            chmod 600 "$dest_etc" "$dest_persist_etc"
        fi
    done

    if [ "$DEBUG" = true ]; then
        log 33 "Setting ownership of copied SSH keys..."
    fi
    run_command chown -R "$username" "$etc_ssh_path"
    run_command chown -R "$username" "$persist_etc_ssh_path"

    if [ "$DEBUG" = true ]; then
        log 33 "Executing nixos-anywhere for deployment..."
    fi
    run_command nix "run" "github:nix-community/nixos-anywhere" "--" \
        "--flake" ".#$target_config" \
        "--build-on" "remote" \
        "--extra-files" "$temp_dir" \
        "--disk-encryption-keys" "$secret_key_path" "/tmp/secret.key" \
        "--target-host" "nixos@$ip_address"

    if [ "$DEBUG" = true ]; then
        log 32 "Remote deployment complete!"
    fi

    # Clean up temporary directory
    rm -rf "$temp_dir"
}

# --- Main Logic ---

# Default flags for the 'local' command
BUILD=true
SWITCH=true
CLEAN=true
DEBUG=false

# Parse command-line arguments
if [ "$1" == "local" ]; then
    shift
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --build)
                BUILD=$2
                shift 2
                ;;
            --switch)
                SWITCH=$2
                shift 2
                ;;
            --clean)
                CLEAN=$2
                shift 2
                ;;
            --debug)
                DEBUG=true
                shift
                ;;
            *)
                echo "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    handle_local_operations "$BUILD" "$SWITCH" "$CLEAN"

elif [ "$1" == "deploy" ]; then
    shift
    TARGET=""
    IP=""
    SECRET_KEY_PATH=""
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --target)
                TARGET=$2
                shift 2
                ;;
            --ip)
                IP=$2
                shift 2
                ;;
            --secret-key-path)
                SECRET_KEY_PATH=$2
                shift 2
                ;;
            --debug)
                DEBUG=true
                shift
                ;;
            *)
                echo "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    if [ -z "$TARGET" ] || [ -z "$IP" ] || [ -z "$SECRET_KEY_PATH" ]; then
        echo "Error: --target, --ip, and --secret-key-path are required for 'deploy' command."
        exit 1
    fi
    deploy_configuration "$TARGET" "$SECRET_KEY_PATH" "$IP"

else
    # Check for debug flag in default case
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --debug)
                DEBUG=true
                shift
                ;;
            *)
                echo "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    # Default to local operations if no command is specified, matching the Rust code
    handle_local_operations "$BUILD" "$SWITCH" "$CLEAN"
fi
