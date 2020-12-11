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
		echo "Do something"
	fi
}

initial_setup() {
	printf "\n\n%s\n" "First time use 🔥, spend time to do a ${BOLD}dotboss setup${RESET}"
	printf "%s\n" "...................................."
	read -p "➤ Enter dotfiles repository URL : " -r DOT_REPO
	read -p "➤ Where should I clone ${BOLD}$(basename "${DOT_REPO}")${RESET} (${HOME}/..): " -r DOT_DEST
	DOT_DEST=${DOT_DEST:-$HOME}

	if [[ -d "$HOME/$DOT_DEST" ]]; then
		printf "\n%s\r\n" "${BOLD}Calling 📞 Git ... ${RESET}"
		clone_dotrepo "$DOT_DEST" "$DOT_REPO"
		printf "\n%s\n" "Open a new terminal or source your shell config"
	else
		printf "\n%s" "[❌]${BOLD}$DOT_DEST${RESET} Not a Valid directory"
		exit 1
	fi
}

intro
init_check
