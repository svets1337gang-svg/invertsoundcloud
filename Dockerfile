# Синтаксис Dockerfile 1
FROM python:3.12-slim

# ffmpeg обязателен для yt-dlp (конвертация в MP3 и встраивание обложки)
RUN apt-get update \
    && apt-get install -y --no-install-recommends ffmpeg \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Сначала зависимости — для кэширования слоя
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Затем код
COPY soundcloud_bot ./soundcloud_bot

# Временные файлы пишем в /tmp; кэш и подписки — в /data (том для персистентности).
# Подписки и кэш ДОЛЖНЫ переживать перезапуск контейнера — монтируйте том:
#   docker run -v sc-bot-data:/data ...
ENV WORK_DIR=/tmp PYTHONUNBUFFERED=1 \
    CACHE_DIR=/data/cache \
    SUBSCRIPTIONS_FILE=/data/subscriptions.json

RUN mkdir -p /data/cache

# Токен передаём через --env-file .env при запуске контейнера
CMD ["python", "-m", "soundcloud_bot.bot"]
