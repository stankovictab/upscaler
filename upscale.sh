#!/bin/bash

echo First Argument: $1
echo Second Argument: $2

# Replace spaces with \ in the path of $1
path="${1// /\\ }" # Makes me wanna shit myself
echo Formatted Path: $path

upscaler="ultramix_balanced" # Change the upscaler here, this name should be the same as the model name in the folder
upscalerAlt="UltraMixBalanced"

# upscaler="4x-UltraSharp-opt-fp32"
# upscalerAlt="UltraSharp"

# upscaler="4x-UniScaleV2_Moderate-opt-fp32"
# upscalerAlt="UniScalerV2Moderate"

if [ -f "$1" ]; then # File or directory check
	echo -e "\e[33m📄 Selected a file.\e[0m"
	# Script continues
else
	echo -e "\e[33m🗃️  Selected a directory.\e[0m"
	mkdir -p "$1"/Upscaled
	for file in "$1"/*; do
		if [[ $file == *".jpg"* ]] || [[ $file == *".png"* ]] || [[ $file == *".webp"* ]] || [[ $file == *".avif"* ]]; then
			echo -e "\e[32mUpscaling $file.\e[0m"
			./upscale.sh "$file" $2 # Need to pass in the same second argument
		else
			echo -e "\e[31mFile is not an image, skipping $file.\e[0m"
		fi
	done
	# Move everything that has the upscaler name in the filename to the Upscaled folder
	mv "$1"/*$upscalerAlt* "$1"/Upscaled
	echo -e "\e[32mFinished upscaling all images in the directory.\e[0m"
	exit
fi

input=$1
if [[ $input == *"."* ]]; then
	input="${input%.*}" # Input is something like tests/test1
	extension="${1##*.}" # Extension is something like jpg, without the dot
fi

# echo "Input:" $input
# echo "Extension:" $extension

echo -e "\e[32mUpscaling started on $input-$upscalerAlt.$extension.\e[0m"

# Note that it generates PNGs if you input PNGs, and JPGs if you input JPGs, etc
./realesrgan-ncnn-vulkan -i $1 -o $input-$upscalerAlt.$extension -m models -n $upscaler

echo -e "\e[32mUpscaling finished, starting compression.\e[0m"

# TODO: Compressing with ffmpeg and libaom-av1 into AVIF doesn't work for files larger than 25MB for some unknown reason
# So, until that gets magically fixed, WEBp is the second best thing. It's configured to use the highest quality and compression level for the same file size.

ffmpeg -hide_banner -i $input-$upscalerAlt.$extension -c:v libwebp -quality 83 -compression_level 6 $input-$upscalerAlt-Webp-Compressed.webp -y
# ffmpeg -hide_banner -i $input-$upscalerAlt.$extension -c:v libaom-av1 -cpu-used 8 -crf 21 $input-$upscalerAlt-AV1-CRF21.avif
# ffmpeg -hide_banner -i $input-$upscalerAlt.$extension $input-$upscalerAlt-JPG-Compressed.jpg

echo -e "\e[32mFile compression finished.\e[0m"

echo $2

# Deleting the original upscaled image
if [ "$2" == "--keep" ]; then
	echo -e "\e[33mOriginal upscaled image kept, file is $input-$upscalerAlt.$extension.\e[0m"
else 
	rm $input-$upscalerAlt.$extension
	echo -e "\e[32mOriginal upscaled image deleted, file was $input-$upscalerAlt.$extension.\e[0m"
fi
