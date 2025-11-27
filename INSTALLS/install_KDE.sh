#!/bin/bash

# Update & upgrade
sudo apt update -y
sudo apt dist-upgrade -y

# Install KDE Plasma, Xephyr, and nano
sudo apt install -y task-kde-desktop xserver-xephyr nano

# Disable LightDM (not used on ChromeOS)
sudo systemctl disable lightdm || true

# Create gol launcher for KDE
sudo bash -c 'cat <<EOF >/usr/bin/gol
#!/bin/bash
Xephyr -br -fullscreen -resizeable :20 &
sleep 5
sudo DISPLAY=:20 startplasma-x11 &
EOF'

# Make gol executable
sudo chmod +x /usr/bin/gol

echo "✔ KDE setup complete!"
echo "Run KDE Plasma with:  gol"
