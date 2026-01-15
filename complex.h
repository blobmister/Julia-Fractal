#ifndef COMPLEX_H
#define COMPLEX_H

#include <iostream>

class complex {
private:
    double m_real;
    double m_imag;

public:
    complex(double r = 0.0, double i = 0.0) : m_real(r), m_imag(i) {}

    double real() const { return m_real; }
    double imaginary() const { return m_imag; }

    complex& operator+=(const complex& other) {
        m_real += other.m_real;
        m_imag += other.m_imag;
        return *this;
    }

    complex& operator-=(const complex& other) {
        m_real -= other.m_real;
        m_imag -= other.m_imag;
        return *this;
    }

    complex& operator*=(const complex& other) {
        double new_real = m_real * other.m_real - m_imag * other.m_imag;
        m_imag = m_real * other.m_imag + m_imag * other.m_real;
        m_real = new_real;
        return *this;
    }

    double const mag_sq() const {
        return m_real * m_real + m_imag * m_imag;
    }

    complex& operator/=(const complex& other);

    complex operator-() const { return complex(-m_real, -m_imag); }
};


inline complex operator+(complex lhs, const complex& rhs) { return lhs += rhs; }
inline complex operator-(complex lhs, const complex& rhs) { return lhs -= rhs; }
inline complex operator*(complex lhs, const complex& rhs) { return lhs *= rhs; }
inline complex operator/(complex lhs, const complex& rhs) { return lhs /= rhs; }

inline complex operator*(complex z, double scalar) { return complex(z.real() * scalar, z.imaginary() * scalar); }
inline complex operator*(double scalar, complex z) { return z * scalar; }
inline complex operator/(complex z, double scalar) { return complex(z.real() / scalar, z.imaginary() / scalar); }
inline complex operator/(double scalar, complex z) { return scalar * (complex(1, 0)/z); }


inline complex conjugate(const complex& z) {
    return complex(z.real(), -z.imaginary());
}

inline complex& complex::operator/=(const complex& other) {
    *this *= conjugate(other);
    *this = *this / other.mag_sq();
    return *this;
}

inline std::ostream& operator<<(std::ostream& os, const complex& z) {
    return os << "(" << z.real() << ", " << z.imaginary() << ")";
}

#endif
