ollama-model-downloader: Lightning-fast model downloader for Ollama with aria2c multi-threaded acceleration
🚀 3-5x Faster downloads using aria2c's segmented multi-threading

# Usage Guide

## 1. Grant Execution Permission
First, you need to grant execution permission to the script `omdl.sh`.
```bash
chmod +x omdl.sh
```

## 2. Configure Environment Variable `OLLAMA_MODELS`
Before running the script, set the `OLLAMA_MODELS` variable to store the downloaded models. The default path is usually `~/.ollama/models`.

Refer to the official documentation [Ollama FAQ](https://github.com/ollama/ollama/blob/main/docs/faq.md#where-are-models-stored) for more details.

```bash
export OLLAMA_MODELS=~/.ollama/models
```

## 3. Run the Script

### Get Model Information (manifest and blob URLs)
```bash
./omdl.sh get model_name:tag
```

### Download Model
```bash
./omdl.sh download model_name:tag
```
If you want to specify the number of download threads (default is 8 threads), use the `-x` option:
```bash
./omdl.sh download model_name:tag -x 10
```

## 4. Run the Model
Once the download is complete, you can run the model directly:
```bash
ollama run model_name:tag
```

## 5. Help Information
To view help information, run:
```bash
./omdl.sh --help
```

The help message is as follows:
```
Usage: ./omdl.sh <command> <model-name> [-x <threads>]
Commands:
  get      - Get manifest and blob URLs
  download - Download manifest and blobs
Options:
  -x <threads> - Specify the number of threads for aria2c (default is 8)
Environment Variables:
  OLLAMA_MODELS - Path to store the downloaded models (must be set before running the script)
                  Example: export OLLAMA_MODELS=~/.ollama/models
Examples:
  ./omdl.sh get model_name:tag
  ./omdl.sh download model_name:tag
  ./omdl.sh download model_name:tag -x 10
After model download is complete, you can directly run: ollama run <model-name>
```

