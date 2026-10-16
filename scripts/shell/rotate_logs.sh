#!/usr/bin/env bash
#
# Production Log Rotation and Retention Script
# Compresses uncompressed log files older than 7 days and purges archives older than 30 days.

set -euo pipefail
IFS=$'\n\t'

readonly LOG_DIR="${1:-/var/log/app}"
readonly RETENTION_COMPRESS_DAYS=7
readonly RETENTION_PURGE_DAYS=30

log_message() {
  local level="$1"
  local message="$2"
  printf '[%s] [%s] %s\n' "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" "${level}" "${message}"
}

main() {
  log_message "INFO" "Starting log rotation procedure on: ${LOG_DIR}"

  if [[ ! -d "${LOG_DIR}" ]]; then
    log_message "ERROR" "Target directory '${LOG_DIR}' does not exist."
    exit 1
  fi

  log_message "INFO" "Searching for .log files older than ${RETENTION_COMPRESS_DAYS} days to compress..."
  local files_to_compress=()
  while IFS= read -r -d $'\0' file; do
    files_to_compress+=("${file}")
  done < <(find "${LOG_DIR}" -maxdepth 2 -type f -name "*.log" -mtime +"${RETENTION_COMPRESS_DAYS}" -print0)

  if [[ ${#files_to_compress[@]} -gt 0 ]]; then
    for log_file in "${files_to_compress[@]}"; do
      log_message "INFO" "Compressing: ${log_file}"
      gzip -f "${log_file}"
    done
    log_message "INFO" "Successfully compressed ${#files_to_compress[@]} log file(s)."
  else
    log_message "INFO" "No .log files older than ${RETENTION_COMPRESS_DAYS} days found."
  fi

  log_message "INFO" "Searching for compressed archives (.gz) older than ${RETENTION_PURGE_DAYS} days to purge..."
  local deleted_count=0
  while IFS= read -r -d $'\0' archive; do
    log_message "INFO" "Purging expired archive: ${archive}"
    rm -f "${archive}"
    ((deleted_count++))
  done < <(find "${LOG_DIR}" -maxdepth 2 -type f -name "*.gz" -mtime +"${RETENTION_PURGE_DAYS}" -print0)

  log_message "INFO" "Purged ${deleted_count} archive(s) exceeding ${RETENTION_PURGE_DAYS}-day retention."
  log_message "INFO" "Log rotation finished successfully."
}

main "$@"
