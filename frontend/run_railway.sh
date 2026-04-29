#!/usr/bin/env bash
# Lanza Flutter apuntando al backend desplegado en Railway (production).
# Backend URL: https://backend-production-b48ab.up.railway.app
# Uso: bash run_railway.sh [device-id]
#   Sin argumento → corre en el primer dispositivo disponible (Android físico si está conectado)
#   Ejemplo: bash run_railway.sh windows

DEVICE=${1:-"HQ7TPR994PDQAIBE"}

flutter run \
  --device-id "$DEVICE" \
  --dart-define=API_BASE_URL=https://backend-production-b48ab.up.railway.app/api/v1 \
  --dart-define=SOCKET_URL=https://backend-production-b48ab.up.railway.app
