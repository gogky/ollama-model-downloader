🚀 **Ollama-Aria2c-Downloader**: Lightning-fast model downloader for Ollama with aria2c multi-threaded acceleration

### Key Features
- ⚡ **3-5x Faster** downloads using aria2c's segmented multi-threading
- 🔧 **CLI-Driven** workflow: `get` manifests & `download` blobs in one command
- 🐧 **Zero-Runtime-Overhead**: Pure Bash implementation (No Python/Node dependency)
- 🧠 **Ollama-Optimized**: Automatic digest parsing & registry.ollama.ai integration
- 🛠️ **Pro Config**: Thread control (`-x 16`), path customization (`$OLLAMA_MODELS`)

### Usage Showcase
```bash
# Download llama3 with 12 threads
odac.sh download llama3:latest -x 12

# Generate download URLs only
odac.sh get codellama:7b
