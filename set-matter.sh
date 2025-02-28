#!/bin/bash

ROOT_UID=0
THEME_DIR="/boot/grub/themes"
THEME_DIR_2="/boot/grub2/themes"
THEME_NAME=Matter

echo "Installing Matter grub theme..."

# Check command avalibility
function has_command() {
  command -v $1 > /dev/null
}

echo "Checking for root access..."

# Checking for root access and proceed if it is present
if [ "$UID" -eq "$ROOT_UID" ]; then

  # Create themes directory if not exists
  echo "Checking for the existence of themes directory..."
  [[ -d ${THEME_DIR}/${THEME_NAME} ]] && rm -rf ${THEME_DIR}/${THEME_NAME}
  [[ -d ${THEME_DIR_2}/${THEME_NAME} ]] && rm -rf ${THEME_DIR_2}/${THEME_NAME}
  [[ -d /boot/grub ]] && mkdir -p ${THEME_DIR}
  [[ -d /boot/grub2 ]] && mkdir -p ${THEME_DIR_2}

  # Copy theme
  echo "Installing ${THEME_NAME} theme..."
  [[ -d /boot/grub ]] && cp -a ${THEME_NAME} ${THEME_DIR}
  [[ -d /boot/grub2 ]] && cp -a ${THEME_NAME} ${THEME_DIR_2}

  # Set theme
  echo -e "Setting ${THEME_NAME} as default..."
  grep "GRUB_THEME=" /etc/default/grub 2>&1 >/dev/null && sed -i '/GRUB_THEME=/d' /etc/default/grub

  [[ -d /boot/grub ]] && echo "GRUB_THEME=\"${THEME_DIR}/${THEME_NAME}/theme.txt\"" >> /etc/default/grub
  [[ -d /boot/grub2 ]] && echo "GRUB_THEME=\"${THEME_DIR_2}/${THEME_NAME}/theme.txt\"" >> /etc/default/grub

  # Update grub config
  echo -e "Updating grub config..."
  if has_command update-grub; then
    update-grub
  elif has_command grub-mkconfig; then
    grub-mkconfig -o /boot/grub/grub.cfg
  elif has_command grub2-mkconfig; then
    grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
  fi

  echo "Done."

else
    echo "Failed. Are you root?"
fi
