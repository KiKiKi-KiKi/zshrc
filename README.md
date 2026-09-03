# :gear: Zsh setting

## :gear: Config

```sh
$ touch ~/.zshrc
```

## 1. Suggestion

### brew install zsh-completions

補完の強化  
[zsh-completions](https://github.com/zsh-users/zsh-completions)

install

```sh
$ brew install zsh-completions
```

`~/.zshrc`

```config
if type brew &>/dev/null; then
  if [ -e $(brew --prefix)/share/zsh-completions ]; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
    autoload -Uz compinit && compinit
  fi
fi
```

```sh
$ chmod -R go-w '/opt/homebrew/share/zsh'
$ source ~/.zshrc
$ rm -f ~/.zcompdump; compinit
```

コマンド入力中に `TAB` を押すとサジェストが表示されるようになる

### zsh-autosuggestions

ターミナルのコマンド履歴に基づいてコマンド候補を表示、入力補完もしてくれるプラグイン  
[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)

install

```sh
$ brew install zsh-autosuggestions
```

`~/.zshrc`

```config
if type brew &>/dev/null; then
  if [ -e $(brew --prefix)/share/zsh-completions ]; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
    autoload -Uz compinit && compinit
  fi
  if [ -e $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  fi
fi
```

#### Other suggestion settings

```config
# ~/.zshrc

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
```

## 2. Prompt display

現在のプロンプトの表示設定を確認

```sh
% echo $PROMPT
```

### Customize Prompt

#### カラーモジュールの有効化

`~/.zshrc`

```config
autoload -Uz colors && colors
```

#### プロンプトの表示設定

cf. https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html

###### プロンプトの表示・カラー設定は次の構文

```config
%F{COLOR}<色をつける文字>%f
```

`%F` 〜 `%f` に挟まれた文字に `{COLOR}` の色がつく

`~/.zshrc`

```config
# User名: ~から始まるフルパス 改行
PROMPT="%n:%~ "$'\n'"%# "
```

- `%n` … `$USERNAME`
- `%~` … `$HOME` を `~` にしたフルパスを表示 <small>`~` 始まりのフルパス</small>
- `"$'\n'"` … 行末で改行
- `%#` … シェルが特権付きで実行されている場合は '#' 、そうでない場合は '%' を表示

:point_down: カラー設定を追加

```sh
PROMPT="%F{034}%n%f:%F{037}%~%f "$'\n'"%# "
```

#### Show git branch in prompt（vcs_info）

追加パッケージや Python は不要。zsh 標準の `vcs_info` でブランチ名を表示する。

cf. https://zsh.sourceforge.io/Doc/Release/User-Contributions.html#Version-Control-Information

`~/.zshrc`

```config
setopt PROMPT_SUBST
autoload -Uz vcs_info
zstyle ':vcs_info:git:*' actionformats ' %F{033}[%b|%a]%f'
zstyle ':vcs_info:git:*' formats ' %F{033}[%b]%f'

git_prompt() {
  vcs_info
  PROMPT="%F{034}%n%f:%F{037}%~%f\${vcs_info_msg_0_} "$'\n'"%# "
}

precmd() {
  add_newline
  git_prompt
}
```

- `%b` … ブランチ名
- `%a` … rebase / merge などのアクション名
- `\${vcs_info_msg_0_}` … `PROMPT_SUBST` により展開される（`vcs_info` の結果）

表示例: `user:~/project [main]`

##### （任意）変更の有無を表示

プロンプト表示のたびにリポジトリを走査するため、巨大リポジトリでは遅くなることがある。

有効にするときは、上の `formats` / `actionformats` をコメントアウトし、次を有効にする。

```config
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr '+'      # index に変更あり → %c
zstyle ':vcs_info:git:*' unstagedstr '*'    # 作業ツリーに変更あり → %u
zstyle ':vcs_info:git:*' formats ' %F{033}[%b%c%u]%f'
zstyle ':vcs_info:git:*' actionformats ' %F{033}[%b|%a%c%u]%f'
```

表示例: ` [main+*]`

##### （任意）ahead / behind を表示

`vcs_info` に組み込みはないため、フックで `hook_com[misc]` を埋め `%m` に出す。  
`%m` は `%F{033}...%f` の外に置き、↑↓ の色が効くようにする。

```config
zstyle ':vcs_info:git:*' formats ' %F{033}[%b%c%u]%f%m'
zstyle ':vcs_info:git:*' actionformats ' %F{033}[%b|%a%c%u]%f%m'
zstyle ':vcs_info:git*+set-message:*' hooks git-aheadbehind

+vi-git-aheadbehind() {
  local ahead behind
  # upstream 未設定・リモートなしのときは何も出さない
  ahead=$(command git rev-list --count @{upstream}..HEAD 2>/dev/null) || return
  behind=$(command git rev-list --count HEAD..@{upstream} 2>/dev/null) || return
  (( ahead ))  && hook_com[misc]+="%F{cyan}↑${ahead}%f"
  (( behind )) && hook_com[misc]+="%F{magenta}↓${behind}%f"
}
```

表示例: ` [main]↑1↓2`

## 3. Add newline after command

`~/.zshrc`

```config
add_newline() {
  if [[ -z $PS1_NEWLINE_LOGIN ]]; then
    PS1_NEWLINE_LOGIN=true
  else
    printf '\n'
  fi
}

precmd() {
  add_newline
  git_prompt
}
```

## 4. Create alias

`ll` コマンドが使いたいのでエイリアスとして設定する  
`~/.zshrc`

```config
# alias
alias ls="ls -FG"
alias la="ls -a"
alias ll='ls -al'

# cd ~/Documents/
alias d='cd ~/Documents/'
```

---

#### :note: Reference

- https://zenn.dev/sprout2000/articles/bd1fac2f3f83bc
- https://zsh.sourceforge.io/Doc/Release/User-Contributions.html#Version-Control-Information
- https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html
- https://qiita.com/ryamate/items/075c34fcf29d0889c15a
