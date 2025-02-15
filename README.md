# Ollama Model Downloader

Lightning-fast model downloader for Ollama with `aria2c` multi-threaded acceleration.

## 🚀 Features

- **⚡ 3-5x Faster Downloads**: Utilizes `aria2c`'s segmented multi-threading for maximum speed.
- **⏯️ Resume Anytime**: Interrupted downloads can be resumed effortlessly with `Ctrl+C` and re-running the command.
- **📂 Seamless Ollama Integration**: Download models directly in Ollama's format with a single command, making them ready for immediate use.

---

## 🛠️ Usage Guide

### 1️⃣ Grant Execution Permission
Before using the script, grant execution permission:
```bash
chmod +x omdl.sh
```

### 2️⃣ Set Environment Variable `OLLAMA_MODELS`
Define the location for storing downloaded models. Replace `<your_model_path>` with your preferred directory.

```bash
export OLLAMA_MODELS=<your_model_path>
```
Generally, the default locations are: `~/.ollama/models`

For more details, refer to the official [Ollama FAQ](https://github.com/ollama/ollama/blob/main/docs/faq.md#where-are-models-stored).

### 3️⃣ Download a Model (Seamless with Ollama)
Easily fetch models in Ollama-compatible format:
```bash
./omdl.sh download model_name:tag
```
To increase the number of download threads (default: 4), use:
```bash
./omdl.sh download model_name:tag -x 10
```

### 4️⃣ Run the Downloaded Model
Once downloaded, the model is ready for use:
```bash
ollama run model_name:tag
```

### 5️⃣ Help Information
To view available commands and options:
```bash
./omdl.sh --help
```

#### Help Output:
```
Usage: ./omdl.sh <command> <model-name> [-x <threads>]
Commands:
  download - Download manifest and blobs
Options:
  -x <threads> - Set the number of `aria2c` threads (default: 4)
Environment Variables:
  OLLAMA_MODELS - Path for storing models (must be set before use)
                  Example: export OLLAMA_MODELS=<your_model_path>
Examples:
  ./omdl.sh download model_name:tag
  ./omdl.sh download model_name:tag -x 10
After download, run the model directly with: ollama run <model-name>
```

With Ollama Model Downloader, downloading and using models is now significantly faster! ⚡

