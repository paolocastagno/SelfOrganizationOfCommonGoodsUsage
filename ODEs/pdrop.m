function res = pdrop(r, n)
res = 1;

p0 = 1 / sum(r.^[0:n]);

res = p0 * (r^n);

end
