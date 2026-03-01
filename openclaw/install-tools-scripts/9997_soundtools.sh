#! /bin/bash

apt-get install portaudio19-dev

pipx install --global --system-site-packages funasr
pipx runpip --global funasr install numpy pyyaml opt-einsum optree fsspec jinja2 networkx soundfile librosa pyaudio
pipx runpip --global funasr install torch torchaudio --index-url=https://mirrors.aliyun.com/pytorch-wheels/cpu --find-links=https://mirrors.aliyun.com/pytorch-wheels/cpu

mkdir -p /.models
hf download funasr/fsmn-vad \
    --local-dir /.models/funasr/fsmn-vad
hf download FunAudioLLM/SenseVoiceSmall \
    --local-dir /.models/FunAudioLLM/SenseVoiceSmall
rm -rf /.models/FunAudioLLM/SenseVoiceSmall/requirements.txt

cat << 'EOF' > /usr/local/bin/asr
#!/opt/pipx/venvs/funasr/bin/python
"""
asr - Speech recognition using FunASR + SenseVoiceSmall

Supports: Chinese, Japanese, Korean, English, Cantonese

Model download (one-time setup):
  git lfs install
  git clone https://huggingface.co/FunAudioLLM/SenseVoiceSmall /path/to/SenseVoiceSmall
  git clone https://huggingface.co/funasr/fsmn-vad /path/to/fsmn-vad

Usage:
  asr --file audio.wav              # transcribe an audio file
  asr --duration 8                  # record from mic for 8 seconds and transcribe
  asr --lang ja                     # force Japanese (default: auto-detect)
  asr --model /path/to/model        # override default model path
  asr --vad   /path/to/fsmn-vad    # override default VAD model path
  asr --count 3                     # repeat mic recording 3 times (default: 1)
"""

import argparse
import logging
import os
import sys
import tempfile
import time
import wave

# ---------------------------------------------------------------------------
# Default model paths — edit these to match your local setup
# ---------------------------------------------------------------------------
DEFAULT_MODEL_PATH = "/.models/FunAudioLLM/SenseVoiceSmall"
DEFAULT_VAD_PATH   = "/.models/funasr/fsmn-vad"

# ---------------------------------------------------------------------------
# Logging: INFO and above → stderr only; stdout is reserved for transcripts
# ---------------------------------------------------------------------------
logging.basicConfig(
    stream=sys.stderr,
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%H:%M:%S",
)
log = logging.getLogger("asr")

def _fd_silence():
    devnull = os.open(os.devnull, os.O_WRONLY)
    saved = (os.dup(1), os.dup(2))
    os.dup2(devnull, 1)
    os.dup2(devnull, 2)
    os.close(devnull)
    return saved

def _fd_restore(saved):
    os.dup2(saved[0], 1); os.close(saved[0])
    os.dup2(saved[1], 2); os.close(saved[1])


# ---------------------------------------------------------------------------
# Suppress noisy third-party loggers that write to stdout/stderr by default
# ---------------------------------------------------------------------------
for _noisy in ("funasr", "modelscope", "torch", "urllib3"):
    logging.getLogger(_noisy).setLevel(logging.WARNING)


def load_model(model_path: str, vad_path: str):
    """Load SenseVoiceSmall and fsmn-vad from local paths."""
    for label, path in [("ASR model", model_path), ("VAD model", vad_path)]:
        if not os.path.isdir(path):
            log.error("%s path does not exist: %s", label, path)
            log.error(
                "Download with:\n"
                "  git lfs install\n"
                "  git clone https://huggingface.co/FunAudioLLM/SenseVoiceSmall %s\n"
                "  git clone https://huggingface.co/funasr/fsmn-vad %s",
                DEFAULT_MODEL_PATH,
                DEFAULT_VAD_PATH,
            )
            sys.exit(1)

    log.info("Loading ASR model from: %s", model_path)
    log.info("Loading VAD model from: %s", vad_path)

    _saved_fds = _fd_silence()
    from funasr import AutoModel
    model = AutoModel(
        model=model_path,
        trust_remote_code=True,
        vad_model=vad_path,
        vad_kwargs={"max_single_segment_time": 30000},  # max VAD segment: 30s
        device="cpu",
        disable_update=True,
    )
    _fd_restore(_saved_fds)

    log.info("Models loaded successfully")
    return model


def transcribe(model, audio_path: str, language: str = "auto") -> str:
    """Run inference on an audio file and return the transcript string."""
    from funasr.utils.postprocess_utils import rich_transcription_postprocess

    log.info("Transcribing: %s (lang=%s)", audio_path, language)
    t0 = time.time()

    res = model.generate(
        input=audio_path,
        cache={},
        language=language,
        use_itn=True,        # inverse text normalization: formats numbers, dates, adds punctuation
        batch_size_s=60,     # dynamic batching window in seconds (30-60 recommended for CPU)
        merge_vad=True,      # merge short VAD segments to reduce fragmentation
        merge_length_s=15,   # merge threshold in seconds
    )

    elapsed = time.time() - t0
    text = rich_transcription_postprocess(res[0]["text"])
    log.info("Done in %.2fs", elapsed)
    return text


def record_mic(duration: int, sample_rate: int = 16000) -> str:
    """Record audio from the default microphone and save to a temp WAV file."""
    try:
        import pyaudio
    except ImportError:
        log.error("pyaudio is not installed. Run: pip install pyaudio")
        sys.exit(1)

    CHUNK    = 1024
    FORMAT   = pyaudio.paInt16
    CHANNELS = 1

    p = pyaudio.PyAudio()
    stream = p.open(
        format=FORMAT,
        channels=CHANNELS,
        rate=sample_rate,
        input=True,
        frames_per_buffer=CHUNK,
    )

    log.info("Recording for %ds ...", duration)
    frames = []
    for _ in range(int(sample_rate / CHUNK * duration)):
        frames.append(stream.read(CHUNK))

    stream.stop_stream()
    stream.close()
    p.terminate()
    log.info("Recording complete")

    tmp = tempfile.NamedTemporaryFile(suffix=".wav", delete=False)
    with wave.open(tmp.name, "wb") as wf:
        wf.setnchannels(CHANNELS)
        wf.setsampwidth(p.get_sample_size(FORMAT))
        wf.setframerate(sample_rate)
        wf.writeframes(b"".join(frames))

    return tmp.name


def main():
    parser = argparse.ArgumentParser(
        prog="asr",
        description="Transcribe speech using FunASR SenseVoiceSmall (CPU).",
    )
    parser.add_argument(
        "--file", metavar="PATH",
        help="Audio file to transcribe (wav/mp3/flac/…). "
             "Mutually exclusive with --duration.",
    )
    parser.add_argument(
        "--duration", metavar="SECS", type=int,
        help="Record from microphone for this many seconds, then transcribe.",
    )
    parser.add_argument(
        "--count", metavar="N", type=int, default=1,
        help="Number of mic recordings to perform (default: 1). "
             "Only meaningful with --duration.",
    )
    parser.add_argument(
        "--lang", default="auto",
        choices=["auto", "zh", "en", "ja", "ko", "yue"],
        help="Language hint (default: auto). "
             "auto=detect, zh=Chinese, en=English, ja=Japanese, ko=Korean, yue=Cantonese.",
    )
    parser.add_argument(
        "--model", default=DEFAULT_MODEL_PATH, metavar="PATH",
        help=f"Path to local SenseVoiceSmall model (default: {DEFAULT_MODEL_PATH}).",
    )
    parser.add_argument(
        "--vad", default=DEFAULT_VAD_PATH, metavar="PATH",
        help=f"Path to local fsmn-vad model (default: {DEFAULT_VAD_PATH}).",
    )

    args = parser.parse_args()

    # Validate mutually exclusive options
    if args.file and args.duration:
        parser.error("--file and --duration are mutually exclusive")
    if not args.file and not args.duration:
        parser.error("one of --file or --duration is required")

    model = load_model(args.model, args.vad)

    if args.file:
        if not os.path.exists(args.file):
            log.error("File not found: %s", args.file)
            sys.exit(1)
        text = transcribe(model, args.file, language=args.lang)
        print(text)

    else:
        for i in range(args.count):
            if args.count > 1:
                log.info("Recording %d/%d", i + 1, args.count)
            tmp_path = record_mic(args.duration)
            text = transcribe(model, tmp_path, language=args.lang)
            os.unlink(tmp_path)
            print(text)


if __name__ == "__main__":
    main()
EOF
chmod a+x /usr/local/bin/asr