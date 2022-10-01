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
  # git prompt
  if [ -e $(brew --prefix)/opt/zsh-git-prompt/zshrc.sh ]; then
    source $(brew --prefix)/opt/zsh-git-prompt/zshrc.sh
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

# python で python3 を実行できるようにうする
## git_super_status に python コマンドが必要
if type brew &>/dev/null && type $(brew --prefix)/bin/python3 &>/dev/null; then
  alias python="$(brew --prefix)/bin/python3"
  alias pip="$(brew --prefix)/bin/pip3"
else
  alias python="/usr/bin/python3"
  alias pip="/usr/bin/pip3"
fi

# PROMPT
# https://zenn.dev/sprout2000/articles/bd1fac2f3f83bc

add_newline() {
  if [[ -z $PS1_NEWLINE_LOGIN ]]; then
    PS1_NEWLINE_LOGIN=true
  else
    printf '\n'
  fi
}

git_prompt() {
  if [ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" = true ]; then
    PROMPT="%F{034}%n%f:%F{037}%~%f $(git_super_status) "$'\n'"%# "
  else
    PROMPT="%F{034}%n%f:%F{037}%~%f "$'\n'"%# "
  fi
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
