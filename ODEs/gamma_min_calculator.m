clearvars -except d b nu mu to T_dumb


if ~exist('d','var')
    d = [0.010 0.020 0.030];
    %d = [0.015 0.030];
end

ns = numel(d);

if ~exist('np','var')
    np = ones(1,numel(d));
end

if ~exist('nu','var')
    nu = 1000;
end

if ~exist('mu','var')
    mu = [100 200 400];
    %mu = [150 350];
end

if ~exist('b','var')
    b = [10 10 10];
    %b = [10 10];
end

if ~exist('to','var')
    to = 0.100;
end

if ~exist('T_dumb','var')
    T_dumb = [3 5 7];
    %T_dumb = [5 5];
else
    T_dumb = mean(T_dumb,1);
end


%%%%%%%%%%%%%%%%%

%prf = @(t, d, l, m, n) 1 - (1 - pdrop(l/m,n)) * cdf_mm1n(t-2*d, l, m, n);
x = sym('x',[1 ns]);
%options = optimoptions('fsolve', 'MaxIterations',10000 ,'MaxFunctionEvaluations', 10000, 'Display','off');
%options = optimoptions('fsolve', 'MaxIterations',10000 ,'MaxFunctionEvaluations', 10000);
options = optimoptions('fsolve', 'MaxIterations',10000, 'FunctionTolerance', 1.0e-21, 'OptimalityTolerance', 1.0e-21,'StepTolerance', 1.0e-21)

rho = linspace(0,1.5,300); 
%rho = [0.25 0.255]
for i = 1 : numel(rho)

    arr_u = rho(i) * sum(mu) / nu;
    %x0 = nu/ns*ones(1,ns);
    x0 = [ nu 0 0];
    assume(x>0 & x<nu)
    A = @(x) fmatrix(to, d, arr_u, mu, b, x, nu);
    [n_limit,fval{i},exitflag(i)] = fsolve(A,x0, options);

    n_dumb_max = sum(T_dumb) * min( n_limit ./ T_dumb);
    gamma_min(i) = 1 - n_dumb_max / nu;

    fprintf('rho = %g  gamma_min = %g   pfail = [ ',rho(i), gamma_min(i));
    for j = 1 : numel(d)
        fprintf('%g ', prf(to,d(j),n_limit(j)*arr_u,mu(j),b(j)))
    end
    fprintf('] ')
    fprintf('n_limit = [ ')
    for j = 1 : numel(d)
        fprintf('%g ', n_limit(j))
    end
    fprintf(']\n')
end

figure('Position',[10 10 900 600])
plot(rho,gamma_min,'LineWidth',2)
xlabel('\rho')
ylabel('\gamma_{min}')
 set(gca,'fontsize',24)


