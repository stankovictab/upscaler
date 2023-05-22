# upscaler
Batch upscaling and compression script.

Upscaler is `realesrgan-ncnn-vulkan-v0.2.0-ubuntu`, you can get it from [here](https://github.com/xinntao/Real-ESRGAN-ncnn-vulkan].)

## TODO List

- [ ] Make it able to run from any directory. An alias could solve this, but then I'd need to change the upscale.sh call in here aswell. Maybe put it in /usr/bin?
- [ ] Fix not being able to run if a folder has spaces in it. So escape whitespace and other characters? Maybe try and find a way to convert imported paths to absolute ones. See test folder 2. 
- [ ] I'm guessing it's the same problem with spaces in file names. 
- [ ] Make the script executable from qimgv. 
- [ ] Add file size compare up to 24MB to do AVIF or WEBP.
- [x] Add flag to keep original upscaled image. 
- [ ] Add more models, for instance digital art ones, see what Upscayl uses. 
- [ ] Try and find the fix for ffmpeg's libaom-av1 encoder, maybe use SVT-AV1 instead, maybe use some API. 
- [ ] Think of a way to constantly show the full progress bar when upscaling a folder. For instance, look up how many images are in the folder, and count how many have been upscaled, then show the progress bar based on that after every upscale.

## Usage

The upscaler uses a dedicated Vulkan-supported GPU to do upscaling. 

```bash
./upscale.sh {file or folder you want to upscale} {--keep to keep original upscaled image}
```

You can suspend the process with `Ctrl` + `z` and resume it with `fg`.\
You can stop the process with `Ctrl` + `c`.

## Model Downloads

As the upscaler is based on NCNN, you need `.param` and `.bin` files to use it.

Here are the models I most commonly use :
- UltraMix Balanced - Download from [Upscayl's git](https://github.com/upscayl/upscayl/tree/main/resources/models) repository, as I couldn't find it anywhere else.
- 4x UltraSharp - Download from [The Model Database](https://upscale.wiki/wiki/Model_Database).
- UniScaleV2 - Download from [The Model Database](https://upscale.wiki/wiki/Model_Database).

Place the downloaded models (`.param` and `.bin` files) in the `models/` folder.

## AVIF Issue

Using `ffmpeg` to convert to AVIF is not working for images over 25MB for some reason.\
So, for file sizes larger than that WEBP compression is used, the second best option.\
Note that I've tried various online converters and they worked.\
From my testing the upscaled images weren't corrupt or anything, and it's not the resolution of them that's the issue, \
but the file size, everything up to 25.3MB was ok, but it failed onwards.\
The `ffmpeg` parameters such as `-cpu-used` and `-crf` also played no role in it from what I could tell. 
