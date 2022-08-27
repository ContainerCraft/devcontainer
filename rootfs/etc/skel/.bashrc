# .bashrc
# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi
# Uncomment the following line if you don't like systemctl's auto-paging feature:
    # using tput commands
    FGBLK=[30m # 000000
    FGRED=[31m # ff0000
    FGGRN=[32m # 00ff00
    FGYLO=[33m # ffff00
    FGBLU=[34m # 0000ff
    FGMAG=[35m # ff00ff
    FGCYN=[36m # 00ffff
    FGWHT=[37m # ffffff
    BGBLK=[40m # 000000
    BGRED=[41m # ff0000
    BGGRN=[42m # 00ff00
    BGYLO=[43m # ffff00
    BGBLU=[44m # 0000ff
    BGMAG=[45m # ff00ff
    BGCYN=[46m # 00ffff
    BGWHT=[47m # ffffff
    RESET=[m
    BOLDM=[1m
    UNDER=[4m
    REVRS=[7m
if [ 0 == 0 ]; then
  export PS1="\[[31m\]\u\[[35m\]@\[[36m\]\h \[[34m\]\W$ \[[m\]"
 else
  export PS1="\[[32m\]\u\[[35m\]@\[[36m\]\h \[[34m\]\W$ \[[m\]"
fi
# User specific environment
#if ! [[ "/root/.local/bin:/root/bin:/usr/share/Modules/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/snap/bin:/var/lib/snapd/snap/bin:/root/bin" =~ "/root/.local/bin:/root/bin:" ]]
#then
#    PATH="/root/.local/bin:/root/bin:/root/.local/bin:/root/bin:/usr/share/Modules/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/snap/bin:/var/lib/snapd/snap/bin:/root/bin"
#fi
#export PATH="/root/platform/bin:$PATH"

# User specific environment and startup programs
# Source items only for interactive sessions (Fixes qemu+ssh header size error)
case $- in *i*)
  for i in $(ls ~/.bashrc.d/ 2>/dev/null); do
    source ~/.bashrc.d/$i
  done
  for i in $(ls ~/deploy/.profile.d/ 2>/dev/null); do
    source ~/deploy/profile.d/$i
  done
esac

# Git stage/commit/push function
# Example:
#  - cd ~/Git/projectName
#  - touch 1.txt
#  - gitup add text file
# Git stage/commit/push
gitup () {

  git pull
  git_commit_msg="$@"
  git_branch=$(git branch --show-current)
  git_remote=$(git remote get-url --push origin)
  git_remote_push="$(git remote get-url --push origin | awk -F'[@]' '{print $2}')"

  cat <<EOF

  Commiting to:
    - branch:    ${git_branch}
    - remote:    ${git_remote_push}
    - message:   ${git_commit_msg}

EOF

  git stage -A
  git commit -m "${git_commit_msg}" --signoff
  git push
}

# User Alias(s)
alias quit="tmux detach"
alias ll="ls -lah"
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias cloc="git count | xargs wc -l 2>/dev/null"
alias k="kubectl"
