# upscaler
Batch upscaling and compression script.

Upscaler is `realesrgan-ncnn-vulkan-v0.2.0-ubuntu`, you can get it from [here](https://github.com/xinntao/Real-ESRGAN-ncnn-vulkan].).

## TODO List

- [x] Make upscale.sh runnable from anywhere. An alias can solve this?
- [x] The upscaler call in the script needs to then run from anywhere. 
- [x] Fix not being able to run if a folder has spaces in it. So escape whitespace and other characters? Maybe try and find a way to convert imported paths to absolute ones. This should fix spaces in file names aswell. 
- [ ] If you just say upscale 1, it'll create a folder 1 and an Upscaled folder in it. Make a check to see if "1" actually exists, if it doesn't, don't do anything. 
- [ ] See if the / at the end if passing a folder needs to be removed in order to not get the // thing in echos. Seems like it doesn't impact functionality.
- [x] Make a post on reddit about the ffmpeg issue. 
- [ ] Mention that you need imagemagick for the AVIF check. 
- [ ] Fix the qimgv AVIF script in scripts/. 
- [ ] Make this script executable from qimgv. 
- [x] Add image pixel count comparison in order to do AVIF or WEBP.
- [x] Add flag to keep original upscaled image. 
- [ ] Add more models, for instance digital art ones, see what Upscayl uses. 
- [ ] Think of a way to constantly show the full progress bar when upscaling a folder. For instance, look up how many images are in the folder, and count how many have been upscaled, then show the progress bar based on that after every upscale.

## Installation

Clone the repo, and have `ffmpeg` installed.\
I also suggest making a shell alias for the script to the folder you've cloned, so you can run it from anywhere.

```bash
alias upscale="~/Desktop/upscaler/upscale.sh" # For example
```

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

Using `ffmpeg` to convert to AVIF is not working for images that have more than ~35 million pixels for some reason.\
I've tried various online converters and they worked.\
From my testing the upscaled images weren't corrupt, as they're all generated the same way via the same upscaler, so it has to be `ffmpeg`.\
I've also considered that it might be the file size, that's not it, I've tried it on some images that are ~80MB and it worked.\
I've thought the `ffmpeg` parameters might be the issue, that's not it either.\
I've thought it was the lack of RAM, but that's not it either.\
The final test was resolution, and that seems to be it.\
Here's the testing I've done. 
- 5200x6496 works, 5600x6996 doesn't. 
- 5300x6496 works, 5400x6744 doesn't.
- 5320x6644 works (35346080 pixels), 5360x6696 (35890560 pixels) doesn't.
- It's not the width or height specifically, 703x6694 works, and 5360x784 works. 
It's the number of pixels.
- 5360x6623 (35499280 pixels) does work, 5359x6666 (35729760 pixels) doesn't work.

Based on this I can make a cutoff to not do AVIF if the number of pixels is over 35499300.\
So, for upscaled images that are larger than that, WEBP compression is used, the second best option, and that one works like expected.\
