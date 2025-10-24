function y = prf(t, d, l, m, n) 
y = 1 - (1 - pdrop(l/m,n)) * cdf_mm1n(t-2*d, l, m, n);
