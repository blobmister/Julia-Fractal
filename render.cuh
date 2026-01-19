#ifndef RENDER_H
#define RENDER_H

#include <vector>
#include <iostream>
#include <chrono>
#include <fstream>

#include "complex.cuh"
#include "fractal.cuh"

struct Color {
    int r;
    int g;
    int b;
};

struct ImageData {
    int dim;
    double scale;
    int depth;
    int sampleNum;
    float colorFreq;
    float r_phase;
    float g_phase;
    float b_phase;
};

using color = struct Color;
using imageData = struct ImageData;

/*
* Helper function to calculate colour values
*/
__device__ void map_color(float t, ImageData d, Color* c) {
    c->r = (int)((sin(d.colorFreq * t + d.r_phase) * 0.5f + 0.5f) * 255);
    c->g = (int)((sin(d.colorFreq * t + d.r_phase) * 0.5f + 0.5f) * 255);
    c->b = (int)((sin(d.colorFreq * t + d.r_phase) * 0.5f + 0.5f) * 255);
}

/*
* Kernel code that is run on GPU. 
*
* Takes in an array, the fractal type (with generate function defined) and the image data.
*/
template <typename Fractal>
__global__ static void kernel(Color* ptr, Fractal f, imageData d) {
    int j = blockIdx.x * blockDim.x + threadIdx.x;
    int i = blockIdx.y * blockDim.y + threadIdx.y;

    if (j >= d.dim || i >= d.dim) return;
    int offset = j + i * d.dim;

    float total_iterations = 0.0f;

    for (int sub_y = 0; sub_y < d.sampleNum; ++sub_y) {
        for (int sub_x = 0; sub_x < d.sampleNum; ++sub_x) {

            float off_x = (sub_x + 0.5f) / d.sampleNum;
            float off_y = (sub_y + 0.5f) / d.sampleNum;

            float coord_x = j + off_x;
            float coord_y = i + off_y;

            float jx = d.scale * ((d.dim * 1.0f) / 2.0f - coord_x) / ((d.dim * 1.0f) / 2.0f);
            float jy = d.scale * ((d.dim * 1.0f) / 2.0f - coord_y) / ((d.dim * 1.0f) / 2.0f);

            total_iterations += f.generate(jx, jy);
        }
    }

    float avg_iter = total_iterations / (d.sampleNum * d.sampleNum);

    if (avg_iter >= d.depth * 0.99f) {
        ptr[offset].r = 0;
        ptr[offset].g = 0;
        ptr[offset].b = 0;
    } else {
        map_color(avg_iter, d, &ptr[offset]);
    }
}

class Renderer {
    public:
        Renderer(imageData data, std::string filename) : d(data), filename(filename) {}

        template <typename Fractal>
        void render(Fractal f) {
            size_t num_bytes = d.dim * d.dim * sizeof(color);
            std::vector<Color> host_bitmap(d.dim * d.dim);
            Color* device_bitmap;

            std::clog << "Rendering on GPU...\n";
            auto start = std::chrono::high_resolution_clock::now();

            cudaMalloc((void**)&device_bitmap, num_bytes);

            dim3 threadsPerBlock(16, 16);
            dim3 numBlocks (
                (d.dim + threadsPerBlock.x - 1) / threadsPerBlock.x,
                (d.dim + threadsPerBlock.y - 1) / threadsPerBlock.y
            );
            kernel<<<numBlocks, threadsPerBlock>>>(device_bitmap, f, d);

            cudaDeviceSynchronize();
            cudaError_t err = cudaGetLastError();
            if (err != cudaSuccess) {
                std::cerr << "Cuda Error: " << cudaGetErrorString(err) << '\n';
            }

            auto end = std::chrono::high_resolution_clock::now();
            auto elapsed = std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count();
            std::clog << "GPU Render Time: " << elapsed << "ms\n";

            std::clog << "Printing to PPM...\n";
            cudaMemcpy(host_bitmap.data(), device_bitmap, num_bytes, cudaMemcpyDeviceToHost);
            cudaFree(device_bitmap);
            PPM_render(host_bitmap);
        }

    private:
        imageData d;
        std::string filename;

        void PPM_render(std::vector<color>& bitmap) {
            std::ofstream file(filename, std::ios::binary);

            file << "P6\n" << d.dim << " " << d.dim << "\n255\n";
            
            std::vector<unsigned char> buffer;
            buffer.reserve(d.dim * d.dim * 3);

            for (const auto& c : bitmap) {
                buffer.push_back((unsigned char)c.r);
                buffer.push_back((unsigned char)c.g);
                buffer.push_back((unsigned char)c.b);
            }

            file.write(reinterpret_cast<char*>(buffer.data()), buffer.size());
            file.close();
        }
};


#endif