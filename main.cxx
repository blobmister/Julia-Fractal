#import <vector>
#import <chrono>
#import "complex.h"

struct Color {
    int r;
    int g;
    int b;
};

using color = struct Color;

int DIM = 1080;
double scale = 1.5;
complex c(-0.8, 0.156);
int depth = 200;
double threshold = 1000;

void generate_loading_bar(const int cur, int total, const std::chrono::time_point<std::chrono::high_resolution_clock>& start) {
    int percent_complete = static_cast<int>((double(cur)/total) * 100.0);
    auto now = std::chrono::high_resolution_clock::now();
    auto elapsed = std::chrono::duration_cast<std::chrono::seconds>(now-start).count();
    long long minutes = elapsed / 60;
    long long seconds = elapsed % 60;

    std::clog << "[";
    for (int i = 0; i < 100; i++) {
        if (i < percent_complete) std::clog << "=";
        else if (i == percent_complete) std::clog << ">";
        else std::clog << " ";
    }
    std::clog << "] " << percent_complete << "%, Elapsed Time: " << minutes << "m " << seconds << "s \r";
}

int julia(int i, int j) {
    float jx = scale * ((DIM * 1.0)/2 - j)/((DIM * 1.0)/2);
    float jy = scale * ((DIM * 1.0)/2 - i)/((DIM * 1.0)/2);

    complex a(jx, jy);
    for (int w{}; w < depth; ++w) {
        a = a * a + c;
        if (a.mag_sq() > threshold) {
            return 0;
        }
    }

    return 1;
}

void kernel(std::vector<color>& bitmap) {
    auto start = std::chrono::high_resolution_clock::now();
    for (int i{}; i < DIM; ++i) {
        for (int j{}; j < DIM; ++j) {
            int offset = j + i * DIM;
            generate_loading_bar(offset, DIM * DIM, start);

            int juliaValue = julia(i, j);
            bitmap[offset].r = 3 * juliaValue;
            bitmap[offset].g = 78 * juliaValue;
            bitmap[offset].b = 252 * juliaValue;

        }
    }

    auto end = std::chrono::high_resolution_clock::now();
    auto elapsed = std::chrono::duration_cast<std::chrono::seconds>(end-start).count();
    long long minutes = elapsed / 60;
    long long seconds = elapsed % 60;

    std::clog << "\rTime Taken to render: " << minutes << "m " << seconds << "s\n                                                                                                                                                                                       "                                                                                                                                                                      ;
}



void render(std::vector<color>& bitmap) {
    std::cout << "P3\n" << DIM << " " << DIM << "\n255\n";
    for (int i{}; i < DIM * DIM; ++i) {
        std::cout << bitmap[i].r << " " << bitmap[i].g << " " << bitmap[i].b << '\n';
    }

}



int main() {
    std::vector<color> bitmap(DIM * DIM);

    kernel(bitmap);

    std::clog << "\rWriting to Image File";
    render(bitmap);
    std::clog << "\rDone                                                                    \n";
}
