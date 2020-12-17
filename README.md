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

- Grab [dotboss.sh](./dotboss.sh) and store it (ideally please store it in PATH folders to call it from anywhere)
- Change file permissions to be executable.

```bash
$ chmod a+x dotboss.sh
```

## 4. Usage

Just run `dotboss` anywhere in your terminal.

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
