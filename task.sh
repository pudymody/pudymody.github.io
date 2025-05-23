#!/usr/bin/env bash 

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

usage() {
  cat << EOF # remove the space between << and EOF, this is due to web plugin issue
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] cmd arg1 [arg2...]

Available cmds:

post file-name       Creates a new post with the given file-name (dont provide md extension)
stream               Creates a new stream post
serve                Serve site

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
EOF
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "$msg"
  exit "$code"
}

parse_params() {
  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) set -x ;;
    --no-color) NO_COLOR=1 ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  args=("$@")

  # check required params and arguments
  # [[ -z "${param-}" ]] && die "Missing required parameter: param"
	[[ ${#args[@]} -eq 0 ]] && usage

  return 0
}

parse_params "$@"
setup_colors

export HUGO_SECURITY_EXEC_ALLOW="^(dart-sass-embedded|go|npx|postcss|nvim)$"
export HUGO_LINKS_ENDPOINT="https://vps-3194141-x.dattaweb.com/freshrss/favs.php?format=export"

case "${args[0]}" in
	post)
		hugo new blog/$(date +%F)-"${args[1]}".md --editor nvim
	;;
	stream)
		hugo new stream/$(date +%F_%H-%M).md --editor nvim
	;;
	serve)
		hugo serve
	;;
	*)
		usage
	;;
esac
