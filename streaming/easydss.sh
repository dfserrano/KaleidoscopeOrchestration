echo "Update packages lists...";
sudo apt-get update;

echo "Installing Git, logrotate and building packages...";
sudo apt-get install -y build-essential git logrotate;

echo "Configuring logrotate...";
sudo tee -a /etc/logrotate.conf <<EOF
/opt/EasyDarwin/EasyDarwin/Logs/stats {
    daily
    copytruncate
    rotate 3
    compress
    delaycompress
    missingok
}
EOF
echo "Logrotate configured daily, rotate 3, with compression";

echo "Getting EasyDarwin Streaming Server files...";
cd /opt;
sudo git clone https://github.com/EasyDarwin/EasyDarwin.git;
cd /opt/EasyDarwin;
sudo git checkout a245348;
echo "EasyDarwin Streaming Server downloaded";

echo "Building EasyDarwin Streaming Server...";
cd /opt/EasyDarwin/EasyDarwin;
sudo chmod +x Buildit;
sudo ./Buildit;
echo "Building EasyDarwin Streaming Server... completed";

echo "Making folder for on-demand videos...";
sudo mkdir /opt/EasyDarwin/EasyDarwin/Movies;

# Downloading demo video
cd /opt/EasyDarwin/EasyDarwin/Movies;
sudo wget https://raw.githubusercontent.com/dfserrano/KaleidoscopeOrchestration/master/streaming/Demo.mp4;
echo "On-demand video folder created";

echo "Attempting to run the streaming server...";
cd /opt/EasyDarwin/EasyDarwin;
sudo ./EasyDarwin -c ./WinNTSupport/easydarwin.xml -D >> /opt/EasyDarwin/EasyDarwin/Logs/stats &
echo "Streaming server running and ready to stream";
