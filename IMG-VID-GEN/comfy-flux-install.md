# Installing Flux Models for ComfyUI

This guide provides a simple method for downloading and setting up the Flux models for use in ComfyUI.

---

## Downloading and Placing Flux Models

1. **Download the Flux Models**  
   - Visit the official Flux model guide: [Flux.1 ComfyUI Workflow Guide](https://comfyui-wiki.com/en/tutorial/advanced/flux1-comfyui-guide-workflow-and-examples)
   - Download the necessary model files from the provided links.

2. **Move the Models to the Correct Directories**  
   - Navigate to your ComfyUI installation directory:
     ```bash
     cd path/to/ComfyUI/models
     ```
   - Place the downloaded Flux model files inside the appropriate subdirectories:
     - **Stable Diffusion Models:**
       ```bash
       mv ~/Downloads/flux_model.safetensors path/to/ComfyUI/models/checkpoints/
       ```
     - **CLIP Models:**
       ```bash
       mv ~/Downloads/clip_model.safetensors path/to/ComfyUI/models/clip/
       ```
     - **VAE Models:**
       ```bash
       mv ~/Downloads/vae_model.safetensors path/to/ComfyUI/models/vae/
       ```

---

## Using Workflows in ComfyUI

Flux workflows can be loaded in ComfyUI in two ways:

1. **JSON Files:**  
   - Download the example workflow from [this link](https://comfyanonymous.github.io/ComfyUI_examples/flux/)
   - Save the `.json` file to your local machine.
   - Load it into ComfyUI via the WebUI by selecting the file in the workflow loader.

2. **Drag & Drop Images:**  
   - ComfyUI allows you to load workflows from images containing embedded workflow metadata.
   - Simply drag and drop a compatible image into the WebUI, and the associated workflow will load automatically.

---

## Adding a Negative Prompt to the Workflow

By default, the Flux workflow includes a positive prompt. To add a negative prompt:

1. Open the ComfyUI WebUI.
2. Load the Flux workflow using one of the methods above.
3. Locate the **CLIPTextEncode** node in the workflow.
4. Add a new **CLIPTextEncode** node for the negative prompt.
5. Connect the new node’s output to the **Sampling Options** node’s negative input.
6. Enter a negative prompt in the new node (e.g., "low quality, blurry, artifacts").
7. Save the updated workflow for future use.

Following these steps will ensure a smooth setup and allow for advanced workflow modifications in ComfyUI.

