#!/bin/python

import os

if os.environ.get("WITH_PKGS") == "no":
    os._exit(0)

from helper import setup_aur_helper, install_packages

# package list
import cli
import pkgs
import fonts
import languages

# setup paru for installing aur stuff
setup_aur_helper()

# install packages
global_packages = cli.packages + pkgs.packages + fonts.packages + languages.packages
install_packages(" ".join(global_packages))

# install fnm if it doesn't exists
home = os.environ.get("HOME")
if not os.path.exists(f"{home}/.fnm/fnm"):
    os.system("curl -fsSL https://fnm.vercel.app/install | bash")

# install foreign env for fish
os.system("fisher install oh-my-fish/plugin-foreign-env")
