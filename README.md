---
title: Custom New-API Instance
emoji: 🚀
colorFrom: blue
colorTo: green
sdk: docker
app_port: 3000
license: apache-2.0
---

# Custom New-API Instance with Model Prefix Feature

This Hugging Face Space runs a customized instance of the [New-API](https://github.com/QuantumNous/new-api) project.

## Key Features

*   **Always Up-to-Date:** Automatically clones the latest code from the `QuantumNous/new-api` repository on each build, ensuring you have recent updates.
*   **Custom UI Enhancement:** Includes a modified `EditChannel.js` from [timigogo/new-api-edit-channel](https://github.com/timigogo/new-api-edit-channel) which re-implements the "一键添加模型前缀" (Add Prefix with One Click) button on the channel editing page. This allows easy prefixing of model names with the channel name and generates the corresponding model mapping.
*   **Dockerized Deployment:** Uses the provided multi-stage `Dockerfile` for a clean and reproducible build process. The Dockerfile handles fetching code, replacing the file, and building both frontend and backend components.

## Usage

Once the Space is running, you can access the New-API web interface via the public URL assigned by Hugging Face. The application listens on port 3000 internally.

Use this instance as you would a standard New-API deployment. The primary difference is the added button functionality on the channel editing form.

## Technical Details

*   **Base Project:** [QuantumNous/new-API](https://github.com/QuantumNous/new-api) (Cloned automatically)
*   **Customization Source:** [timigogo/new-api-edit-channel](https://github.com/timigogo/new-api-edit-channel) (`EditChannel.js`) (Cloned automatically)
*   **Build Environment:** Defined by `Dockerfile`. The build process includes cache-busting techniques to ensure the latest code is fetched when the Space is rebuilt.

## License

This customized deployment is based on the New-API project, which uses the Apache 2.0 License. The license terms apply accordingly.


