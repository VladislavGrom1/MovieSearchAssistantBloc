#!/bin/sh
# Сверяет экраны с @RoutePage() с тем, что лежит в app_router.gr.dart.
#
# Ловит устаревшую кодогенерацию: экран переименован или удалён, а .gr.dart
# не перегенерирован. Именно так проект однажды собирался только благодаря
# закоммиченному маршруту UserAuthenticationRoute, пока экран уже назывался
# OnboardingScreen.

set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GENERATED="$ROOT/lib/app/router/app_router.gr.dart"

if [ ! -f "$GENERATED" ]; then
  echo "check_routes_sync: не найден $GENERATED"
  exit 1
fi

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# Экраны, объявленные через @RoutePage(), во всём lib/, кроме сгенерированных
# файлов.
find "$ROOT/lib" -name '*.dart' ! -name '*.gr.dart' -exec awk '
  /@RoutePage\(\)/ { pending = 1; next }
  pending && /^[[:space:]]*class[[:space:]]+/ {
    name = $0
    sub(/^[[:space:]]*class[[:space:]]+/, "", name)
    sub(/[^A-Za-z0-9_].*$/, "", name)
    print name
    pending = 0
    next
  }
  pending && /^[[:space:]]*[^[:space:]\/]/ { pending = 0 }
' {} + | LC_ALL=C sort -u > "$tmp/pages"

# Экраны, на которые ссылается сгенерированный файл: перед каждым классом
# маршрута auto_route пишет док-комментарий «/// [_i3.CollectionFilmsScreen]».
awk '
  /^\/\/\/ \[_i[0-9]+\./ {
    page = $0
    sub(/^.*\[_i[0-9]+\./, "", page)
    sub(/\].*$/, "", page)
    next
  }
  /^class [A-Za-z0-9_]+/ {
    if ($2 ~ /Route$/ && page != "") print page
    page = ""
  }
' "$GENERATED" | LC_ALL=C sort -u > "$tmp/routes"

status=0

missing="$(comm -23 "$tmp/pages" "$tmp/routes")"
if [ -n "$missing" ]; then
  echo "check_routes_sync: у этих экранов нет маршрута в app_router.gr.dart:"
  echo "$missing" | sed 's/^/  /'
  echo "  → перегенерируйте маршруты (порядок — в комментарии pubspec.yaml)"
  status=1
fi

stale="$(comm -13 "$tmp/pages" "$tmp/routes")"
if [ -n "$stale" ]; then
  echo "check_routes_sync: app_router.gr.dart ссылается на отсутствующие экраны:"
  echo "$stale" | sed 's/^/  /'
  echo "  → перегенерируйте маршруты (порядок — в комментарии pubspec.yaml)"
  status=1
fi

if [ "$status" -eq 0 ]; then
  count="$(wc -l < "$tmp/pages" | tr -d ' ')"
  echo "check_routes_sync: маршруты совпадают с экранами ($count шт.)"
fi

exit "$status"
