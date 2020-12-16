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
	if [[ -z ${DOT_REPO} && -z ${DOT_DEST} ]]; then
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
	read -p "➤ Where should I clone ${BOLD}$(basename "${DOT_REPO}")${RESET}, please enter absolute path (${HOME} by default): " -r DOT_DEST
	read -p "➤ Enter the repository remote ('origin' by default): " -r DOT_REPO_REMOTE
	read -p "➤ Enter the repository branch ('master' by default): " -r DOT_REPO_BRANCH
	DOT_DEST=${DOT_DEST:-$HOME}
	DOT_REPO_REMOTE=${DOT_REPO_REMOTE:-"origin"}
	DOT_REPO_BRANCH=${DOT_REPO_BRANCH:-"master"}

	# check DOT_DEST is directory and it is an absolute path
	if [[ -d "$DOT_DEST" && ("${DOT_DEST:0:1}" == / || "${DOT_DEST:0:2}" == ~[/a-z]) ]]; then
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

	if git -C "${DOT_DEST}" clone "${DOT_REPO}"; then
		if [[ $DOT_REPO && $DOT_DEST ]]; then
			add_env "$DOT_REPO" "$DOT_DEST" "$DOT_REPO_REMOTE" "$DOT_REPO_BRANCH"
		fi
		printf "\n%s" "[✔️] dotboss successfully configured"
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

repo_check() {
	# check if dotfile repo is present inside DOT_DEST

	DOT_REPO_NAME=$(basename "${DOT_REPO}")
	# all paths are relative to HOME
	if [[ -d ${DOT_DEST}/${DOT_REPO_NAME} ]]; then
		printf "\n%s\n" "Found ${BOLD}${DOT_REPO_NAME}${RESET} as dotfile repo in ${BOLD}~/${DOT_DEST}/${RESET}"
	else
		printf "\n\n%s\n" "[❌] ${BOLD}${DOT_REPO_NAME}${RESET} not present inside path ${BOLD}${DOT_DEST}${RESET}"
		read -p "Should I clone it ? [Y/n]: " -n 1 -r USER_INPUT
		USER_INPUT=${USER_INPUT:-y}
		case $USER_INPUT in
		[y/Y]*) clone_dotrepo "$DOT_DEST" "$DOT_REPO" ;;
		[n/N]*) printf "\n%s" "${BOLD}${DOT_REPO_NAME}${RESET} not found" ;;
		*) printf "\n%s\n" "[❌] Invalid Input 🙄, Try Again" ;;
		esac
	fi
}

setup_stow() {
	[[ "$DOT_DEST" && "$DOT_REPO" && "$DOT_REPO_REMOTE" && "$DOT_REPO_BRANCH" ]] && return
	DOT_REPO_NAME=$(basename "${DOT_REPO}")
	printf "\n%s\n" "Your current dotfiles in ${BOLD}${DOT_DEST}${RESET}"
	tree ${DOT_DEST}/${DOT_REPO_NAME}
	printf "\n%s\n" "Execute stow command..."
	# force create symbol link
	# When stowing, if a target is encountered which already exists but is a plain file (and hence not owned by any existing stow package), then normally Stow will register this as a
	# conflict and refuse to proceed.  This option changes that behaviour so that the file is moved to the same relative place within the package's installation image within the stow
	# directory, and then stowing proceeds as before.  So effectively, the file becomes adopted by the stow package, without its contents changing.
	stow -v --adopt -t "${HOME}" ${DOT_REPO_NAME}
	printf "\n"
}

setup_automatic() {
	printf "\n%s\n" "${BOLD}Setup automatic...${RESET}"
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
	dot_repo="${DOT_DEST}/$(basename "${DOT_REPO}")"
	printf "\n%s\n" "${BOLD}List all file changed${RESET}"
	changed_files=$(git -C "$dot_repo" --no-pager diff --name-only)
	printf "\n%s\n" "$changed_files"
	changes=$(git -C "$dot_repo" --no-pager diff --color)
	printf "\n%s\n" "${BOLD}List all changes${RESET}"
	printf "\n%s\n" "$changes"
}

dot_pull() {
	# pull changes (if any) from the remote repo
	printf "\n%s\n" "${BOLD}Pulling dotfiles ...${RESET}"
	dot_repo="${DOT_DEST}/$(basename "${DOT_REPO}")"
	printf "\n%s\n" "Pulling changes in $dot_repo"
	GET_BRANCH=$(git remote show origin | awk '/HEAD/ {print $3}')
	printf "\n%s\n" "Pulling from ${BOLD}${GET_BRANCH}"
	git -C "$dot_repo" pull origin "${GET_BRANCH}"
}

dot_push() {
	show_diff_check
	dot_repo="${DOT_DEST}/$(basename "${DOT_REPO}")"
	changed_files=$(git -C "$dot_repo" --no-pager diff --name-only)
	if [[ ${#changed_files} != 0 ]]; then
		printf "\n%s\n" "${BOLD}Following dotfiles changed${RESET}"
		git -C "$dot_repo" add -A
		echo "${BOLD}Enter Commit message (Ctrl + d to save): ${RESET}"
		commit=$(</dev/stdin)
		printf "\n"
		git -C "$dot_repo" commit -m "$commit"

		# Run Git Push
		git -C "$dot_repo" push
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
