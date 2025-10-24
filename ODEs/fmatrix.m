function Fmatrix = fmatrix(to, d, arr_u, mu, b, x, nu)
Fmatrix(1) = sum(x) - nu;  
for i = 2:numel(d)
    Fmatrix(i) = prf(to, d(i), x(i)*arr_u, mu(i), b(i)) - prf(to, d(1), x(1)*arr_u, mu(1), b(1));
end