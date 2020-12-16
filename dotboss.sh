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
	FG_ORANGE2=""
	UL=""
	RUL=""
else
	BOLD=$(tput bold)
	RESET=$(tput sgr0)
	FG_SKYBLUE=$(tput setaf 122)
	FG_ORANGE=$(tput setaf 208)
	BG_AQUA=$(tput setab 45)
	FG_BLACK=$(tput setaf 16)
	FG_ORANGE2=$(tput setaf 214)
	UL=$(tput smul)
	RUL=$(tput rmul)
fi

logo() {
	# print dotboss logo
	printf "${BOLD}${FG_SKYBLUE}%s\n" ""
	printf "%s\n" "                                                                           "
	printf "%s\n" " ________   _____________________________ ________    _________ _________  "
	printf "%s\n" " \______ \  \_____  \__    ___/\______   \\\_____  \  /   _____//   _____/ "
	printf "%s\n" "  |    |  \  /   |   \|    |    |    |  _/ /   |   \ \_____  \ \_____  \   "
	printf "%s\n" "  |    |   \/    |    \    |    |    |   \/    |    \/        \/        \  "
	printf "%s\n" " /_______  /\_______  /____|    |______  /\_______  /_______  /_______  /  "
	printf "%s\n" "         \/         \/                 \/         \/        \/        \/   "
	printf "%s\n" "                                                                           "
	printf "${RESET}\n%s" ""
}

# TODO(kiennt): Create a loop
# check if git exists
if ! command -v git &>/dev/null; then
	printf "%s\n\n" "${BOLD}${FG_SKYBLUE}${RESET}"
	echo "I can't live without Git 😞"
	exit 1
fi

# check if stow exists
if ! command -v stow &>/dev/null; then
	printf "%s\n\n" "${BOLD}${FG_SKYBLUE}${RESET}"
	echo "I can't live without Stow 😞"
	exit 1
fi

# check if tree exists
if ! command -v tree &>/dev/null; then
	printf "%s\n\n" "${BOLD}${FG_SKYBLUE}${RESET}"
	echo "I can't live without Tree 😞"
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
	if [[ -z ${DOT_REPO} && -z ${DOT_PARENT_DIR} ]]; then
		initial_setup
		goodbye
	else
		repo_check
		manage
	fi
}

initial_setup() {
	printf "\n\n%s\n" "First time use 🔥, spend time to do a ${BOLD}dotboss setup${RESET}"
	printf "%s\n" "..................................................."
	printf "%s\n"
	printf "%s\n" "${BOLD}${FG_ORANGE}NOTE:${RESET} Your dotfiles folder has to contain a subfolder named ${FG_ORANGE2}home${RESET}"
	printf "%s\n"
	read -p "➤ Enter dotfiles repository URL: " -r DOT_REPO
	read -p "➤ Where should I clone ${BOLD}$(basename "${DOT_REPO}")${RESET}, please enter absolute path (${HOME} by default): " -r DOT_PARENT_DIR
	read -p "➤ Enter the repository remote ('origin' by default): " -r DOT_REPO_REMOTE
	read -p "➤ Enter the repository branch ('master' by default): " -r DOT_REPO_BRANCH
	DOT_PARENT_DIR=${DOT_PARENT_DIR:-$HOME}
	DOT_REPO_REMOTE=${DOT_REPO_REMOTE:-"origin"}
	DOT_REPO_BRANCH=${DOT_REPO_BRANCH:-"master"}

	# check DOT_PARENT_DIR is directory and it is an absolute path
	if [[ -d "$DOT_PARENT_DIR" && ("${DOT_PARENT_DIR:0:1}" == / || "${DOT_PARENT_DIR:0:2}" == ~[/a-z]) ]]; then
		printf "\n%s\r\n" "${BOLD}Calling 📞 Git ... ${RESET}"
		clone_dotrepo "$DOT_PARENT_DIR" "$DOT_REPO" "$DOT_REPO_REMOTE" "$DOT_REPO_BRANCH"
		printf "\n%s\n" "Open a new terminal or source your shell config"
	else
		printf "\n%s" "[❌]${BOLD}$DOT_PARENT_DIR${RESET} Not a Valid directory"
		exit 1
	fi
}

clone_dotrepo() {
	# clone the repo in the destination directory
	DOT_PARENT_DIR=$1
	DOT_REPO=$2
	DOT_REPO_REMOTE=$3
	DOT_REPO_BRANCH=$4

	if git -C "${DOT_PARENT_DIR}" clone "${DOT_REPO}"; then
		if [[ $DOT_REPO && $DOT_PARENT_DIR ]]; then
			add_env "$DOT_REPO" "$DOT_PARENT_DIR" "$DOT_REPO_REMOTE" "$DOT_REPO_BRANCH"
		fi
		printf "\n%s" "[✔️] dotboss successfully configured"
	else
		# invalid arguments to exit, Repository Not Found
		printf "\n%s" "[❌] $DOT_REPO Unavailable. Exiting !"
		exit 1
	fi
}

add_env() {
	[[ "$DOT_PARENT_DIR" && "$DOT_REPO" && "$DOT_REPO_REMOTE" && "$DOT_REPO_BRANCH" ]] && return
	# export environment variables
	printf "\n%s\n" "Exporting env variables DOT_PARENT_DIR, DOT_REPO, DOT_REPO_REMOTE & DOT_REPO_BRANCH ..."

	current_shell=$(basename "$SHELL")
	DOT_REPO_NAME=$(basename "${DOT_REPO}")
	DOT_REPO_DIR=${DOT_PARENT_DIR}/${DOT_REPO_NAME}
	if [[ $current_shell == "zsh" ]]; then
		echo "# Dotboss configs" >>"$HOME"/.zshrc
		echo "export DOT_REPO=$1 DOT_PARENT_DIR=$2 DOT_REPO_REMOTE=$3 DOT_REPO_BRANCH=$4 DOT_REPO_DIR=${DOT_REPO_DIR}" >>"$HOME"/.zshrc
	elif [[ $current_shell == "bash" ]]; then
		# assume we have a fallback to bash
		echo "# Dotboss configs" >>"$HOME"/.bashrc
		echo "export DOT_REPO=$1 DOT_PARENT_DIR=$2 DOT_REPO_REMOTE=$3 DOT_REPO_BRANCH=$4 DOT_REPO_DIR=${DOT_REPO_DIR}" >>"$HOME"/.bashrc
	else
		echo "Couldn't export ${BOLD}DOT_REPO=$1${RESET} and ${BOLD}DOT_PARENT_DIR=$2 DOT_REPO_REMOTE=$3 DOT_REPO_BRANCH=$4 DOT_REPO_DIR=${DOT_REPO_DIR}${RESET}"
		echo "Consider exporting them manually."
		exit 1
	fi
	printf "\n%s" "Configuration for SHELL: ${BOLD}$current_shell${RESET} has been updated."
}

repo_check() {
	# check if dotfile repo is present inside DOT_PARENT_DIR

	DOT_REPO_NAME=$(basename "${DOT_REPO}")
	# all paths are relative to HOME
	if [[ -d ${DOT_PARENT_DIR}/${DOT_REPO_NAME} ]]; then
		printf "\n%s\n" "Found ${BOLD}${DOT_REPO_NAME}${RESET} as dotfile repo in ${BOLD}~/${DOT_PARENT_DIR}/${RESET}"
	else
		printf "\n\n%s\n" "[❌] ${BOLD}${DOT_REPO_NAME}${RESET} not present inside path ${BOLD}${DOT_PARENT_DIR}${RESET}"
		read -p "Should I clone it ? [Y/n]: " -n 1 -r USER_INPUT
		USER_INPUT=${USER_INPUT:-y}
		case $USER_INPUT in
		[y/Y]*) clone_dotrepo "$DOT_PARENT_DIR" "$DOT_REPO" ;;
		[n/N]*) printf "\n%s" "${BOLD}${DOT_REPO_NAME}${RESET} not found" ;;
		*) printf "\n%s\n" "[❌] Invalid Input 🙄, Try Again" ;;
		esac
	fi
}

setup_stow() {
	[[ "$DOT_PARENT_DIR" && "$DOT_REPO" && "$DOT_REPO_REMOTE" && "$DOT_REPO_BRANCH" && "$DOT_REPO_DIR" ]] && return
	printf "\n%s\n" "Your current dotfiles in ${BOLD}${DOT_REPO_DIR}${RESET}"
	tree ${DOT_REPO_DIR}/home
	printf "\n%s\n" "Execute stow command..."
	# force create symbol link
	# for more details, please check `man stow`
	stow -v --adopt -t "${HOME}" ${DOT_REPO_NAME}
}

setup_automatic() {
	printf "\n%s\n" "${BOLD}Setup automatic...${RESET}"
	printf "\n%s\n" "Check if there are gitwatch processes is running"
	gitwatch_proc=$(ps -ef | grep "gitwatch" | grep -v "grep")
	if [[ ${#gitwatch_proc} != 0 ]]; then
		printf "\n%s\n" "Found gitwatch processes is running"
		printf "\n%s" "[${BOLD}1${RESET}] Kill the current gitwatch process(es)"
		printf "\n%s" "[${BOLD}2${RESET}] Skip the setup, keep it as before"
		printf "\n%s\n" "[${BOLD}q/Q${RESET}] Quit Session"
		read -p "What do you want me to do ? [${BOLD}1${RESET}]: " -n 1 -r USER_INPUT
		# Default choice is [1], See Parameter Expansion
		USER_INPUT=${USER_INPUT:-1}
		case $USER_INPUT in
		[1]*) kill_gitwatch ;;
		[2]*)
			printf "\n%s" "${BOLD}Ok, just keep it 😌${RESET}"
			goodbye
			return
			;;
		[q/Q]*)
			goodbye
			exit
			;;
		*) printf "\n%s\n" "[❌]Invalid Input 🙄, Try Again" ;;
		esac
	else
		start_gitwatch
	fi
}

start_gitwatch() {
	printf "\n%s\n" "${BOLD}Start a gitwatch process in background${RESET}"
	nohup gitwatch -r ${DOT_REPO_REMOTE} -b ${DOT_REPO_BRANCH} ${DOT_REPO_DIR}") &
	printf "\n%s\n" "${BOLD}Create init file to start gitwatch at startup (require ${BOLD}root priviledge${RESET})"
	sudo echo "nohup gitwatch -r origin -b master ${DOT_REPO_DIR}") &" >/etc/init.d/dotboss_gitwatch
	sudo chmod a+x /etc/init.d/dotboss_gitwatch
}

kill_gitwatch() {
	printf "\n%s\n" "${BOLD}Kill a gitwatch process in background${RESET}"
	ps -ef | grep "gitwatch" | grep -v "grep" | awk '{print $2}' | xargs kill -9
	printf "\n%s\n" "${BOLD}Killed! 💀${RESET}"
}

setup_manual() {
	printf "\n%s\n" "${BOLD}Setup manual...${RESET}"
	while :; do
		printf "\n%s" "[${BOLD}1${RESET}] Show diff"
		printf "\n%s" "[${BOLD}2${RESET}] Push changed dotfiles"
		printf "\n%s" "[${BOLD}3${RESET}] Pull latest changes"
		printf "\n%s\n" "[${BOLD}q/Q${RESET}] Quit Session"
		read -p "What do you want me to do ? [${BOLD}1${RESET}]: " -n 1 -r USER_INPUT
		# Default choice is [1], See Parameter Expansion
		USER_INPUT=${USER_INPUT:-1}
		case $USER_INPUT in
		[1]*) show_diff_check ;;
		[2]*) dot_push ;;
		[3]*) dot_pull ;;
		[q/Q]*)
			goodbye
			exit
			;;
		*) printf "\n%s\n" "[❌]Invalid Input 🙄, Try Again" ;;
		esac
	done
}

show_diff_check() {
	printf "\n%s\n" "${BOLD}Check git status & git diff...${RESET}"
	printf "\n%s" "${BOLD}List all file changed${RESET}"
	changed_files=$(git -C "${DOT_REPO_DIR}" --no-pager diff --name-only)
	printf "\n%s" "$changed_files"
	changes=$(git -C "${DOT_REPO_DIR}" --no-pager diff --color)
	printf "\n%s" "${BOLD}List all changes${RESET}"
	printf "\n%s\n" "$changes"
}

dot_pull() {
	# pull changes (if any) from the remote repo
	printf "\n%s\n" "${BOLD}Pulling dotfiles ...${RESET}"
	printf "\n%s\n" "Pulling changes in ${DOT_REPO_DIR}"
	GET_BRANCH=$(git remote show origin | awk '/HEAD/ {print $3}')
	printf "\n%s\n" "Pulling from ${BOLD}${GET_BRANCH}"
	git -C "${DOT_REPO_DIR}" pull origin "${GET_BRANCH}"
}

dot_push() {
	show_diff_check
	changed_files=$(git -C "$dot_repo" --no-pager diff --name-only)
	if [[ ${#changed_files} != 0 ]]; then
		printf "\n%s" "${BOLD}Following dotfiles changed${RESET}"
		git -C "${DOT_REPO_DIR}" add -A
		echo "${BOLD}Enter Commit message (Ctrl + d to save): ${RESET}"
		commit=$(</dev/stdin)
		printf "\n"
		git -C "${DOT_REPO_DIR}" commit -m "$commit"

		# Run Git Push
		git -C "${DOT_REPO_DIR}" push
	else
		printf "\n%s\n" "${BOLD}No Changes in dotfiles.${RESET}"
		return
	fi
}

manage() {
	# Setup stow
	setup_stow

	while :; do
		printf "\n%s\n" "[${BOLD}1${RESET}] Automatic mode with gitwatch"
		printf "\n%s\n" "[${BOLD}2${RESET}] Manual mode"
		printf "\n%s\n" "[${BOLD}q/Q${RESET}] Quit Session"
		read -p "What do you want me to do? [${BOLD}1${RESET}]: " -n 1 -r USER_INPUT
		# Default choice is [1], See Parameter Expansion
		USER_INPUT=${USER_INPUT:-1}
		case $USER_INPUT in
		[1]*) setup_automatic ;;
		[2]*) setup_manual ;;
		[q/Q]*)
			goodbye
			exit
			;;
		*) printf "\n%s\n" "[❌] Invalid Input 🙄, Try Again" ;;
		esac
	done
}

intro
init_check
