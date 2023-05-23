#!/bin/bash

# NOTE: A lot of command calls require the input to be in quotes because of the absolute path, which deals with folders with spaces in them

# If no argument is passed, exit the script
if [ -z "$1" ]; then
	echo -e "\e[31mNo argument passed! Make sure you pass in a file or folder you want to upscale. Exiting.\e[0m"
	exit
fi

script_path=$(readlink -f "$0")
script_path="${script_path%/*}" # This is the absolute path of the folder the upscaler is in
# echo $script_path 

# echo First Argument: $1
# echo Second Argument: $2

absolutePath=$(readlink -f "$1") # Get the absolute path of the file, the input to readlink must be in quotes if the folder has spaces
echo Absolute Path: $absolutePath

# Replace spaces with \ in the path of $1
formattedAbsolutePath="${absolutePath// /\\ }" # Makes me wanna shit myself
echo Formatted Absolute Path: $formattedAbsolutePath

# Pick an Upscaler

upscaler="ultramix_balanced" # Change the upscaler here, this name should be the same as the model name in the folder
upscalerAlt="UltraMixBalanced"

# upscaler="4x-UltraSharp-opt-fp32"
# upscalerAlt="UltraSharp"

# upscaler="4x-UniScaleV2_Moderate-opt-fp32"
# upscalerAlt="UniScalerV2Moderate"

# Upscaling Loop

if [ -f "$1" ]; then # File or directory check
	echo -e "\e[33m📄 Selected a file.\e[0m"
	# Script continues
else
	echo -e "\e[33m🗃️  Selected a directory.\e[0m"
	mkdir -p "$1"/Upscaled
	for file in "$1"/*; do
		if [[ $file == *".jpg"* ]] || [[ $file == *".png"* ]] || [[ $file == *".webp"* ]] || [[ $file == *".avif"* ]]; then
			echo -e "\e[32mUpscaling file of directory: $file.\e[0m"
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

# By this point a file with an extension has been selected (hopefully)
# formattedAbsolutePath is the absolute path of the file with spaces replaced with '\ '
# absolutePath is the absolute path of the file with actual spaces

noExtensionNonFormatted="${absolutePath%.*}" # Input is something like /home/.../tests/test folder 2/image
extension="${absolutePath##*.}" # Extension is something like jpg, without the dot

echo "No Extension Non Formatted:" $noExtensionNonFormatted
echo "Extension:" $extension

echo -e "\e[32mUpscaling started on $noExtensionNonFormatted-$upscalerAlt.$extension.\e[0m"

# Note that it generates PNGs if you input PNGs, and JPGs if you input JPGs, etc
$script_path/realesrgan-ncnn-vulkan -i "$absolutePath" -o "$noExtensionNonFormatted-$upscalerAlt.$extension" -m models -n $upscaler

echo -e "\e[32mUpscaling finished, starting compression.\e[0m"

# TODO: Compressing with ffmpeg and libaom-av1 into AVIF doesn't work for files larger than 25MB for some unknown reason, see the README. 
ffmpeg -hide_banner -i "$noExtensionNonFormatted-$upscalerAlt.$extension" -c:v libwebp -quality 83 -compression_level 6 "$noExtensionNonFormatted-$upscalerAlt-Webp-Compressed.webp" -y
# ffmpeg -hide_banner -i $input-$upscalerAlt.$extension -c:v libaom-av1 -cpu-used 8 -crf 21 $input-$upscalerAlt-AV1-CRF21.avif
# ffmpeg -hide_banner -i $input-$upscalerAlt.$extension $input-$upscalerAlt-JPG-Compressed.jpg

echo -e "\e[32mFile compression finished.\e[0m"

# Deleting the original upscaled image
if [ "$2" == "--keep" ]; then
	echo -e "\e[33mOriginal upscaled image kept, file is $noExtensionNonFormatted-$upscalerAlt.$extension.\e[0m"
else 
	rm "$noExtensionNonFormatted-$upscalerAlt.$extension"
	echo -e "\e[32mOriginal upscaled image deleted, file was $noExtensionNonFormatted-$upscalerAlt.$extension.\e[0m"
fi
