#!/bin/bash

clear
echo "🌐 GHOSTTRACK – GLOBAL OBSERVER FRAMEWORK"
echo "-----------------------------------------"
echo "1) 🌱 AgroWatch"
echo "2) 🛰️ OrbitalWatch"
echo "3) 🏔️ SportExtreme"
echo "4) 🚨 SOS Beacon"
echo "5) 📡 Starlink Geo-Sentinel"
echo "6) 🔭 BOINC Node"
echo "0) ❌ Esci"
echo "-----------------------------------------"
read -p "Seleziona un modulo: " choice

case $choice in
  1) bash modules/AgroWatch/AgroWatch.sh ;;
  2) bash modules/OrbitalWatch/OrbitalWatch.sh ;;
  3) bash modules/SportExtreme/SportExtreme.sh ;;
  4) bash modules/SOSBeacon/SOSBeacon.sh ;;
  5) bash modules/StarlinkNode/StarlinkNode.sh ;;
  6) bash modules/BOINCNode/BOINCNode.sh ;;
  0) exit ;;
  *) echo "Scelta non valida." ;;
esac
