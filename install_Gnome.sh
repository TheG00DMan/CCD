#!/bin/bash
# GNOME-on-Chromebook setup + scaling gog script
# Run with:  bash gnome-setup.sh

set -e

echo "=== GNOME setup for Chromebook Linux (Debian) ==="

USER_ID="$(whoami)"
echo "Detected user: $USER_ID"
echo

echo "=== Updating and upgrading packages ==="
sudo apt update -y
sudo apt dist-upgrade -y

echo
echo "=== Installing GNOME desktop and tools ==="
# Core GNOME + tools mentioned in the guide
sudo apt install -y \
  task-gnome-desktop \
  nano \
  xserver-xephyr \
  cros-pipe-config \
  calc \
  gnome-shell-extension-manager

echo
echo "=== Backing up any existing /usr/bin/gog script (if present) ==="
if [ -f /usr/bin/gog ] && [ ! -f /usr/bin/gog.bak ]; then
  echo "Backing up existing /usr/bin/gog to /usr/bin/gog.bak"
  sudo mv /usr/bin/gog /usr/bin/gog.bak
else
  echo "No existing /usr/bin/gog found or backup already exists."
fi

echo
echo "=== Creating new scaling-aware gog script ==="
sudo tee /usr/bin/gog >/dev/null <<'EOF'
#!/bin/bash

sudo killall Xephyr &> /dev/null
sudo rm /tmp/.X20-lock &> /dev/null

DIMENSION=$(sommelier -X xdpyinfo 2> /dev/null | grep dim | \
cut -d ':' -f 2 | cut -d 'p' -f 1 )

WIDTH=$(echo $DIMENSION | cut -d 'x' -f 1)
HEIGHT=$(echo $DIMENSION | cut -d 'x' -f 2)

if [ "$1" = "h" ]; then
    PERCENT=$((HEIGHT*100/$2))
elif [ "$1" = "w" ]; then
    PERCENT=$((WIDTH*100/$2))
elif [ "$1" = "" ]; then
    # Default PERCENT
    PERCENT=100
else
    PERCENT=$1
fi

RES=$(calc -d 100/$PERCENT); RES=${RES:1:5}

COMMAND='sommelier -X --scale='$RES\
' --glamor Xephyr -br -fullscreen -resizeable :20'

echo $DIMENSION, $WIDTH, $HEIGHT, $PERCENT
echo $COMMAND

exec $COMMAND &> /dev/null &

sudo systemctl stop NetworkManager
sudo systemctl restart networking &> /dev/null &
sleep 3

sudo -u <user-id> env XDG_RUNTIME_DIR=/run/user/1000 \
GDK_BACKEND=x11 PATH=/usr/local/bin:/usr/bin:\
/usr/local/games:/usr/games \
DISPLAY=:20 dbus-launch gnome-shell --x11 &> /dev/null &
EOF

echo "Injecting actual username ($USER_ID) into /usr/bin/gog..."
sudo sed -i "s/<user-id>/$USER_ID/g" /usr/bin/gog
sudo chmod +x /usr/bin/gog

echo
echo "=== Creating standard directories (if missing) ==="
for d in Documents Downloads Music PDF Pictures Templates Videos; do
  if [ ! -d "$HOME/$d" ]; then
    echo "Creating $HOME/$d"
    mkdir "$HOME/$d"
  fi
done

echo
echo "=== Done! ==="
echo
echo "Next steps:"
echo "1) (Recommended) Set passwords manually:"
echo "   sudo passwd $USER_ID"
echo "   sudo passwd root"
echo
echo "2) Start GNOME with scaling:"
echo "   gog            # default scale (currently 100%)"
echo "   gog 150        # 150% scale"
echo "   gog h 1080     # scale so height is 1080"
echo "   gog w 1200     # scale so width is 1200"
echo
echo "To properly shut down Linux: right-click Terminal > Shut down Linux."
