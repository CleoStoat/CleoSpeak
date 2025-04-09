from fastapi.responses import StreamingResponse
import io
from fastapi import FastAPI
from pydantic import BaseModel
from gtts import gTTS
import edge_tts
import asyncio
import os
import uuid

# Create a directory for temporary audio files
TEMP_DIR = "temp_audio"
os.makedirs(TEMP_DIR, exist_ok=True)

app = FastAPI()

class TTSRequest(BaseModel):
    text: str
    voice_provider: str
    voice_language: str
    slow: bool = False


@app.get("/gtts/voice_languages")
def list_gtts_voice_languages():
    """Return available languages for gTTS."""
    from gtts.langs import _langs as gtts_languages
    return {"voice_languages": gtts_languages}

@app.get("/edge/voice_languages")
async def list_edge_voice_languages():
    """Return available Edge TTS voices."""
    voices = await edge_tts.list_voices()
    return {"voice_languages": voices}


@app.post("/generate")
async def create_tts(request: TTSRequest):
    
    if request.voice_provider == "gtts":
        mp3_fp = io.BytesIO()
        tts = gTTS(text=request.text, lang=request.voice_language, slow=request.slow)
        tts.write_to_fp(mp3_fp)
        mp3_fp.seek(0)
        return StreamingResponse(mp3_fp, media_type="audio/mpeg")
    
    elif request.voice_provider == "edge":
        mp3_fp = io.BytesIO()
        communicate = edge_tts.Communicate(request.text, request.voice_language)
        async for chunk in communicate.stream():
            if chunk["type"] == "audio":
                mp3_fp.write(chunk["data"])
        mp3_fp.seek(0)
        return StreamingResponse(mp3_fp, media_type="audio/mpeg")

@app.get("/health")
def health_check():
    return {"status": "ok"}