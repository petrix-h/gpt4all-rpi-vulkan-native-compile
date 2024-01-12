#!/bin/sh

PATH=$(pwd)

sudo apt-get update 
sudo apt-get install -y htop nano git build-essential cmake ninja-build  wget vulkan-tools libvulkan-dev python3-pip
#sudo apt-get install  mesa-vulkan-drivers 

mkdir cmake 
cd cmake 
wget https://github.com/Kitware/CMake/releases/download/v3.28.1/cmake-3.28.1-linux-aarch64.sh 

chmod +x cmake-3.28.1-linux-aarch64.sh 
./cmake-3.28.1-linux-aarch64.sh

cd

##########
# 
# glscl takes about 2h or so to compile... 
# there is a zip that can let you skip to just copying the binary
# "sudo cp glslc/glslc /usr/local/bin" after "ninja"
#
##########

mkdir glslc
cd glslc/

#wget https://storage.googleapis.com/shaderc/artifacts/prod/graphics_shader_compiler/shaderc/linux/continuous_clang_release/444/20240103-104401/install.tgz

#tar -xvf install.tgz 

#sudo cp install/bin/glslc /usr/local/bin

git clone https://github.com/google/shaderc glslc/

cd glslc 

./utils/git-sync-deps 

mkdir build 

cmake -GNinja -DCMAKE_BUILD_TYPE=Release -Bbuild

cd build

ninja

sudo cp glslc/glslc /usr/local/bin

cd

#Probably not needed (noup not needed, gpt4all llama.cpp-mainline comes with its own copy of kompute)
#mkdir kompute
#git clone https://github.com/KomputeProject/kompute.git ./kompute/
#cd kompute/
#$PATH/cmake/cmake-3.28.1-linux-aarch64/bin/cmake -Bbuild -DKOMPUTE_OPT_DISABLE_VULKAN_VERSION_CHECK=ON

 
cd


mkdir gpt4all
git clone --recurse-submodules https://github.com/nomic-ai/gpt4all.git ./gpt4all

cd gpt4all/gpt4all-backend/
#Around line 55, comment out #include <immintrin.h>
nano llama.cpp-mainline/ggml-vulkan.cpp



mkdir build 

cd build


$PATH/cmake/cmake-3.28.1-linux-aarch64/bin/cmake -S $PATH/gpt4all/gpt4all-backend -B $PATH/gpt4all/gpt4all-backend/build -DKOMPUTE_OPT_DISABLE_VULKAN_VERSION_CHECK=ON --compile-no-warning-as-error

#/home/petri/cmake/cmake-3.28.1-linux-aarch64/bin/cmake -S /home/petri/gpt4all/gpt4all-backend -B /home/petri/gpt4all/gpt4all-backend/build --compile-no-warning-as-error


#Comment out memcpy around line 1333
nano _deps/fmt-src/include/fmt/format.h

$PATH/cmake/cmake-3.28.1-linux-aarch64/bin/cmake --build $PATH/gpt4all/gpt4all-backend/build --parallel 

#/home/petri/cmake/cmake-3.28.1-linux-aarch64/bin/cmake --build /home/petri/gpt4all/gpt4all-backend/build --parallel

cd

cd gpt4all/gpt4all-bindings/python

pip3 install -e .

#if pip fails... then (this is NOT how you should do it) 
#sudo rm /usr/lib/python3.11/EXTERNALLY-MANAGED
# and re run pip3 install.. 

#Test CPU inference first... it will download the model, it's about 2 GB... 
nano test.py

#from gpt4all import GPT4All
#from datetime import datetime
#start_time=datetime.now()
#model = GPT4All("orca-mini-3b-gguf2-q4_0.gguf")
#mod_load=datetime.now()
#output = model.generate("The capital of France is ", max_tokens=30)
#mod_generate=datetime.now()
#print(output)
#
#print('Mod load: {}'.format(mod_load - start_time))
#print('Generate: {}'.format(mod_generate - mod_load))
 
python3 test.py 

Then GPU acceleration... 

And this is where it fails because it can not find aby GPU devices even though vulkaninfo lists GPU 0 as V3D (the Broadcom Videocore one) and GPU 1 as llvmpipe (which is probably useless here) .. 

#model = GPT4All("orca-mini-3b-gguf2-q4_0.gguf", device='gpu')




