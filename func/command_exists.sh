function command_exists() {
  type "$1" &>/dev/null
}

function all_commands_exist() {
  for cmd in "$@"; do
    if ! command_exists "$cmd"; then
      return 1
    fi
  done
  return 0
}
