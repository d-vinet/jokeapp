if [[ -n $RCLONE_CONFIG_BASE_URL ]]; then
	echo "Rclone config detected"
     mkdir /root/.config && mkdir /root/.config/rclone && wget -O /root/.config/rclone/rclone.conf $RCLONE_CONFIG_BASE_URL
fi

if [[ -n $BOT_TOKEN && -n $OWNER_ID ]]; then
	echo "Bot token and owner ID detected"
	python3 config.py
fi

if [[ -n $CREDENTIALS_LINK ]]; then
	echo "credentials.json detected"
    wget $CREDENTIALS_LINK && drivedl set /app/credentials.json
fi

if [[ -n $ACCOUNTS_FOLDER_LINK ]]; then
	echo "accounts.zip detected"
    wget $ACCOUNTS_FOLDER_LINK && unzip accounts.zip -d accounts && rm *.zip
fi

echo "SETUP COMPLETED"

node server
