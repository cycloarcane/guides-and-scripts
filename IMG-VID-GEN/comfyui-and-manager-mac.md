# Installing ComfyUI & ComfyUI Manager

This guide provides a simple and efficient method for installing ComfyUI and ComfyUI Manager on macOS.

---

## Installing ComfyUI on macOS

1. **Clone the Repository**
   ```bash
   git clone https://github.com/comfyanonymous/ComfyUI.git
   cd ComfyUI
   ```

2. **Create a Virtual Environment & Install Dependencies**
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

3. **Run ComfyUI**
   ```bash
   python main.py
   ```

---

## Installing ComfyUI Manager

### Method 1: Cloning into the Custom Nodes Directory

1. **Navigate to the Custom Nodes Directory**
   ```bash
   cd ComfyUI/custom_nodes
   ```
2. **Clone the Repository**
   ```bash
   git clone https://github.com/ltdrdata/ComfyUI-Manager.git
   ```
3. **Restart ComfyUI** to apply changes.

### Alternative Method: Using comfy-cli

1. **Run the following command:**
   ```bash
   python comfy-cli.py install ltdrdata/ComfyUI-Manager
   ```

This alternative method automates the installation process but requires comfy-cli to be set up correctly.

---

Following these steps will ensure a smooth setup for both ComfyUI and ComfyUI Manager on macOS.

