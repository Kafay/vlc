#!/bin/sh

########################################################################
# VLC demo command line generator
# $Id$
########################################################################

#TODO: change on Max OS X
if test ".`uname -s`" = ".Darwin"; then
  VLC="./VLC.app/Contents/MacOS/VLC --quiet --color "
else
  VLC="./vlc --quiet --color "
fi
CMD=""

pyschedelic()
{
  echo -e "\n- Psychedelic demo -\nconfiguration\n"
  echo -en "Please chose an input. Live camera feeds are best.\ninput? "
  read input
  echo -e "\n$VLC --sub-filter marq --marq-position 8 --marq-size 30 --marq-color 16776960 --marq-marquee \"VLC - Psychedelic video filter\" --vout-filter distort --distort-mode psychedelic $input"
}

gradient()
{
  echo -e "\n- Gradient demo -\nconfiguration\n"
  echo -en "Please chose an input. Live camera feeds are best.\ninput? "
  read input
  echo -en "Please chose a logo to display (or multiple logos according to the --logo-file syntax)\nlogo? "
  read logofile
  echo "new a broadcast enabled loop
setup a input $input
setup a output #duplicate{dst=mosaic-bridge,select=video}
control a play" > "`pwd`/demo.vlm"
  echo "VLM batch file saved to `pwd`/demo.vlm"
  echo -e "\n$VLC --sub-filter mosaic:marq:logo --mosaic-width 120 --mosaic-height 90 --mosaic-cols 1 --mosaic-rows 1 --marq-position 8 --marq-size 30 --marq-color 65280 --marq-marquee \"VLC - Gradient video filter\" --logo-file $logofile --vout-filter distort --distort-mode gradient --extraintf telnet --telnet-host localhost --vlm-conf `pwd`/demo.vlm $input"
}

mosaic()
{
  echo -e "\n- Mosaic demo -\nconfiguration\n"
  echo -en "Please chose a background input.\nbackground input? "
  read bg
  echo -en "Please chose a video to blend.\nvideo? "
  read vid
  echo "new a broadcast enabled loop
setup a input $vid
setup a output #duplicate{dst=mosaic-bridge,select=video}
control a play" > "`pwd`/demo.vlm"
  echo "VLM batch file saved to `pwd`/demo.vlm"
  echo -e "\n$VLC --sub-filter mosaic:marq --marq-marque \"VLC - mosaic\" --marq-position 6 --mosaic-width 120 --mosaic-height 90 --mosaic-rows 1 --mosaic-cols 1 --mosaic-alpha 150 --extraintf telnet --telnet-host localhost --vlm-conf `pwd`/demo.vlm $bg"
}

opengl()
{
  echo -e "\n- OpenGL cube demo -\nconfiguration\n"
  echo -en "Please chose an input.\ninput? "
  read input
  echo -e "\n$VLC -V opengl --opengl-effect transparent-cube $input"
}

wall()
{
  echo -e "\n- Video wall demo -\nconfiguration\n"
  echo -en "Please chose an input.\ninput? "
  read input
  echo -en "Do you want to use rotated laptops/screens ?\n[y/N] "
  read rot
  case "$rot" in
    "y"|"Y"|"yes")
      echo -e "\nLeft hand side:\n$VLC --vout-filter wall:transform --transform-type 90 --wall-cols 2 --wall-rows 1 --wall-active 0 $input"
      echo -e "\nRight hand side:\n$VLC --vout-filter wall:transform --transform-type 90 --wall-cols 2 --wall-rows 1 --wall-active 1 --sub-filter marq --marq-marquee \"VLC - Video wall\" $input"
      ;;
    *)
      echo -e "\nLeft hand side:\n$VLC --vout-filter wall --wall-cols 2 --wall-rows 1 --wall-active 0 --sub-filter marq --marq-marquee \"VLC - Video wall\" $input"
      echo -e "\nRight hand side:\n$VLC --vout-filter wall --wall-cols 2 --wall-rows 1 --wall-active 1 $input"
      ;;
  esac
}

cat << EOF
VLC cool demos script
 1. psychedelic video filter
 2. gradient video filter
 3. mosaic
 4. OpenGL cube
 5. video wall
EOF

echo -n "demo number? "
read choice

case "$choice" in
 1) pyschedelic;;
 2) gradient;;
 3) mosaic;;
 4) opengl;;
 5) wall;;
 *) echo "Wrong answer ... try again"; exit 1;;
esac

echo -e "\nUse the previous command to run the demo."
echo "Note: make sure that you reset your preferences before running these demos."
