# vscodeserveronterminux
This script is for running on Terminux app on Android phone.
This installs proot-distro ubuntu, and inside the proot-dristro it installs .net lts sdk, and vs code cli, and opens vs code tunnel.

First time user need to authenticate the vs code server either with microsoft or github account, following the device code url printed by script on any browser.

Additionally script prints a public ssh key, that is to be 

Next timeonwards, when Terminux is started on android phone, user can go to vscode.dev/tunnel/<tunnel name> and start working in the tunnel environment.

