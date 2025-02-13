#! /usr/bin/env bash

set -e;

if [ ! "$(command -v shellcheck)" ]; then
  echo "shellcheck not installed - install it to lint bash scripts";
  echo "  - Debian: apt install shellcheck";
  echo "  - EPEL: yum -y install epel-release && yum install ShellCheck";  # cspell:words epel
  echo "  - macOS: brew install shellcheck";
  exit 1;
fi

INPUT_SHELLCHECK_OPTIONS=('--color=always' '--format=gcc');

statuscode=0;
declare -a filepaths;
shebangregex="^#! */[^ ]*/(env *)?[abk]*sh";

# cspell:words shlib zsenv
while IFS= read -r -d '' file; do
  filepaths+=("$file");
done < <(find . \
    -not \
    '(' \
      -path '*/.git/*' \
      -or -path '*/.venv/*' \
      -or -path '*/node_modules/*' \
    ')' \
    -type f \
    '(' \
      -name '*.bash' \
      -or -name '.bashrc' \
      -or -name 'bashrc' \
      -or -name '.bash_aliases' \
      -or -name '.bash_completion' \
      -or -name '.bash_login' \
      -or -name '.bash_logout' \
      -or -name '.bash_profile' \
      -or -name 'bash_profile' \
      -or -name '*.ksh' \
      -or -name 'suid_profile' \
      -or -name '*.zsh' \
      -or -name '.zlogin' \
      -or -name 'zlogin' \
      -or -name '.zlogout' \
      -or -name 'zlogout' \
      -or -name '.zprofile' \
      -or -name 'zprofile' \
      -or -name '.zsenv' \
      -or -name 'zsenv' \
      -or -name '.zshrc' \
      -or -name 'zshrc' \
      -or -name '*.sh' \
      -or -path '*/.profile' \
      -or -path '*/profile' \
      -or -name '*.shlib' \
    ')' \
    -print0);

while IFS= read -r -d '' file; do
  head -n1 "$file" | grep -Eqs "$shebangregex" || continue
  filepaths+=("$file")
done < <(find . \
  -not \
    '(' \
      -path '*/.git/*' \
      -or -path '*/.venv/*' \
      -or -path '*/node_modules/*' \
    ')' \
  -type f ! -name '*.*' -perm a+x \
  -print0)

if [[ -n "${INPUT_CHECK_TOGETHER}" ]]; then
  shellcheck "${INPUT_SHELLCHECK_OPTIONS[@]}" "${filepaths[@]}" || statuscode=$?
else
  for file in "${filepaths[@]}"; do
    shellcheck "${INPUT_SHELLCHECK_OPTIONS[@]}" "$file" || statuscode=$?
  done
fi

exit ${statuscode}
