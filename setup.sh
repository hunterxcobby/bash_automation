#!/usr/bin/bash


echo

tput setaf 6 # Set foreground color to green
tput bold

# DANCING CHARACTERS


# Define dancing characters for each frame
frames=("(^_^)" "(~_^)" "(^~^)" "(^_^)")

# Adjust the delay between frames in seconds
delay=0.5

# Function to clear the current line
clear_line() 
{
    echo -ne "\r\033[K"
}

# Main animation loop
echo "DELIBERATELY CREATING SUSPENSE!!"
echo
for i in {1..5}; do
    for frame in "${frames[@]}"; do
        clear_line
        echo -n "HEHEHE : ${frame}"
        sleep ${delay}
    done
done

# Move to the next line after the animation
echo

# NEXT STEP
loading_chars="___"
delay=0.1  # Adjust the delay between frames in seconds

echo
echo -n "Loading: "
for i in {1..30}; do
    for char in ${loading_chars}; do
        echo -ne "\b${char}"
        sleep ${delay}
    done
done

echo  # Move to the next line after the loading animation
echo
echo 

echo "꧁༺ 𝓗𝓮𝔂 𝓑𝓪𝓫𝓮, \
 𝓖𝓻𝓪𝓷𝓽 𝓶𝓮 𝓽𝓱𝓮 𝓹𝓮𝓻𝓶𝓲𝓼𝓼𝓲𝓸𝓷 𝓽𝓸 𝓱𝓪𝓬𝓴 𝔂𝓸𝓾𝓻 𝓱𝓮𝓪𝓻𝓽? ༻꧂"

echo 

while true; do
    sleep 1.5
    echo
    echo "꧁༺ 𝓓𝓸 𝓷𝓸𝓽 𝔀𝓸𝓻𝓻𝔂, 𝓽𝓱𝓲𝓼 𝔀𝓲𝓵𝓵 𝓸𝓷𝓵𝔂 𝓽𝓪𝓴𝓮 𝓼𝓸𝓶𝓮 𝓽𝓲𝓶𝓮 ༻꧂"
    sleep 1.5
    echo
    echo
    echo "❀ꗥ～ꗥ❀ 𝐀𝐜𝐜𝐞𝐬𝐬𝐢𝐧𝐠 𝐲𝐨𝐮𝐫 𝐝𝐚𝐭𝐚𝐛𝐚𝐬𝐞... ❀ꗥ～ꗥ❀"
    echo 
tput sgr0    # Reset attributes
    sleep 4.0
    sudo apt-get install -y toilet && break
done

sleep 4.0
 # Display in a different font and colors
echo 
toilet -f term -F border --gay "Happy Birthday Baby!"

sleep 2.0

echo 
toilet -f term -F border --gay "SAMUELLA AMI MANYE AGLAGO!"

sleep 2.0
echo 
toilet -f term -F border --gay "MY PARTNER IN EVERYTHING!"

sleep 2.0
echo 
toilet -f term -F border --gay "I LOVE YOU SO MUCH!"


