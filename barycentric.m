function [c1, c2, c3] = barycentric(pixel1_u, pixel2_u, pixel3_u, pixel1_v, pixel2_v, pixel3_v, u, v)
    v0_u = pixel2_u - pixel1_u;
    v0_v = pixel2_v - pixel1_v;

    v1_u = pixel3_u - pixel1_u;
    v1_v = pixel3_v - pixel1_v;

    v2_u = u - pixel1_u;
    v2_v = v - pixel1_v;

    invDenom = 1.0/(v0_u * v1_v - v1_u * v0_v + 1e-6);
    c2 = (v2_u * v1_v - v1_u * v2_v) * invDenom;
    c3 = (v0_u * v2_v - v2_u * v0_v) * invDenom;
    c1 = 1.0 - c2 - c3;
end