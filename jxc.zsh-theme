# ----------------------------------------------------------------------------
# shared dirty string for all VCS prompt segments
# ----------------------------------------------------------------------------
function dirty_str {
    echo "[dirty]"
}

# ----------------------------------------------------------------------------
# checks if current directory is part of an svn repo
# stolen from: https://github.com/robbyrussell/oh-my-zsh/blob/master/plugins/svn-fast-info/svn-fast-info.plugin.zsh
# ----------------------------------------------------------------------------
function in_svn() {
  if $(svn info >/dev/null 2>&1); then
    return 0
  fi
  return 1
}

# ----------------------------------------------------------------------------
# svn prompt
# adapted from: http://zanshin.net/2012/03/09/wordy-nerdy-zsh-prompt/
# ----------------------------------------------------------------------------
function svn_prompt_info {
    # Set up defaults
    local svn_branch=""
    local svn_repository=""
    local svn_version=""
    local svn_change=""

    if in_svn; then
        # query svn info and parse the results
        svn_branch=`svn info | grep '^URL:' | egrep -o '((tags|branches)/[^/]+|trunk).*' | sed -E -e 's/^(branches|tags)\///g'`
        svn_repository=`svn info | grep '^Repository Root:' | egrep -o '(http|https|file|svn|svn+ssh)/[^/]+' | egrep -o '[^/]+$'`
        svn_version=`svnversion -n`
        
        # this is the slowest test of the bunch
        change_count=`svn status | grep "?\|\!\|M\|A" | wc -l`
        if [ "$change_count" != "       0" ]; then
            svn_change="$ZSH_THEME_GIT_PROMPT_DIRTY"
        else
            svn_change="$ZSH_THEME_GIT_PROMPT_CLEAN"
        fi
        
        # show the results
        echo "%{$fg[blue]%}$ZSH_THEME_SVN_PROMPT_PREFIX$svn_repository/$svn_branch @ $svn_version%{$reset_color%}%{$fg[yellow]%}$svn_change$ZSH_THEME_SVN_PROMPT_SUFFIX"
        
    fi
}

# Characters
CROSS="\u2718"
LIGHTNING="\u26a1"
GEAR="\u2699"
DISAPPOINTED="ಠ_ಠ"

# Convenience methods
# some inspired from https://gist.github.com/agnoster/3712874
function location {
  echo "%{$fg[cyan]%}${PWD/#$HOME/~} "
}

function vcs_prompt {
  local git_or_svn_prompt_info="$(git_prompt_info)$(svn_prompt_info)"

  # make sure it is not empty
  if [ -n "$git_or_svn_prompt_info" ]; then
    echo "%{$fg_bold[blue]%}$git_or_svn_prompt_info%{$fg_bold[blue]%}%{$reset_color%} "
  fi
}

function username_and_host {
  local user=`whoami`
 
  if [[ "$user" != "$DEFAULT_USER" || -n "$SSH_CONNECTION" ]]; then
    echo "%{$fg[magenta]%}%n%{$reset_color%}%{$fg[cyan]%}@%{$reset_color%}%{$fg[yellow]%}%m "
  fi
}

function prompt_character {
  local prompt=""
  [[ $UID -eq 0 ]] && prompt+="%{%F{yellow}%}$LIGHTNING"
  prompt+="%{$reset_color%}$ "
  echo $prompt
}

function last_command_status {
  [[ $? -ne 0 ]] && echo "%{$fg[red]%}$DISAPPOINTED%{$reset_color%}"
}

function jobs_running {
  [[ $(jobs -l | wc -l) -gt 0 ]] && echo "%{$fg_bold[cyan]%}$GEAR%{$reset_color%}"
}

ZSH_THEME_VCS_PROMPT_PREFIX=":(%{$fg[red]%}"
ZSH_THEME_VCS_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_VCS_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}$(dirty_str)%{$reset_color%}"
ZSH_THEME_VCS_PROMPT_CLEAN="%{$fg[blue]%})"

ZSH_THEME_GIT_PROMPT_PREFIX="git$ZSH_THEME_VCS_PROMPT_PREFIX"
ZSH_THEME_GIT_PROMPT_SUFFIX="$ZSH_THEME_VCS_PROMPT_SUFFIX"
ZSH_THEME_GIT_PROMPT_DIRTY="$ZSH_THEME_VCS_PROMPT_DIRTY"
ZSH_THEME_GIT_PROMPT_CLEAN="$ZSH_THEME_VCS_PROMPT_CLEAN"

ZSH_THEME_SVN_PROMPT_PREFIX="svn$ZSH_THEME_VCS_PROMPT_PREFIX"
ZSH_THEME_SVN_PROMPT_SUFFIX="$ZSH_THEME_VCS_PROMPT_SUFFIX"
ZSH_THEME_SVN_PROMPT_DIRTY="$ZSH_THEME_VCS_PROMPT_DIRTY"
ZSH_THEME_SVN_PROMPT_CLEAN="$ZSH_THEME_VCS_PROMPT_CLEAN"

local ret_status="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ %s)"
PROMPT=$'$(location)$(vcs_prompt)$(username_and_host)\n$(prompt_character)'
RPROMPT='$(last_command_status) $(jobs_running)'
