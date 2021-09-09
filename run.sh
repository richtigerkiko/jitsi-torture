URL=https://meet.jit.si
ROOMPREFIX=test
AUDIOSENDERS=0
PARTICIPANTS=5
ACTIVE_SELENIUMNODES=$( docker ps -a | grep jitsi-meet-torture-selenium-node | wc -l )


if [$1 -eq ""]; then
    echo "Setting Participants to Default Value of 5"
else
    PARTICIPANTS=$1
fi

function Stop_Docker-Compose(){
    echo "🛑🛑 Stopping Active docker-compose containers🛑🛑"
    docker-compose down
}

function Write_EmptyRows(){
    for i in $(seq 1 $1)
    do
        printf "\n"
    done
}

function Start_Docker_Compose(){
    Write_EmptyRows 3
    Stop_Docker-Compose
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
    Write_EmptyRows 3
    echo "🚀🚀 🚀🚀"
}

function End_Test(){
    Write_EmptyRows 3
    echo "🛑🛑 Ending Test 🛑🛑"
    Stop_Docker-Compose
    exit 0
}

if [ $ACTIVE_SELENIUMNODES -lt $PARTICIPANTS ]; then
    echo "Not Enough Seleniumnodes detected"
    Start_Docker_Compose
    Start_Test
    End_Test
else
    echo "Enough Nodes Present"
    Start_Test
    End_Test
fi


