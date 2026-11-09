#!/bin/sh
# Проверяет, что в lib/ не используются синонимы, которые GLOSSARY.md
# запрещает. Список пар «запрещено|замена» лежит в scripts/vocabulary.txt.
#
# Поиск регистрозависимый: -i не сворачивает кириллицу вне UTF-8 локали,
# поэтому слова в списке пишутся так, как они встречаются в тексте.

set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LIST="$ROOT/scripts/vocabulary.txt"

if [ ! -f "$LIST" ]; then
  echo "check_vocabulary: не найден $LIST"
  exit 1
fi

status=0

while IFS='|' read -r banned replacement; do
  case "$banned" in
    ''|'#'*) continue ;;
  esac

  set +e
  hits="$(grep -rnF --include='*.dart' -- "$banned" "$ROOT/lib")"
  code=$?
  set -e

  case "$code" in
    0)
      echo "check_vocabulary: «$banned» запрещён глоссарием — используйте «$replacement»"
      echo "$hits" | sed "s|$ROOT/||" | sed 's/^/  /'
      status=1
      ;;
    1)
      ;;
    *)
      echo "check_vocabulary: grep не смог проверить «$banned» (код $code)"
      exit 1
      ;;
  esac
done < "$LIST"

if [ "$status" -eq 0 ]; then
  echo "check_vocabulary: запрещённых синонимов нет"
fi

exit "$status"
