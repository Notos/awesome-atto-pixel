#!/bin/bash

VERSION=1.0

### Decompress files to a folder named 'new'

function decompress() {
  UPDATE=$(pwd)/$2

  OLD="$ENIGMA2DIR/old-`date +%Y%m%d-%H%M%S`"

  if [ "$2" == "" ]; then
    echo Missing update file name
    exit 1
  fi

  if [ -d $NEW ]; then
      mv $NEW $OLD
  fi

  mkdir $NEW

  if [[ $UPDATE == *.tar.bz2 ]]; then
     COMMAND="tar xvfj"
  fi

  if [[ $UPDATE == *.tar.gz ]]; then
     COMMAND="tar xvfz"
  fi

  if [[ $UPDATE == *.zip ]]; then
     COMMAND="unzip x"
  fi

  if [[ $UPDATE == *.rar ]]; then
     COMMAND="unrar x"
  fi
  
  cd $NEW
  
  echo Changed to directory \"$(pwd)\"

  COMMAND="$COMMAND $UPDATE"

  echo Executing \"$COMMAND\"

  $COMMAND

  chown root:root -R $NEW
}

### Do a dist-upgrade

function distUpgrade() {
  echo Starting a dist-upgrade...
  echo 

  backupConf

  backupConf
  
  MOVETO="$ENIGMA2DIR/backup-enigma/`date +%Y%m%d-%H%M%S`"
  
  mkdir -p $MOVETO

  for filename in $NEW/*; do
    OLD_DIR=$(pwd)/$(basename $filename)
    
    echo "------------------------- $filename"   
    
    mv $OLD_DIR $MOVETO/
    
    mv $filename $(pwd)
    
    echo
  done
}

### Show program help screen

function help() {
  echo
  echo "enigma2-update (v $VERSION)"
  echo
  echo Usage:
  echo
  echo "  update-enigma2 <option>"
  echo
  echo Options:
  echo
  echo "  decompress <file>       - Decompress your enigma2 rootfs"
  echo "  dist-upgrade            - Full upgrade on your distribuition"
  echo "  update                  - Update your distribution"
  echo "  backup-conf             - Backup important config files"
  echo "  restore-conf            - Restore config"
  echo "  clean-root              - Delete all rootfs files"
  echo
  
  exit 1
}

### Backup important files

function backupConf() {
  shopt -s dotglob
  
  DIR="$ENIGMA2DIR/backup-conf/`date +%Y%m%d-%H%M%S`"
  
  mkdir -p $DIR

  rsync -aR --progress $CURDIR/etc/oscam/config/* $DIR/
  rsync -aR --progress $CURDIR/etc/enigma2/** $DIR/
  rsync -aR --progress $CURDIR/home/root/* $DIR/
  rsync -aR --progress $CURDIR/etc/scripts/* $DIR/
  rsync -aR --progress $CURDIR/picon/* $DIR/  
  rsync -aR --progress $CURDIR/etc/opkg/* $DIR/
}

### Check if files were decompressed

function checkDecompressed() {
  if [[ ! -d $NEW || "$(ls -A $NEW/)" == "" ]]; then
    echo "Directory $NEW is empty, please run decompress first"

    exit 0
  fi
}

### Restore configuration

function restoreConf() {
  echo not implemented
}

### Update enigma2

function update() {
  echo Starting a update...
  echo

  checkDecompressed

  backupConf

  rsync -a --progress $NEW/* $(pwd)/
}

### Clean the root dir, removing all files

function cleanRoot() {
  rm -rf $(pwd)/bin
  rm -rf $(pwd)/boot
  rm -rf $(pwd)/dev
  rm -rf $(pwd)/etc
  rm -rf $(pwd)/home
  rm -rf $(pwd)/lib
  rm -rf $(pwd)/media
  rm -rf $(pwd)/proc
  rm -rf $(pwd)/run
  rm -rf $(pwd)/sbin
  rm -rf $(pwd)/sys
  rm -rf $(pwd)/usr
  rm -rf $(pwd)/var
  rm $(pwd)/hdd
  rm $(pwd)/mnt
  rm $(pwd)/share
  rm $(pwd)/tmp
}

### Main app

function main() {
  CURDIR=$(pwd)

  ENIGMA2DIR=$CURDIR/Enigma2

  mkdir -p $ENIGMA2DIR

  if [ "$1" == "" ]; then
    help
  fi

  OPTION=$1

  UPDATE=$(pwd)/$1

  NEW=$ENIGMA2DIR/new

  if [ "$OPTION" == "decompress" ]; then
    decompress $@

    exit 0
  fi
  
  if [ "$OPTION" == "dist-upgrade" ]; then
    distUpgrade
    
    exit 0
  fi

  if [ "$OPTION" == "full" ]; then
    movetoroot
    
    exit 0
  fi

  if [ "$OPTION" == "backup-conf" ]; then
    backupConf
    
    exit 0
  fi

  if [ "$OPTION" == "restore-conf" ]; then
    restore
    
    exit 0
  fi

  if [ "$OPTION" == "update" ]; then
    update
    
    exit 0
  fi

  if [ "$OPTION" == "clean-root" ]; then
    cleanRoot

    exit 0
  fi
      
  echo Option \"$OPTION\" does not exists
  
  help
}

### Execute the main function

main $@
