#!/usr/bin/env bash

# Dotfiles manager

IFS=$'\n'

VERSION="v0.1.0"

# check if tput exists
if ! command -v tput &>/dev/null; then
	# tput could not be found
	BOLD=""
	RESET=""
	FG_SKYBLUE=""
	FG_ORANGE=""
	BG_AQUA=""
	FG_BLACK=""
	FG_ORANGE=""
	UL=""
	RUL=""
else
	BOLD=$(tput bold)
	RESET=$(tput sgr0)
	FG_SKYBLUE=$(tput setaf 122)
	FG_ORANGE=$(tput setaf 208)
	BG_AQUA=$(tput setab 45)
	FG_BLACK=$(tput setaf 16)
	FG_ORANGE=$(tput setaf 214)
	UL=$(tput smul)
	RUL=$(tput rmul)
fi

logo() {
	# print dotman logo
	printf "${BOLD}${FG_SKYBLUE}%s\n" ""
	printf "%s\n" "                                                                          "
	printf "%s\n" " ________   _____________________________ ________    _________ _________ "
	printf "%s\n" " \______ \  \_____  \__    ___/\______   \\_____  \  /   _____//   _____/ "
	printf "%s\n" "  |    |  \  /   |   \|    |    |    |  _/ /   |   \ \_____  \ \_____  \  "
	printf "%s\n" "  |    |   \/    |    \    |    |    |   \/    |    \/        \/        \ "
	printf "%s\n" " /_______  /\_______  /____|    |______  /\_______  /_______  /_______  / "
	printf "%s\n" "         \/         \/                 \/         \/        \/        \/  "
	printf "%s\n" "                                                                          "
	printf "${RESET}\n%s" ""
}

# check if git exists
if ! command -v git &>/dev/null; then
	printf "%s\n\n" "${BOLD}${FG_SKYBLUE}${RESET}"
	echo "I can't leave without Git 😞"
	exit 1
fi

# check if stow exists
if ! command -v stow &>/dev/null; then
	printf "%s\n\n" "${BOLD}${FG_SKYBLUE}${RESET}"
	echo "I can't leave without Stow 😞"
	exit 1
fi

# function called by trap
catch_ctrl+c() {
	goodbye
	exit
}

trap 'catch_ctrl+c' SIGINT

goodbye() {
	printf "\a\n\n%s\n" "${BOLD}Thanks for using dotboss 🖖.${RESET}"
	printf "%s\n" "${BOLD}Report Bugs 🐛 @ ${UL}https://github.com/ntk148v/dotboss/issues${RUL}${RESET}"
}

intro() {
	BOSS_NAME=$LOGNAME
	printf "\n\a%s" "Hi ${BOLD}${FG_ORANGE}${BOSS_NAME}${RESET} 👋"
	logo
}

init_check() {
	# Check whether its a first time use or not
	if [[ -z ${DOT_REPO} && -z ${DOT_DEST} ]]; then
		initial_setup
		goodbye
	else
		repo_check
	fi
}

initial_setup() {
	printf "\n\n%s\n" "First time use 🔥, spend time to do a ${BOLD}dotboss setup${RESET}"
	printf "%s\n" "..................................................."
	read -p "➤ Enter dotfiles repository URL: " -r DOT_REPO
	read -p "➤ Where should I clone ${BOLD}$(basename "${DOT_REPO}")${RESET} (${HOME}/..): " -r DOT_DEST
	read -p "➤ Enter the repository remote ('origin' by default): " -r DOT_REPO_REMOTE
	read -p "➤ Enter the repository branch ('master' by default): " -r DOT_REPO_BRANCH
	DOT_DEST=${DOT_DEST:-$HOME}
	DOT_REPO_REMOTE=${DOT_REPO_REMOTE:-"origin"}
	DOT_REPO_BRANCH=${DOT_REPO_BRANCH:-"master"}

	if [[ -d "$HOME/$DOT_DEST" ]]; then
		printf "\n%s\r\n" "${BOLD}Calling 📞 Git ... ${RESET}"
		clone_dotrepo "$DOT_DEST" "$DOT_REPO" "$DOT_REPO_REMOTE" "$DOT_REPO_BRANCH"
		printf "\n%s\n" "Open a new terminal or source your shell config"
	else
		printf "\n%s" "[❌]${BOLD}$DOT_DEST${RESET} Not a Valid directory"
		exit 1
	fi
}

clone_dotrepo() {
	# clone the repo in the destination directory
	DOT_DEST=$1
	DOT_REPO=$2
	DOT_REPO_REMOTE=$3
	DOT_REPO_BRANCH=$4

	if git -C "${HOME}/${DOT_DEST}" clone "${DOT_REPO}"; then
		if [[ $DOT_REPO && $DOT_DEST ]]; then
			add_env "$DOT_REPO" "$DOT_DEST" "$DOT_REPO_REMOTE" "$DOT_REPO_BRANCH"
		fi
		printf "\n%s" "[✔️ ] dotman successfully configured"
	else
		# invalid arguments to exit, Repository Not Found
		printf "\n%s" "[❌] $DOT_REPO Unavailable. Exiting !"
		exit 1
	fi
}

add_env() {
	[[ "$DOT_DEST" && "$DOT_REPO" && "$DOT_REPO_REMOTE" && "$DOT_REPO_BRANCH" ]] && return
	# export environment variables
	printf "\n%s\n" "Exporting env variables DOT_DEST, DOT_REPO, DOT_REPO_REMOTE & DOT_REPO_BRANCH ..."

	current_shell=$(basename "$SHELL")
	if [[ $current_shell == "zsh" ]]; then
		echo "# Dotboss configs" >>"$HOME"/.zshrc
		echo "export DOT_REPO=$1 DOT_DEST=$2 DOT_REPO_REMOTE=$3 DOT_REPO_BRANCH=$4" >>"$HOME"/.zshrc
	elif [[ $current_shell == "bash" ]]; then
		# assume we have a fallback to bash
		echo "# Dotboss configs" >>"$HOME"/.bashrc
		echo "export DOT_REPO=$1 DOT_DEST=$2 DOT_REPO_REMOTE=$3 DOT_REPO_BRANCH=$4" >>"$HOME"/.bashrc
	else
		echo "Couldn't export ${BOLD}DOT_REPO=$1${RESET} and ${BOLD}DOT_DEST=$2${RESET}"
		echo "Consider exporting them manually."
		exit 1
	fi
	printf "\n%s" "Configuration for SHELL: ${BOLD}$current_shell${RESET} has been updated."
}

repo_check(){
	# check if dotfile repo is present inside DOT_DEST

	DOT_REPO_NAME=$(basename "${DOT_REPO}")
	# all paths are relative to HOME
	if [[ -d ${HOME}/${DOT_DEST}/${DOT_REPO_NAME} ]]; then
	    printf "\n%s\n" "Found ${BOLD}${DOT_REPO_NAME}${RESET} as dotfile repo in ${BOLD}~/${DOT_DEST}/${RESET}"
	else
	    printf "\n\n%s\n" "[❌] ${BOLD}${DOT_REPO_NAME}${RESET} not present inside path ${BOLD}${HOME}/${DOT_DEST}${RESET}"
		read -p "Should I clone it ? [Y/n]: " -n 1 -r USER_INPUT
		USER_INPUT=${USER_INPUT:-y}
		case $USER_INPUT in
			[y/Y]* ) clone_dotrepo "$DOT_DEST" "$DOT_REPO" ;;
			[n/N]* ) printf "\n%s" "${BOLD}${DOT_REPO_NAME}${RESET} not found";;
			* )     printf "\n%s\n" "[❌] Invalid Input 🙄, Try Again";;
		esac
	fi
}

intro
init_check
