# Running Ollama on a Pixel 9 Pro with Termux (No Root Required)

**Overview:** This guide will show you how to set up and run **Ollama** (a local LLM runner) on a Pixel 9 Pro using Termux (from F-Droid) without root. We’ll cover installation from the Termux User Repository (TUR), downloading a model, starting the Ollama server, exposing its API over your LAN, and securing access. We’ll also discuss performance limitations on Android and how to test the setup from another device.

## Installing Ollama in Termux (Termux User Repository)

Before installing Ollama, make sure you have the latest Termux from F-Droid (the Play Store version is outdated). Launch Termux and update packages:

```bash
pkg update && pkg upgrade -y
```

**Add the TUR repo and install Ollama:** The Termux User Repository (TUR) provides a pre-built Ollama package (so you don’t have to compile it yourself). Run the following in Termux:

```bash
pkg install tur-repo    # Add the community repository
pkg update              # Update package lists
pkg install -y ollama   # Install Ollama from TUR
```

This will download and install the Ollama binary and any dependencies. Once done, verify the installation by checking the version or help:

```bash
ollama --help           # Shows available commands if installation succeeded
ollama version          # Shows the version of Ollama installed
```

If the `ollama` command is not found, double-check that the TUR repo was added and try running `pkg update && pkg install ollama` again. Grant Termux storage permission (`termux-setup-storage`) if needed to ensure it can write model files. If you built Ollama manually, ensure the binary is executable (`chmod +x ollama`), but for TUR installs this shouldn’t be necessary.

## Downloading (Pulling) a Model with Ollama

Once Ollama is installed, you can **pull a model** from the Ollama library. The `ollama pull <model_name>` command will download a model locally. For example, to pull the Qwen3-14B model (14 billion parameters) you would run:

```bash
ollama pull qwen3:14b   # Downloads the Qwen3-14B model (~9 GB) if you have enough storage
```

*(Tip: If this model is too large or you just want to test, try a smaller model such as `qwen3:5b` or a 7B model. You can find model names on the [Ollama website](https://ollama.ai) or its documentation.)*

You should see Ollama begin downloading the model; this may take a long time for large models and requires sufficient storage (ensure you have multiple GBs free). After the download completes, use `ollama list` to verify the model is installed:

```bash
ollama list
```

The above command **displays all models you have installed locally**. For example, if Qwen3-14B was pulled successfully, it should appear in the list of models. This confirms that Ollama has the model ready to use.

*Note:* Models are typically stored in your Termux home directory (e.g. under `~/.ollama` or similar). Be mindful of your device’s storage limits. If space is low (ensure >5 GB free as a rule of thumb), consider using a smaller model or adding an SD card/OTG storage for Termux data.

## Running the Ollama Server in Termux

Ollama can run as a background service providing an HTTP API. To start the Ollama server, use the `ollama serve` command. In Termux, you have a few options to run this:

* **Foreground in a session:** Simply execute `ollama serve` in the Termux session. It will start the server and log output there (such as model loading messages).
* **Background process:** Add an ampersand (`&`) to run it in the background: `ollama serve &`. This will free your Termux prompt, but note that the process will keep running until you close Termux or kill it.
* **Multiple sessions:** Alternatively, open a new Termux session (swipe from left and tap “New Session”) and run `ollama serve` there, leaving it running, while using another session for other commands.

When you run `ollama serve`, if everything is working, Ollama will initialize and begin listening for API requests. By default, **Ollama binds to localhost (127.0.0.1) on port 11434**. This means the API is accessible only from the phone itself (Termux sessions or apps on the device). For example, you might see a log like “Server running on 127.0.0.1:11434”. If you try an Ollama command in another session without the server running, you’ll get an error (“could not connect to ollama app, is it running?”) – which simply means you need to start `ollama serve` first.

**Stopping the server:** If you need to stop Ollama, you can press **Ctrl+C** in the session where it’s running (if foreground). If it’s in the background, find its process with `ps` or `pgrep ollama` and kill it (`kill <PID>`). In a pinch, `pkill ollama` will terminate all Ollama processes.

**Keeping the service running:** Android may suspend Termux processes when the app is in background or the screen is off. To prevent this, you should disable battery optimizations for Termux (in Android Settings > Apps > Termux > Battery > *Allow background activity*). Additionally, Termux provides a `termux-wake-lock` utility to keep the CPU awake and prevent the device from sleeping. Run `termux-wake-lock` before starting the server to improve reliability for long-running sessions. (You’ll see a notification that Termux acquired a wakelock; you can release it with `termux-wake-unlock` or by closing Termux.)

## Exposing the Ollama HTTP API to Your LAN

By default, the Ollama server listens only on the loopback interface (`127.0.0.1`), which **prevents other devices from connecting**. To allow computers or other phones on your local network to reach the API, you need to make Ollama listen on the phone’s network interface (e.g. Wi-Fi IP address). We can do this by changing the bind address from `127.0.0.1` to `0.0.0.0` (all interfaces).

**Using OLLAMA\_HOST environment variable:** Ollama respects an environment variable `OLLAMA_HOST` to set the host and port for the server. We’ll use this to change the listening address. In Termux, run the server as follows:

```bash
export OLLAMA_HOST="0.0.0.0:11434"
ollama serve
```

This tells Ollama to bind to all interfaces on port 11434. You can verify it’s correctly set by running `echo $OLLAMA_HOST` (should output `0.0.0.0:11434`). When the server starts now, it should listen on the phone’s Wi-Fi IP as well. If you run `netstat -nlp` (with the `net-tools` package) or `ss -tlp`, you should see Ollama bound on `0.0.0.0:11434` instead of `127.0.0.1`.

**Finding your phone’s IP:** Ensure your Pixel 9 Pro is connected to Wi-Fi. Find its IP address on the LAN – you can use Termux: `ip addr show wlan0 | grep "inet "` or use Android’s Wi-Fi details. Suppose your phone’s IP is **192.168.1.100** (replace with your actual address).

Now any other device on the same network can reach the Ollama API at `http://192.168.1.100:11434`. For example, you could open a browser on another device and go to `http://192.168.1.100:11434/` – it should show a simple message (or potentially an empty response) indicating the server is up. The real functionality is via the API endpoints (like `/api/generate`, covered below).

> 💡 **Note:** Opening the bind address to `0.0.0.0` only makes the server accessible within your local network by default. This does **not** automatically expose it to the internet at large (that would require port forwarding on your router or using a VPN/Tunnel). We *strongly* advise against exposing it publicly without proper security.

## Securing Access to the Ollama API

Once the API is listening on `0.0.0.0`, **any device on your LAN can attempt to use your Ollama server** if they know the IP and port. By default, Ollama’s HTTP API has no authentication or encryption (it’s an HTTP server meant for local use). If your network is just your home and you trust all devices on it, this might be fine. But if you want to restrict or secure access, consider the options below:

### Restrict by IP (Interface Binding or Firewall)

One basic restriction is to only allow certain IP ranges. Since an unrooted Android can’t easily run `iptables` to filter traffic (Termux has no built-in firewall), you have limited options:

* **Bind to a specific IP:** Instead of `0.0.0.0`, you could bind Ollama to the phone’s specific LAN IP (e.g. `192.168.1.100:11434`). This still allows any device on that subnet to connect (since that IP is reachable by all in subnet), so it’s not a true restriction – it mainly prevents listening on other interfaces (like if your phone had cellular or VPN interfaces active). In most cases, `0.0.0.0` versus the specific IP makes no difference for LAN security.

* **Use Android firewall apps:** Apps like **NetGuard** (no-root firewall via VPN) or **AFWall+** (requires root) can block or allow connections. Termux itself doesn’t embed a firewall, but you can use a third-party firewall app to control traffic. For example, you might configure NetGuard to allow Termux’s traffic only from certain LAN IPs. This approach can be complex and might require advanced rules (NetGuard supports custom filter rules in its pro version, which could potentially filter by remote IP).

Given the above, many users opt for a simpler method: run a **reverse proxy** that can enforce authentication or IP allowlisting.

### Using a Reverse Proxy with Basic Authentication (Optional)

A lightweight reverse proxy like **Nginx** or **Caddy** can sit in front of Ollama. You would have Ollama continue listening on `127.0.0.1:11434` (the default) and have the proxy listen on `0.0.0.0` at a different port (or the same port with authentication). The proxy can then restrict access by IP or require a username/password to access the API.

For example, you can install Nginx in Termux (`pkg install nginx`) and set up a configuration to protect the Ollama API:

1. **Configure Nginx**: Edit the Nginx config (e.g. create a file `/data/data/com.termux/files/usr/etc/nginx/conf.d/ollama.conf`). Use something like:

   ```nginx
   server {
       listen 0.0.0.0:11435;  # Listen on port 11435 for LAN
       location / {
           # Allow only a specific IP (e.g. your PC), deny all others:
           allow 192.168.1.50;    # example allowed client IP
           deny  all;
           # Basic Auth protection:
           auth_basic "Ollama API";
           auth_basic_user_file /data/data/com.termux/files/usr/etc/nginx/.htpasswd;
           # Proxy to the Ollama server running on localhost
           proxy_pass http://127.0.0.1:11434;
       }
   }
   ```

   In the above:

   * Replace `192.168.1.50` with the IP of the device(s) you want to allow (you can include multiple `allow` lines). All others will be denied.
   * The `auth_basic` lines enable Basic HTTP Authentication. You need to create an `.htpasswd` file with a username and hashed password. For example, install **apache2-utils** in Termux to get the `htpasswd` command, then run `htpasswd -c /data/data/com.termux/files/usr/etc/nginx/.htpasswd <username>` and enter a password. This will generate a hashed password file for Nginx to use.

2. **Run Nginx**: Start the Nginx server with `nginx` (it will read the config and begin listening). Make sure Ollama is already running (`ollama serve` bound to localhost as usual). Now, other devices must connect to port 11435 and will be prompted for the username/password you set. Nginx will only proxy the request to Ollama if the client’s IP is allowed and credentials are correct.

This approach effectively secures the API – even if someone knows your IP and port, they either won’t get through the IP filter or will be challenged for a password. Users have reported success using Nginx with Basic Auth in front of Ollama. It’s a bit heavy to run two services, but Nginx on a modern phone for light use is typically fine.

*Alternatives:* Instead of Nginx, you could use **Caddy** (which has simpler config for basic auth) or even an SSH tunnel if you only need personal access (for instance, run `ssh -L 11434:127.0.0.1:11434 phone` from a PC to forward the port securely). There’s also the option of using a VPN like **Tailscale** to restrict access to your device from only your devices. Choose the method that fits your security needs and skill level. The key point is that **Ollama itself doesn’t have built-in auth or IP filtering** (as of now), so you need external measures for security.

## Testing the Setup from Another Device

Now that the Ollama server is running on your Pixel and (optionally) exposed to the LAN, let’s test it from a second device. You can use tools like **curl** or a simple Python script to call the API.

### Using curl

On a PC or another device on the same Wi-Fi, open a terminal and try a curl command to generate text from the model. For example:

```bash
curl -X POST http://192.168.1.100:11434/api/generate \
     -H "Content-Type: application/json" \
     -d '{ "model": "qwen3:14b", "prompt": "Hello, how are you?" }'
```

*(Replace `192.168.1.100` with your phone’s IP. If you set up Nginx on 11435 with auth, use that port and include `-u username:password` in the curl command for basic auth.)*

This curl POSTs a JSON payload to the `/api/generate` endpoint, specifying the model to use and a prompt. The Ollama server will process the request and stream back a response. According to the Ollama API docs, the generate endpoint returns the model’s text output. You should see the AI’s response in your terminal. For example, it might return something like:

```json
{"model": "qwen3:14b", "created_at": "...", "response": "I am doing well, thank you for asking!"}
```

*(The exact format may vary; it could stream partial results. If you see nothing for a while, the model might be loading or processing – large models on CPU can be *very* slow. For streaming output, adding `--no-buffer` to curl can help.)*

### Using a Python request

You can also test via Python (on another machine). For instance:

```python
import requests
url = "http://192.168.1.100:11434/api/generate"
payload = {"model": "qwen3:14b", "prompt": "Hello from another device."}
response = requests.post(url, json=payload)
print(response.text)
```

Make sure to adjust the URL/IP, and if you enabled authentication via proxy, supply the auth (e.g., `requests.post(url, json=payload, auth=('user','pass'))`). Running this script should print out the model’s answer to your prompt.

**Chat endpoint:** Ollama also offers a chat-style endpoint at `/api/chat` for multi-turn conversations. You would POST a JSON with a message list (roles “user”, “assistant”, etc.). For example, `{"model": "qwen3:14b", "messages": [ {"role":"user","content":"Hi"} ] }`. Testing that is similar with curl or Python.

If the remote calls succeed (you get a valid response or at least some output), congratulations – your Pixel 9 Pro is now acting as an AI API server on your LAN! 🎉

## Performance and Android Limitations

It’s important to set realistic expectations when running large models on a mobile device. A Pixel 9 Pro has a powerful CPU for a phone, but it’s still far slower than a desktop GPU. Here are some considerations:

* **CPU-only inference:** Ollama on Android (Termux) cannot use the phone’s GPU or NPUs for acceleration (Ollama currently only supports CUDA and ROCm for GPU acceleration on PC). This means all model computation is on the CPU cores. Generation will be **very slow** for large models. One user reported \~6–10 tokens per second with a 1.5B-parameter model on a Snapdragon 7+ Gen3 phone (12 GB RAM). A 14B model is **orders of magnitude heavier** – expect less than 1 token/sec, potentially a several-second pause per token.

* **Heat and battery:** Running these models will max out your CPU. It’s common to see \~1000% CPU usage (all cores at full tilt). The phone **will get hot** and battery will drain quickly. It’s advisable to keep the phone on a charger and ensure proper ventilation when doing longer runs. Throttling may occur if the device overheats, slowing down performance further.

* **Memory constraints:** The Pixel 9 Pro likely has 12 GB RAM. A 14B model (especially if not highly quantized) can consume close to that in memory. Ollama models are often quantized (e.g., 4-bit), but even then, 14B parameters at 4-bit is \~7 GB, plus overhead. It should fit, but running near memory limits can cause **out-of-memory crashes** or Android killing the Termux app. If you encounter issues, try a smaller model (7B or 5B). In general, models above 7B are probably pushing the limits of a phone’s CPU and RAM.

* **Model capability:** Smaller models (2–7B) can handle basic tasks (summaries, simple Q\&A), but will struggle with complex reasoning or code generation. As one Termux user noted, tiny models (1–2B) are “nearly useless for complex tasks” on mobile hardware, and even 7B models have limited capability in that environment. Don’t expect ChatGPT-level performance from a 7B running on a phone – the hardware and model size impose real limits.

* **Android process lifetime:** Remember that if you leave Termux (or the phone goes to deep sleep), the Ollama server might be paused or killed despite our precautions. Using `termux-wake-lock` and disabling battery optimization greatly helps, but Android may still terminate the process if the system is under pressure. Monitor the Termux session if you rely on it continuously, or consider using an Android foreground service (there are third-party apps that can wrap Termux commands as persistent services).

* **Storage and I/O:** Loading a large model from storage can take time (especially from an SD card). The first request to a model might include a long load time. Keep an eye on Termux logs when you send a request – you may see a model loading message. Subsequent uses will be faster until you restart the server.

In summary, running Ollama on a Pixel 9 Pro is an impressive feat – you can have a local AI assistant on your phone – but it comes with trade-offs in speed and practicality. For experimentation, it’s fantastic, but for heavy use or large models, you might still prefer running them on a PC/server and querying from your phone. Nonetheless, with the steps above, you **have a full Ollama setup on Android**, reachable over your LAN, and optionally protected for safe use. Enjoy exploring local LLMs on your phone!

**Sources:**

* Reddit – *Termux: Build Ollama on Termux Natively (No Proot Required)*
* ItsFOSS – *Must-Know Ollama Commands* (usage of pull, list, serve)
* Ollama Documentation – *REST API and Usage*
* Atlassc Tech Blog – *Sharing Ollama Server via IP* (changing bind address)
* Termux Wiki / Samgalope.dev – *Termux Security* (firewall limitations)
* Reddit – *Securing Ollama server* (Nginx basic auth recommendation)
* Ivon’s Blog – *Ollama on Android* (CPU-only performance note)
