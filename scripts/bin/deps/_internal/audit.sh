# Internal script: secure audit execution

log -ic "🛡️ " -m "Running $PACKAGE_MANAGER audit...\n"

if [ "$SILENT_MODE" = true ]; then
  $AUDIT_CMD > /dev/null 2>&1
else
  $AUDIT_CMD
  log -m "\n"
fi
