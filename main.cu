#include <cuda_runtime.h>

#include "complex.cuh"
#include "fractal.cuh"
#include "render.cuh"


// Image Setup
int DIM = 2000;
double scale = 1.5;
int sampleNum = 10;
float colorFreq = 0.01f;
float r_phase = 3.14f;
float g_phase = 3.14f;
float b_phase = 0.0f;
std::string filename = "image.ppm";


// Fractal Setup
complex c(-0.35, 0.35);
int depth = 2000;
double threshold = 1000;

int main() {
   // Setup Image Parameters
   imageData d = {
       DIM, scale, depth, sampleNum, colorFreq, r_phase, g_phase, b_phase
   };

   // Setup fractal type and parameters
   Julia f(c, threshold, depth);

   // Get Render Object
   Renderer r(d, filename);
   r.render(f);
   
   return 0;
}
