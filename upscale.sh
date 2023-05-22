#!/bin/bash

upscaler="ultramix_balanced" # Change the upscaler here, this name should be the same as the model name in the folder
upscalerAlt="UltraMixBalanced"

# upscaler="4x-UltraSharp-opt-fp32"
# upscalerAlt="UltraSharp"

# upscaler="4x-UniScaleV2_Moderate-opt-fp32"
# upscalerAlt="UniScalerV2Moderate"

if [ -f "$1" ]; then # File or directory check
	# File
	echo -e "\e[33m📄 Selected a file.\e[0m"
else
	# Directory
	echo -e "\e[33m🗃️  Selected a directory.\e[0m"
	mkdir -p "$1"/Upscaled
	for file in "$1"/*; do
		# Check if the file is .jpg, .png, .webp, .avif and then proceed
		if [[ $file == *".jpg"* ]] || [[ $file == *".png"* ]] || [[ $file == *".webp"* ]] || [[ $file == *".avif"* ]]; then
			echo -e "\e[32mUpscaling $file.\e[0m"
			./upscale.sh "$file"
		else
			echo -e "\e[31mFile is not an image, skipping $file.\e[0m"
		fi
	done
	# Move everything that has the upscaler name in the filename to the Upscaled folder
	mv "$1"/*$upscalerAlt* "$1"/Upscaled
	echo -e "\e[32mFinished upscaling all images in the directory.\e[0m"
	exit 1
fi

input=$1
if [[ $input == *"."* ]]; then
	input="${input%.*}"
	extension="${1##*.}"
fi

echo "Input:" $input
echo "Extension:" $extension

echo -e "\e[32mUpscaling started.\e[0m"

# Note that it generates PNGs if you input PNGs, and JPGs if you input JPGs, etc
~/Desktop/MyUpscaler/realesrgan-ncnn-vulkan -i $1 -o $input-$upscalerAlt.$extension -m ~/Desktop/MyUpscaler/models -n $upscaler -f jpg

echo -e "\e[32mUpscaling finished, starting compression.\e[0m"

# TODO: Compressing with ffmpeg and libaom-av1 into AVIF doesn't work for files larger than 25MB for some unknown reason
# So, until that gets magically fixed, WEBp is the second best thing. It's configured to use the highest quality and compression level for the same file size.

ffmpeg -hide_banner -i $input-UltraMixBalanced.$extension -c:v libwebp -quality 83 -compression_level 6 $input-UltraMixBalanced-Webp-Compressed.webp
# ffmpeg -hide_banner -i $input-UltraMixBalanced.jpg -c:v libaom-av1 -cpu-used 8 -crf 21 $input-UltraMixBalanced-AV1-CRF21.avif
# ffmpeg -hide_banner -i $input-UltraMixBalanced.jpg $input-UltraMixBalanced-JPG-Compressed.jpg

echo -e "\e[32mFile compression finished.\e[0m"

# Deleting the original upscaled image

# rm $input-UltraMixBalanced.jpg
