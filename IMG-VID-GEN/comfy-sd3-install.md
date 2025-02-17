# Setting Up Stable Diffusion 3.5 in ComfyUI

## Step 1: Download Required Models

1. **Download the Stable Diffusion 3.5 Model:**
   - Visit: [Stable Diffusion 3.5 Large](https://huggingface.co/stabilityai/stable-diffusion-3.5-large)
   - Accept the model license agreement if required.
   - Download: `sd3.5_large.safetensors`
   - You can get superior altenative fine-tunes from civitai.com

2. **Download Required Text Encoders:**
   - Visit: [Stable Diffusion 3.5 Medium](https://huggingface.co/stabilityai/stable-diffusion-3.5-medium)
   - Download:
     - `clip_l.safetensors`
     - `clip_g.safetensors`
     - `t5xxl_fp16.safetensors` (or `t5xxl_fp8_e4m3fn.safetensors` if system has less than 32GB RAM)

## Step 2: Place Models in the Correct Directories

Navigate to the ComfyUI `models` directory:

```bash
cd path/to/ComfyUI/models
```

Move the downloaded models:

```bash
mv ~/Downloads/sd3.5_large.safetensors checkpoints/
mv ~/Downloads/clip_l.safetensors clip/
mv ~/Downloads/clip_g.safetensors clip/
mv ~/Downloads/t5xxl_fp16.safetensors clip/
```

## Step 3: Load the Stable Diffusion 3.5 Workflow

1. **Download the Workflow:**
   - Get the Stable Diffusion 3.5 workflow JSON file from: [ComfyUI Wiki](https://comfyui-wiki.com/en/tutorial/advanced/stable-diffusion-3-5-comfyui-workflow)

2. **Load the Workflow in ComfyUI:**
   - Open ComfyUI.
   - Use the workflow loader to upload the JSON file.

## Step 4: Generate Images

1. Enter a text prompt.
2. Adjust settings if needed (sampling method, CFG scale, resolution, etc.).
3. Click "Queue Prompt" to start generation.

Your Stable Diffusion 3.5 setup in ComfyUI is now ready to use.

