function H = measurement_jacobian(x, pos)
%MEASUREMENT_JACOBIAN Jacobian of [range; bearing] w.r.t. state.
dx = x(1)-pos(1); dy = x(3)-pos(2);
r = sqrt(dx^2+dy^2);
if r < 1e-6
    r = 1e-6;
end
H = [dx/r, 0, dy/r, 0;
     -dy/r^2, 0, dx/r^2, 0];
end
