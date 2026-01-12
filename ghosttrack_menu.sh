#!/data/data/com.termux/files/usr/bin/bash

while true; do
    clear
    echo "========================================="
    echo "      🌌 GHOSTTRACK NODE PRAGONE"
    echo "========================================="
    echo ""
    echo " 0) MASTER RITUAL (A → Z)"
    echo " 1) Omega Ritual"
    echo " 2) Telemetry Ritual"
    echo " 3) Full Ritual"
    echo " 4) Repair Ritual"
    echo " 5) Visualizza Telemetria"
    echo " 6) Visualizza Stato Git"
    echo " 7) Esci"
    echo ""
    read -p "Seleziona un'opzione: " choice

    case $choice in
        0) ./ghosttrack_master.sh ;;
        1) ./ghosttrack_omega_ritual.sh ;;
        2) ./ghosttrack_telemetry_ritual.sh ;;
        3) ./ghosttrack_full_ritual.sh ;;
        4) ./ghosttrack_repair.sh ;;
        5) cat docs/telemetry.json | jq . ;;
        6) git status ;;
        7) exit 0 ;;
        *) echo "Opzione non valida." ;;
    esac

    echo ""
    read -p "Premi Invio per continuare..."
done
