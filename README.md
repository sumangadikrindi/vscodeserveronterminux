# vscodeserveronterminux
This script is for opening a VS Code tunnel running on pdistro-ubuntu in Terminux app on Android phone.
This installs proot-distro ubuntu, and inside the proot-dristro it installs .net lts sdk, and vs code cli, and opens vs code tunnel.

First time user need to authenticate the vs code server either with microsoft or github account, following the device code url printed by script.

Next time onwards, when Terminux is started on android phone, user can go to vscode.dev/tunnel/my-terminux-ubuntu and start working in the tunnel environment by logging-in with same microsoft or github account.

# Usage
## On you android phone install Terminux first
### 📲 1. Install via **Google Play Store**
- Official, easy, and auto-updated for Android 11+ users.  
- Just open the Play Store app and search for **“Termux”** or use this link: [Termux – Apps on Google Play](https://play.google.com/store/apps/details?id=com.termux).  
- Compatible devices begin with Android 11 and above – works for most newer phones.

---

### 🛠️ 2. Install via **F-Droid (Recommended)**
- Best for stable releases compatible across many Android versions (7+).  
- Procedure:
  1. Open [F-Droid](https://f-droid.org/en/packages/com.termux/) in your browser and install the F-Droid client.
  2. In F-Droid, search for **“Termux”** and install from its repository.
- Guaranteed to work on Android 7.0+ with automatic app updates handled by F-Droid.

## Open Terminux app, and run this script to start VS code tunnel
- type below command on the terminal that is opened in Terminux app
```bash
curl https://raw.githubusercontent.com/sumangadikrindi/vscodeserveronterminux/main/setup-autostart-ubuntu-vscode-tunnel.sh | bash
```
