# dotboss

```
________   _____________________________ ________    _________ _________
\______ \  \_____  \__    ___/\______   \\_____  \  /   _____//   _____/
 |    |  \  /   |   \|    |    |    |  _/ /   |   \ \_____  \ \_____  \
 |    `   \/    |    \    |    |    |   \/    |    \/        \/        \
/_______  /\_______  /____|    |______  /\_______  /_______  /_______  /
        \/         \/                 \/         \/        \/        \/
```

- [dotboss](#dotboss)
  - [1. What is this?](#1-what-is-this)
  - [2. Features](#2-features)
  - [3. Installation](#3-installation)
  - [4. Usage](#4-usage)

## 1. What is this?

dotboss is a easy to use dotfiles manager.

> Inspired by [Dotman](https://www.freecodecamp.org/news/build-your-own-dotfiles-manager-from-scratch/).

## 2. Features

- Single file manager.
- No config files.
- Easy to use.
- Use stow to manage dot files.
- Automatically watch changes and backup.

## 3. Installation

- Install the dependencies.

  - `stow`
  - `bash >= 3`
  - `git`
  - `tree`
  - [`gitwatch`](https://github.com/gitwatch/gitwatch)
  - [`inotify-tools`](https://github.com/rvoicilas/inotify-tools)

- Grab [dotboss.sh](./dotboss.sh) and store it (ideally please store it in PATH folders to call it from anywhere).
- Change file permissions to be executable.

```bash
$ chmod a+x dotboss.sh
```

## 4. Usage

- Prepare your repository, folder structure should look like this:
- Configure your Git username & email for commits. For example:

```bash
$ git config --global user.name "FIRST_NAME LAST_NAME"
$ git config --global user.email "MY_NAME@example.com"
```

- Note that, if you use automatic mode, you have to configure remote url as SSH url. This is documented at Github: [Switching remote URLs from HTTPS to SSH](https://help.github.com/articles/changing-a-remote-s-url/#switching-remote-urls-from-https-to-ssh). Or you can configure Git to store your username & password.

```bash
# Make Git store the username and password and it will never ask for them.
$ git config --global credential.helper store
# Save the username and password for a session (cache it);
$ git config --global credential.helper cache
```

- Run `dotboss` anywhere in your terminal.

```bash
$ dotboss


Hi kiennt 👋

 ________   _____________________________ ________    _________ _________
 \______ \  \_____  \__    ___/\______   \\_____  \  /   _____//   _____/
  |    |  \  /   |   \|    |    |    |  _/ /   |   \ \_____  \ \_____  \
  |    |   \/    |    \    |    |    |   \/    |    \/        \/        \
 /_______  /\_______  /____|    |______  /\_______  /_______  /_______  /
         \/         \/                 \/         \/        \/        \/




First time use 🔥, spend time to do a dotboss setup
...................................................

NOTE: Your dotfiles folder has to contain a subfolder named home

➤ Enter dotfiles repository URL:
```
