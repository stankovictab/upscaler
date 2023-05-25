#!/bin/bash

# NOTE: A lot of command calls require the input to be in quotes because of the absolute path, which deals with folders with spaces in them

# If no argument is passed, exit the script
if [ -z "$1" ]; then
	echo -e "\e[31mNo argument passed! Make sure you pass in a file or folder you want to upscale. Exiting.\e[0m"
	exit
fi

if [ ! -e "$1" ]; then
	echo -e "\e[31mFile or folder \"$1\" doesn't exist! Make sure you pass in a file or folder you want to upscale. Exiting.\e[0m"
	exit
fi

script_path=$(readlink -f "$0")
script_path="${script_path%/*}" # This is the absolute path of the folder the upscaler is in
# echo "Script Path:" $script_path 

# echo First Argument: $1
# echo Second Argument: $2

absolutePath=$(readlink -f "$1") # Get the absolute path of the file, the input to readlink must be in quotes if the folder has spaces
# echo Absolute Path: $absolutePath

# Pick an Upscaler

upscaler="ultramix_balanced" # Change the upscaler here, this name should be the same as the model name in the folder
upscalerAlt="UltraMixBalanced"

# upscaler="4x-UltraSharp-opt-fp32"
# upscalerAlt="UltraSharp"

# upscaler="4x-UniScaleV2_Moderate-opt-fp32"
# upscalerAlt="UniScalerV2Moderate"

# Upscaling Loop

# Take absolutePath and remove the last part of the path, which is the filename
absolutePathTrimmed="${absolutePath%/*}" # Input is something like /home/.../tests/test folder 2
# echo $absolutePathTrimmed

mkdir -p "$absolutePathTrimmed"/Upscaled # This is fine, as the file or folder is already checked to exist

if [ -f "$1" ]; then # File or directory check
	echo -e "\e[33m📄 Selected a file.\e[0m"
	# Script continues
else
	echo -e "\e[33m🗃️  Selected a directory.\e[0m"
	for file in "$1"/*; do
		if [[ $file == *".jpg"* ]] || [[ $file == *".jpeg"* ]] || [[ $file == *".png"* ]] || [[ $file == *".webp"* ]] || [[ $file == *".avif"* ]]; then
			echo -e "\e[32mUpscaling file of directory: $file.\e[0m"
			$script_path/upscale.sh "$file" $2 # Need to pass in the same second argument
		else
			echo -e "\e[31mFile is not an image, skipping $file.\e[0m"
		fi
	done
	exit
fi

# By this point a file with an extension has been selected
# absolutePath is the absolute path of the file with actual spaces

noExtensionNonFormatted="${absolutePath%.*}" # Input is something like /home/.../tests/test folder 2/image
extension="${absolutePath##*.}" # Extension is something like jpg, without the dot

# echo "No Extension Non Formatted:" $noExtensionNonFormatted
# echo "Extension:" $extension

echo -e "\e[32mUpscaling started on $noExtensionNonFormatted-$upscalerAlt.$extension.\e[0m"

# Note that it generates PNGs if you input PNGs, and JPGs if you input JPGs, etc
$script_path/realesrgan-ncnn-vulkan -i "$absolutePath" -o "$noExtensionNonFormatted-$upscalerAlt.$extension" -m models -n $upscaler

echo -e "\e[32mUpscaling finished, starting compression.\e[0m"

width=$(identify -format "%w" "$noExtensionNonFormatted-$upscalerAlt.$extension")
height=$(identify -format "%h" "$noExtensionNonFormatted-$upscalerAlt.$extension")
pixels=$((width * height))
# echo "Image (" $width "x" $height ") has this many pixles:" $pixels

# Compressing with libaom-av1 doesn't work for images that have more than 35mil pixels for some unknown reason. See the README, tests have been done. 
if [ $pixels -lt "35499300" ]; then
	echo -e "\e[33mImage is smaller than 35499300 pixels, compressing with libaom-av1.\e[0m"
    ffmpeg -hide_banner -i "$noExtensionNonFormatted-$upscalerAlt.$extension" -c:v libaom-av1 -cpu-used 8 -crf 19 "$noExtensionNonFormatted-$upscalerAlt-AV1-CRF19.avif" -y
else
	echo -e "\e[33mImage is larger than 35499300 pixels, compressing with libwebp.\e[0m"
    ffmpeg -hide_banner -i "$noExtensionNonFormatted-$upscalerAlt.$extension" -c:v libwebp -quality 82 -compression_level 6 "$noExtensionNonFormatted-$upscalerAlt-WebP-Q82-CL6.webp" -y
fi

echo -e "\e[32mFile compression finished.\e[0m"

# Deleting the original upscaled image
if [ "$2" == "--keep" ]; then
	echo -e "\e[33mOriginal upscaled image kept.\e[0m"
else 
	rm "$noExtensionNonFormatted-$upscalerAlt.$extension"
	echo -e "\e[32mOriginal upscaled image deleted.\e[0m"
fi

# Move every file that has the upscaler name in that folder to the Upscaled folder
mv "$absolutePathTrimmed"/*$upscalerAlt* "$absolutePathTrimmed"/Upscaled
echo -e "\e[35mFinished upscaling, see the Upscaled folder.\e[0m"
