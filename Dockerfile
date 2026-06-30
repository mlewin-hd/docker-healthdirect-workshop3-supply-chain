# Minimal image for the Workshop 3 end-to-end supply-chain pipeline.
# Uses a slim base — the single highest-value supply-chain fix from Lab 3.
FROM python:3.13-slim
WORKDIR /app
COPY app.py .
CMD ["python", "app.py"]
