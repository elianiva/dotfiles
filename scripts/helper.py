#!/bin/python

from os import system, chdir, path

repo_url = "https://aur.archlinux.org/paru-bin.git"

def setup_aur_helper():
    if path.exists("/usr/bin/paru"):
        print("Paru is already installed")
        return
    if not path.exists("/tmp/paru-bin"):
        system(f"git clone {repo_url} /tmp/paru-bin")
    chdir("/tmp/paru-bin")
    system("makepkg -si")

def install_packages(pkgs: str):
    system(f"paru -S {pkgs} --noconfirm --needed")
