#!/bin/bash

# StarHunt Terminal Game Installer — Randomized Sectors Version

BASE_DIR="starhunt"

STARS=(
  "Sirius" "Canopus" "Rigil_Kentaurus" "Arcturus"
  "Vega" "Capella" "Rigel" "Procyon"
  "Achernar" "Betelgeuse" "Hadar" "Altair"
  "Acrux" "Aldebaran" "Antares" "Spica"
  "Pollux" "Fomalhaut" "Deneb" "Mimosa"
)

EXTENSIONS=(".tx" ".l" ".dat" ".fg" ".fo")

encode_base64() { echo -n "$1" | base64; }
encode_rot13() { echo "$1" | tr 'A-Za-z' 'N-ZA-Mn-za-m'; }
reverse_string() { echo "$1" | rev; }

mkdir -p "$BASE_DIR/results"
mkdir -p "$BASE_DIR/starmap"

cat << EOF > "$BASE_DIR/README.txt"
🚀 Місія StarHunt: Відновлення Зоряної Карти

Ви — дослідник міжгалактичного флоту. Система навігації пошкоджена, і ваша зоряна карта втрачена. 
Ваше завдання — знайти 20 найяскравіших зірок, захованих у файловій системі. 

Кожна зірка має індекс яскравості. Зібрані дані записуйте у файл: results/my_star_road.txt

Успіхів, досліднику!
EOF

# Перемішати зірки
SHUFFLED_STARS=( $(shuf -e "${STARS[@]}") )

for SECTOR in {1..5}; do
  mkdir -p "$BASE_DIR/starmap/sector_$SECTOR"

  STAR_COUNT=0
  for j in {1..4}; do
    IDX=$(( (SECTOR-1)*4 + j - 1 ))
    STAR="${SHUFFLED_STARS[$IDX]}"
    EXT=${EXTENSIONS[$RANDOM % ${#EXTENSIONS[@]}]}

    STAR_COUNT=$((STAR_COUNT + 1))

    case $SECTOR in
      1)
        echo "Зірка: $STAR" > "$BASE_DIR/starmap/sector_$SECTOR/star_${STAR_COUNT}$EXT"
        ;;
      2)
        echo "$(encode_rot13 "$STAR")" > "$BASE_DIR/starmap/sector_$SECTOR/star_${STAR_COUNT}$EXT"
        ;;
      3)
        echo "$(encode_base64 "$STAR")" > "$BASE_DIR/starmap/sector_$SECTOR/star_${STAR_COUNT}$EXT"
        ;;
      4)
        TMPDIR=$(mktemp -d)
        FILENAME="file_${STAR_COUNT}$EXT"
        if [ $((STAR_COUNT % 2)) -eq 0 ]; then
          echo "$(encode_base64 "$STAR")" > "$TMPDIR/$FILENAME"
        else
          echo "$(encode_rot13 "$STAR")" > "$TMPDIR/$FILENAME"
        fi
        tar -czf "$BASE_DIR/starmap/sector_$SECTOR/pack_${STAR_COUNT}.tar.gz" -C "$TMPDIR" "$FILENAME"
        rm -r "$TMPDIR"
        ;;
      5)
        if [ "$STAR_COUNT" -eq 1 ]; then
          HIDDEN_DIR_NAME=".$(tr -dc a-z0-9 </dev/urandom | head -c 8)"
          HIDDEN_DIR="$BASE_DIR/starmap/sector_$SECTOR/$HIDDEN_DIR_NAME"
          mkdir -p "$HIDDEN_DIR"

          TMPD=$(mktemp -d)
          for k in {1..4}; do
            STAR_NAME="${SHUFFLED_STARS[$((16 + k - 1))]}"
            FNAME=".$(tr -dc a-z </dev/urandom | head -c 6).txt"
            echo "$STAR_NAME" > "$TMPD/$FNAME"
          done

          tar -czf "$HIDDEN_DIR/.stars_hidden.tar.gz" -C "$TMPD" .
          rm -r "$TMPD"
        fi
        ;;
    esac
  done
done

# Create results file
touch "$BASE_DIR/results/my_star_road.txt"

echo "StarHunt розгорнуто у: $BASE_DIR"
echo "Запусти гру з: cd $BASE_DIR && cat README.txt"
