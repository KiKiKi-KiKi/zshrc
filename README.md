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
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
  autoload -Uz compinit && compinit
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

```diff
if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
+ source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  autoload -Uz compinit && compinit
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

#### Show git status in prompt

cf. https://github.com/olivierverdier/zsh-git-prompt

install

```sh
% brew install zsh-git-prompt
```

`~/.zshrc`

```diff
+ source $(brew --prefix)/opt/zsh-git-prompt/zshrc.sh

- PROMPT="%n:%~ "$'\n'"%# "
+ PROMPT='%F{034}%n%f:%F{037}%~%f $(git_super_status)'
```

#### :warning: Mac OS Monterey では `python` コマンドの設定が必要

zsh-git-prompt の表示には `python` コマンドが必要だが、Mac OS Monterey は `python3` コマンドのみで `python` コマンドが無いので `python` コマンドを `python3` のエイリアスに設定する必要がある

`~/.zshrc`

```config
if type brew &>/dev/null && type $(brew --prefix)/bin/python3 &>/dev/null; then
  alias python="$(brew --prefix)/bin/python3"
  alias pip="$(brew --prefix)/bin/pip3"
else
  alias python="/usr/bin/python3"
  alias pip="/usr/bin/pip3"
fi
```

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
```

---

#### :note: Reference

- https://zenn.dev/sprout2000/articles/bd1fac2f3f83bc
- https://zenn.dev/luvmini511/articles/8d427e1faa089f
- https://issueoverflow.com/2017/03/14/how-to-display-the-repository-status-with-zsh-git-prompt/
- https://gallard316.hatenablog.com/entry/2020/11/24/185634
- https://qiita.com/ryamate/items/075c34fcf29d0889c15a
