OUTPUT="$(flutter analyze)"
echo "$OUTPUT"
echo
if grep -q "error •" echo "$OUTPUT"; then
    echo "Flutter analyze found errors"
    exit 1
else
    echo "Flutter analyze didn't find any errors"
    exit 0
fi