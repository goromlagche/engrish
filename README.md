![image](https://github.com/user-attachments/assets/cf40cf76-1472-4f41-89fd-eb3687ee4e85)


# ✍️ Writing Assistant (Ollama-powered)

A minimal writing assistant that enhances your texts with a single hotkey and local LLM processing.

---

## 🧠 Why I Built This
My writing skills are less than ideal, so I rely heavily on ChatGPT for most of my writing.
I developed this little tool using [Ollama](https://ollama.com) so I can just **press a hotkey (mod + x)** to fix my text, then **Ctrl + V** to paste the improved version.

No browser, no ChatGPT tab, no distraction — just instant local help.

---

## 🚀 How It Works

1. **Select** any text (e.g. with mouse or keyboard)
2. **Press `mod + x`** (configured in Sway)
3. Your text is sent to an LLM (e.g., `mistral:7b-instruct`) via a Ruby script in Docker
4. The improved version is **copied back to your clipboard**
5. **Paste** (`Ctrl+V`) anywhere — improved writing, instantly

---

## ⚙️ Architecture

- **Wayland clipboard tools**: `wl-paste`, `wl-copy`
- **Hotkey daemon**: `sway`
- **Shell script**: Captures clipboard → triggers Docker
- **Docker container**:
  - Ruby script reads input
  - Sends to Ollama API
  - Writes improved text to shared output file
- **Clipboard updated** with improved result

---

## 🐳 Docker Setup

- Uses [`ollama/ollama`](https://hub.docker.com/r/ollama/ollama) for local LLM server
- Writing assistant runs in separate container
- Communication happens through two shared files:
  - `/tmp/shared_input.txt`
  - `/tmp/shared_output.txt`

---

## 🧩 Requirements

- Wayland (tested on Sway WM)
- `wl-clipboard` (`wl-copy`, `wl-paste`)
- `notify-send` (optional, for desktop feedback)
- `docker` + `docker-compose`
- [Ollama](https://ollama.com) (automatically started via Docker)

---

## 🔑 Hotkey Setup

### Sway (in `~/.config/sway/config`)

```ini
bindsym $mod+x exec --no-startup-id /home/you/path/to/hotkey_runner.sh
````

### Or with `sxhkd` (in `~/.config/sxhkd/sxhkdrc`)

```ini
super + x
    bash /home/you/path/to/hotkey_runner.sh
```

---

## 📁 File Structure

```
.
├── docker-compose.yml
├── Dockerfile
├── writing_assistant.rb     # LLM processing in Ruby
├── hotkey_runner.sh         # Clipboard + file interface
```

---

## 📦 Model Used

Default: [`mistral:7b-instruct`](https://ollama.com/library/mistral)
You can change the model in the `OLLAMA_MODEL` environment variable.

---

## 🛡️ Security & Permissions

* Container runs as non-root (UID 1000)
* Files are pre-created with correct ownership
* Clipboard access and file I/O are host-controlled

---

## 💬 Example Workflow

1. Select and copy: `My english is bad`
2. Press hotkey (`mod + x`)
3. Press `Ctrl+V`
4. Pasted: `My English needs improvement.` ✅

---

## 🧠 Local, Private, and Fast

* 💻 **Runs entirely offline**
* 🔒 **No API keys or data leakage**
* ⚡ **Fast, single-purpose, and distraction-free**

---

## 📜 License

MIT — free to use, share, and modify.

---

## 🙏 Credits

Built with ❤️ for all non-native English speakers using Linux + Wayland.

