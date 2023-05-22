# upscaler
Batch upscaling and compression script.

Upscaler is `realesrgan-ncnn-vulkan-v0.2.0-ubuntu`, you can get it from [here](https://github.com/xinntao/Real-ESRGAN-ncnn-vulkan].)

## TODO List

- [ ] Make the script executable from qimgv. 
- [ ] Add file size compare up to 24MB to do AVIF or WEBP.
- [ ] Add flag to keep original upscaled image. 
- [ ] Add more models, for instance digital art ones, see what Upscayl uses. 
- [ ] Try and find the fix for ffmpeg's libaom-av1 encoder, maybe use SVT-AV1 instead, maybe use some API. 
- [ ] Think of a way to constantly show the full progress bar when upscaling a folder.

## Usage

`./upscale.sh {input}`

You can suspend the project with `Ctrl` + `z` and resume it with `fg`.

## Model Downloads

As the upscaler is based on NCNN, you need `.param` and `.bin` files to use it.

Here are the models I most commonly use:
- UltraMix Balanced - Download from [Upscayl's git](https://github.com/upscayl/upscayl/tree/main/resources/models) repository.
- 4x UltraSharp - Download from [The Model Database](https://upscale.wiki/wiki/Model_Database).
- UniScaleV2 - Download from [The Model Database](https://upscale.wiki/wiki/Model_Database).

Place the downloaded models (`.param` and `.bin` files) in the `models/` folder.

## AVIF Issue

Using `ffmpeg` to convert to AVIF is not working for images over 25MB for some reason.
So, for file sizes larger than that WEBP compression is used, the second best option.
