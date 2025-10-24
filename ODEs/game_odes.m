
%This script computes how ODEs evolve in the system

%fix the parametes in the "if ~exist" statements below, otherwise the
%script will try to continue a previously run ODE-based simulation

%results will be stored in "sequence", wchihc will contain one row per each
%time step (the corresponding time values are in "trange"). Each row
%contains (2*ns+1) columns: the initial ns columns report failure
%probabilities at each of the ns servers, the second group of ns columns 
%report the distribution of population across servers and the last colums 
% is the sum of populations. which should be constant and equal to nu 



clearvars -except adaptive_flag adaptive_flag_local time_duration folder rho_local switch_mode_local rho load_intervals s nu mu d b to T print_figures atconvergence stats_server_fail_filtered population horizon J_t sm_index switch_mode population_initial fail_mean_steady population_mean_steady fail_mean_steady_ideal population_mean_steady_ideal fail_mean_steady_ode population_mean_steady_ode simulated_points
if ~exist('rho','var')
    rho = 0.75;    %load
end

if ~exist('d','var')
    %d = [0.010 0.020 0.030];
    d = [0.015 0.030]; %latency of userts to servers
end

ns = numel(d); 

if ~exist('s','var')
    %for initialization from a uniform distribution of users to servers
    tot = randi(ns,1,1000);
    %tot = [ones(1,333) 2*ones(1,333) 3*ones(1,334)];
    for j = 1:ns
        s(j) = sum(tot==j);
    end
end

if ~exist('np','var')
    np = ones(1,numel(d)); %number of processors on each server
end

if ~exist('nu','var')
    nu = 1000; %population size
end

if ~exist('horizon','var')
    horizon = 1000; %time to evaluate, in seconds
end

if ~exist('mu','var')
    %mu = [100 200 400];
    mu = [150 350]; %service rate of processors, in services/s
end

if ~exist('b','var')
    %b = [10 10 10];
    b = [10 10]; %servers' buffer size
end

if ~exist('to','var')
    to = 0.075; %timeout to receive a response from a server
end

if ~exist('T','var')
    %T = [5 5 5];
    T = [5 5]; %initial patience values
else
    T = mean(T,1);
end

if ~exist('print_figures','var')
    print_figures = 1;
end

if ~exist('atconvergence','var')
    atconvergence = 0; %stop at convergence
end

if ~exist('switch_mode','var')
    switch_mode = 0; %0 for uniform reselection of server, 1 for slecting the next server proportionally to current patience values T
end

if ~exist('D', 'var')
    D = 0.01; %step to evaluate teh ODEs, in seconds
end



%%%%%%%%%%%%%%%%%

prf = @(t, d, l, m, n) 1 - (1 - pdrop(l/m,n)) * cdf_mm1n(t-2*d, l, m, n);


if atconvergence
    nsteps= 1;
else
    nsteps= horizon/D;
end

ns = numel(d);
if switch_mode == 0 %uniform switch probability
    M = 1./repmat((ns-1)*T,ns,1);
else %switch probability proportional to the patience
    for in1 = 1:ns
        for in2= 1:ns
            M(in1,in2) = 1 / T(in2) * T(in1) / (sum(T)-T(in2));
        end
    end
end
for j = 1:ns
    M(j,j) = -1/T(j);
end
rho_active = rho(1); 
arr_u = rho_active * sum(mu) / nu;

pfail = zeros(1,ns);

if ~atconvergence
    sequence = zeros(nsteps,2*ns+1);
end
sequence(1,:) = [zeros(1,numel(s)) s sum(s)];

load_intervals_index = 1; 

if atconvergence
    convergence_flag = 0;
    while convergence_flag == 0
        nsteps = nsteps + 1;
        for j = 1:numel(d)
            pfail(1,j) =  prf(to, d(j), s(j)*arr_u, mu(j), b(j));
        end
        s = s + D * (s .* pfail) * M';
        sequence(nsteps,:) = [pfail s sum(s)];
        if numel(rho)>1 
            if D*(nsteps-1) >= load_intervals(load_intervals_index)
                load_intervals_index = min(load_intervals_index+1, numel(rho));
                rho_active = rho(load_intervals_index);
                arr_u = sum(mu.*np) * rho_active / nu;
            end
            if D*(nsteps-1) >= load_intervals(end)
                if sqrt(sum((sequence(nsteps,ns+1:2*ns)./sequence(nsteps-1,ns+1:2*ns)-1).^2)) < 1.0e-9
                    convergence_flag = 1;
                end
            end    
        else
            if sqrt(sum((sequence(nsteps,ns+1:2*ns)./sequence(nsteps-1,ns+1:2*ns)-1).^2)) < 1.0e-9
                convergence_flag = 1;
            end
        end
        
    end
else
    for k = 2:size(sequence,1)
        for j = 1:numel(d)
            pfail(1,j) =  prf(to, d(j), s(j)*arr_u, mu(j), b(j));
        end
        s = s + D * (s .* pfail) * M';
        sequence(k,:) = [pfail s sum(s)];
        if numel(rho)>1 && D*k >= load_intervals(load_intervals_index)
            load_intervals_index = min(load_intervals_index+1, numel(rho));
            rho_active = rho(load_intervals_index);
            arr_u = sum(mu.*np) * rho_active / nu;
        end
    end
end

basename = sprintf('-rho_%g',rho(1));
if numel(rho) > 1
    basename = sprintf('%s_var',basename);
end
basename = sprintf('%s-ns_%d',basename, ns);
basename = sprintf('%s-mu',basename);
for j = 1:ns
    basename = sprintf('%s_%g',basename,mu(j));
end
basename = sprintf('%s-k',basename);
for j = 1:ns
    basename = sprintf('%s_%g',basename,b(j));
end
basename = sprintf('%s-d',basename);
for j = 1:ns
    basename = sprintf('%s_%g',basename,d(j));
end
basename = sprintf('%s-nu_%d',basename, nu);
basename = sprintf('%s-to_%g',basename, to);
basename = sprintf('%s-T',basename);
for j = 1:ns
    basename = sprintf('%s_%g',basename,T(j));
end




save(sprintf('./ode_results%s.mat',basename))

fprintf('rho = %g, steps = %g, population = [ ', rho(1), nsteps);
for j = 1:ns
    fprintf('%d ',s(j));
end
fprintf('], pfail = [ ')
for j = 1:ns
    fprintf('%d ',pfail(j));
end
fprintf(']\n')
if ns == 2
    fprintf('rho = %g, population = [%g %g], pfail = [%g %g], pfail_avg = %g \n', rho(1), s, pfail, pfail*s'/nu)
end






if print_figures

    figure('Position',[10 10 900 600])
    hold on
    trange = D*[0:size(sequence,1)-1];
    for j = 1:ns
        plot(trange, sequence(:,j), 'Linewidth',3, 'DisplayName', sprintf('Server %d',j))
    end
    legend('boxoff')
    legend('location','best')
    set(gca,'fontsize',24)
    xlabel('time')
    ylabel('pfail')

    figure('Position',[10 10 900 600])
    hold on
    trange = D*[0:size(sequence,1)-1];
    for j = ns+1 : 2*ns
        plot(trange, sequence(:,j), 'Linewidth',3, 'DisplayName', sprintf('Server %d',j-ns))
    end
    plot(trange, sequence(:,end), ':k','Linewidth',3, 'DisplayName', 'total')
    legend('boxoff')
    legend('location','best')
    set(gca,'fontsize',24)
    ylim([0 nu])
    xlabel('time')
    ylabel('population')


    figure('Position',[10 10 900 600])
    hold on
    trange = D*[0:size(sequence,1)-1];
    for j = 1:ns
        plot(trange, sequence(:,j) .* sequence(:,j+ns), 'Linewidth',3, 'DisplayName', sprintf('Server %d',j))
    end
    legend('boxoff')
    legend('location','best')
    set(gca,'fontsize',24)
    xlabel('time')
    ylabel('population-failure product')

    drawnow
end



