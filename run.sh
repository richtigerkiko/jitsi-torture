URL=https://meet.jit.si
ROOMPREFIX=tester
AUDIOSENDERS=0

ACTIVE_SELENIUMNODES=$( docker ps -a | grep jitsi-meet-torture-selenium-node | wc -l )


if [$1 -eq 0]; then
    echo "Setting Participants to Default Value of 5"
    PARTICIPANTS=5
else 
    PARTICIPANTS=$1
fi


function Write_EmptyRows(){
    for i in $(seq 1 $1)
    do
        printf "\n"
    done
}

function Start_Docker_Compose(){
    Write_EmptyRows 3
    echo "🛑🛑 Stopping Active docker-compose containers🛑🛑"
    docker-compose stop
    Write_EmptyRows 3
    echo "🚀🚀 Starting docker-compose with enough selenium nodes for test 🚀🚀"
    docker-compose up -d --scale node=$PARTICIPANTS
}

function Start_Test(){
    Write_EmptyRows 3
    echo "🚀🚀 Starting Test 🚀🚀"
    docker-compose exec torture ./scripts/malleus.sh \
        --conferences=1 \
        --participants=$PARTICIPANTS \
        --senders=$PARTICIPANTS \
        --audio-senders=$AUDIOSENDERS \
        --duration=300 \
        --room-name-prefix=$ROOMPREFIX \
        --hub-url=http://hub:4444/wd/hub \
        --instance-url=$URL
}


if [ $ACTIVE_SELENIUMNODES -lt $PARTICIPANTS ]; then
    echo "Not Enough Seleniumnodes detected"
    Start_Docker_Compose
    Start_Test
else
    echo "Enough Nodes Present"
    Start_Test
fi
