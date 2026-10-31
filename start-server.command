cd "$(dirname "$0")" || exit 1

PHP=/Applications/XAMPP/xamppfiles/bin/php
MYSQL=/Applications/XAMPP/xamppfiles/bin/mysql

if lsof -nP -iTCP:8000 -sTCP:LISTEN >/dev/null 2>&1; then
    echo "The server is already running on port 8000."
    echo "Open http://127.0.0.1:8000 in your browser. You can close this window."
    exit 0
fi

if ! "$MYSQL" -u root -e "SELECT 1" >/dev/null 2>&1; then
    echo "WARNING: MySQL is not running, so pages will show no data."
    echo "Open XAMPP > Manage Servers > MySQL Database > Start, then reload your page."
    echo
fi

echo "VaxAssist server running at http://127.0.0.1:8000"
echo "Keep this window open while you work. Close it (or press Ctrl+C) to stop the server."
echo
exec "$PHP" -S 127.0.0.1:8000 router.php