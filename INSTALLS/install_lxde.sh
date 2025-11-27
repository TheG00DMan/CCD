#!/bin/bash

# Update & upgrade
sudo apt update -y
sudo apt dist-upgrade -y

# Install LXDE, Xephyr, and nano
sudo apt install -y task-lxde-desktop xserver-xephyr nano

# Disable LightDM (not used on ChromeOS)
sudo systemctl disable lightdm || true

# Create gol launcher
sudo bash -c 'cat <<EOF >/usr/bin/gol
#!/bin/bash
Xephyr -br -fullscreen -resizeable :20 &
sleep 5
sudo DISPLAY=:20 startlxde &
EOF'

# Make gol executable
sudo chmod +x /usr/bin/gol

echo "✔ Setup complete!"
echo "Run LXDE with:  gol"
