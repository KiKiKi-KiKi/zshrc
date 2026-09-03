ZLE_REMOVE_SUFFIX_CHARS=$''
zstyle ":completion:*:commands" rehash 1

# カラーモジュールの有効化
autoload -Uz colors && colors

typeset -U path PATH
path=(
  /opt/homebrew/bin(N-/)
  /opt/homebrew/sbin(N-/)
  /usr/bin
  /usr/sbin
  /bin
  /sbin
  /usr/local/bin(N-/)
  /usr/local/sbin(N-/)
  /Library/Apple/usr/bin
)

if type brew &>/dev/null; then
  if [ -e $(brew --prefix)/share/zsh-completions ]; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
    autoload -Uz compinit && compinit
  fi
  if [ -e $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  fi
fi

# 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# 補完候補一覧をカラー表示
autoload colors
zstyle ':completion:*' list-colors ''

# 補完候補を詰めて表示
setopt list_packed

# コマンドのスペルを訂正
setopt correct

# ?, &, * でエラーにならないようにする
setopt nonomatch

# PROMPT
# https://zenn.dev/sprout2000/articles/bd1fac2f3f83bc

# Git ブランチ表示（zsh 標準の vcs_info を使用、Python 不要）
setopt PROMPT_SUBST
autoload -Uz vcs_info
zstyle ':vcs_info:git:*' actionformats ' %F{033}[%b|%a]%f'
zstyle ':vcs_info:git:*' formats ' %F{033}[%b]%f'

# git 変更内容を表示する場合
# ※ プロンプト表示のたびにリポジトリを走査するので、巨大リポジトリでは遅くなることがあります。
# zstyle ':vcs_info:git:*' check-for-changes true
# zstyle ':vcs_info:git:*' stagedstr '+'      # index に変更あり → %c に入る
# zstyle ':vcs_info:git:*' unstagedstr '*'    # 作業ツリーに変更あり → %u に入る
# zstyle ':vcs_info:git:*' formats ' %F{033}[%b%c%u]%f'

## %m = misc （フックで ahead/behind を出力）
# zstyle ':vcs_info:git:*' formats ' %F{033}[%b%c%u]%f%m'
# zstyle ':vcs_info:git:*' actionformats ' %F{033}[%b|%a%c%u]%f%m'
# zstyle ':vcs_info:git*+set-message:*' hooks git-aheadbehind

# ahead/behind を出力 する hooks
# +vi-git-aheadbehind() {
#   local ahead behind
#   # upstream 未設定・リモートなしのときは何も出さない
#   ahead=$(command git rev-list --count @{upstream}..HEAD 2>/dev/null) || return
#   behind=$(command git rev-list --count HEAD..@{upstream} 2>/dev/null) || return
#   (( ahead ))  && hook_com[misc]+="%F{cyan}↑${ahead}%f"
#   (( behind )) && hook_com[misc]+="%F{magenta}↓${behind}%f"
# }

add_newline() {
  if [[ -z $PS1_NEWLINE_LOGIN ]]; then
    PS1_NEWLINE_LOGIN=true
  else
    printf '\n'
  fi
}

git_prompt() {
  vcs_info
  PROMPT="%F{034}%n%f:%F{037}%~%f\${vcs_info_msg_0_} "$'\n'"%# "
}

precmd() {
  add_newline
  git_prompt
}

# 解凍時に .DS_Store を作成しない
tgz() {
  if [ $# -lt 2 ]; then
    echo "Usage: tgz DIST SOURCE"
  else
    xattr -rc ${@:2} && \
    env COPYFILE_DISABLE=1 tar zcvf $1 --exclude=".DS_Store" ${@:2}
  fi
}

# alias
alias ls="ls -FG"
alias la="ls -a"
alias ll='ls -al'

# cd ~/Documents/
alias d='cd ~/Documents/'

