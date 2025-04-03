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

class GTTSRequest(BaseModel):
    text: str
    voice_language: str = "en"
    slow: bool = False

class EdgeTTSRequest(BaseModel):
    text: str
    voice_language: str = "en-US-JennyNeural"

def generate_filename():
    """Generate a unique filename."""
    return os.path.join(TEMP_DIR, f"{uuid.uuid4()}.mp3")

def generate_gtts(text, voice, slow):
    """Generate speech using gTTS."""
    file_path = generate_filename()
    tts = gTTS(text=text, lang=voice, slow=slow)
    tts.save(file_path)
    return file_path

async def generate_edge_tts(text, voice):
    """Generate speech using Edge TTS."""
    file_path = generate_filename()
    communicate = edge_tts.Communicate(text, voice)
    with open(file_path, "wb") as audio_buffer:
        async for chunk in communicate.stream():
            if chunk["type"] == "audio":
                audio_buffer.write(chunk["data"])
    return file_path

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

@app.post("/gtts")
def create_gtts_tts(request: GTTSRequest):
    """Generate TTS using gTTS and return the file path."""
    file_path = generate_gtts(request.text, request.voice_language, request.slow)
    return {"file_path": file_path}

@app.post("/edge")
async def create_edge_tts(request: EdgeTTSRequest):
    """Generate TTS using Edge TTS and return the file path."""
    file_path = await generate_edge_tts(request.text, request.voice_language)
    return {"file_path": file_path}
