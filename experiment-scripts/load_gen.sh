# Parameters:
# 1 - Number of sessions
# 2 - Base name of the video
# Example: bash load_gen.sh 3 Demo

# In each VM:
# sudo apt-get update;
# sudo apt-get install -y vlc;
# mkdir ~/vlc-logs
# cd ~/vlc-logs

NUM_VIDEOS=5
NUM_SESSIONS=$1
VIDEO_NAME=$2
CURDATE=$(date +%s)

for ((i=1; i<=$NUM_SESSIONS; i++)); do
	VIDEO_NUMBER=$(( ( RANDOM % NUM_VIDEOS )  + 1 ))
	echo "screen -d -m vlc --intf dummy rtsp://142.150.208.206:554/${VIDEO_NAME}${VIDEO_NUMBER}.mp4 -vvv --file-logging --logfile=vlc-log${CURDATE}_${i}.txt"
done

// screen -d -m vlc --intf dummy rtsp://162.246.156.33:554/${VIDEO_NAME}${VIDEO_NUMBER}.mp4 -vvv --file-logging --logfile=vlc-log${CURDATE}_${i}.txt
