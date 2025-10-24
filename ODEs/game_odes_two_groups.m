clearvars -except adaptive_flag T_dumb adaptive_flag_local time_duration folder rho_local switch_mode_local rho load_intervals s nu mu d b to T print_figures atconvergence stats_server_fail_filtered population horizon J_t sm_index switch_mode



if ~exist('rho','var')
    rho = 0.75;    %max in service
end

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

if ~exist('horizon','var')
    horizon = 1000;
end

if ~exist('mu','var')
    mu = [100 200 400];
    %mu = [150 350];
end

if ~exist('d','var')
    d = [0.010 0.020 0.030];
    %d = [0.015 0.030];
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
T_smart = T_dumb; 

if ~exist('print_figures','var')
    print_figures = 0;
end

if ~exist('atconvergence','var')
    atconvergence = 1;
end

if ~exist('switch_mode','var')
    switch_mode = 0;
end

if ~exist('D', 'var')
    D = 0.1;
end



%%%%%%%%%%%%%%%%%

%prf = @(t, d, l, m, n) 1 - (1 - pdrop(l/m,n)) * cdf_mm1n(t-2*d, l, m, n);
x = sym('x',[1 ns]);

if atconvergence
    nsteps= 1;
else
    nsteps= horizon/D;
end

ns = numel(d);

rho_active = rho(1); 
arr_u = rho_active * sum(mu) / nu;

%determine T_smart
%make p_fail the same over all links by finding a population split
%prf(to, d(j), s(j)*arr_u, mu(j), b(j));

%%%%%%%%%%%%%%%

% find the population distribution n_limit that equalizes p_fail over all servers
% use the highest value of rho for the computation

%optimoptions('fsolve','OptimalityTolerance',1.0e-12, 'FunctionTolerance',1.0e-12);
%options = optimset('Display','off');
%options = optimoptions('fsolve', 'MaxFunctionEvaluations', 2000, 'Display','off');
options = optimoptions('fsolve', 'MaxFunctionEvaluations', 10000');


x0 = nu/ns*ones(1,ns);
assume(x,'real')
A = @(x) fmatrix(to, d, max(rho) * sum(mu) / nu, mu, b, x, nu); 
n_limit = fsolve(A,x0,options);

% print the corresponding failure probabilities 
fprintf('failure probs under the highest load:\n');
for i = 1 : ns 
    fprintf('%g\n',prf(to,d(i),n_limit(i)*max(rho) * sum(mu) / nu,mu(i),b(i)))
end
fprintf('\n');


% find the maximum number of dumb users 
% if n_dumb_max is the maximum for the total number of dumb users, 
% at server i, the number of dumb users will be 
% T_dumb(i) * n_dumb_max / sum(T_dumb), 
% which shall be not greater than n_limit(i). 
% Therefore, each server imposes a limit, and we shall take the minimum: 
n_dumb_max = sum(T_dumb) * min(n_limit ./ T_dumb);

% compute gamma_min accordingly
gamma_min = 1 - n_dumb_max / nu; 

% if instead we want to impose the value of gamma: 
gamma = 0.7;
%gamma = 5*ceil(gamma_min*1.1*100/5) / 100;

% with equalized p_fail, dumb users must be spread over all 
% available servers, proportioanlly to T_dumb: 
n_dumb = nu * (1-gamma) * T_dumb / sum(T_dumb); 

%therefore smart users must be distributed as follows: 
n_smart = n_limit - n_dumb;

% if all values of n_smart are positive, then it is possible to equalize
% p_fail over all servers by adjusting the values of T for the smart users.
% If instaead some values of n_smart are negative, then we must increase
% gamma until all values become non-negative

n_dumb(1:end-1) = round(nu * (1-gamma) * T_dumb(1:end-1) / sum(T_dumb));
n_dumb(end) = round(nu * (1-gamma) - sum(n_dumb(1:end-1)));
n_smart = round(n_limit - n_dumb);

%redefine nu after rounding:
nu = sum(n_smart + n_dumb);

% if gamma_min < 1, using smart users can equalize p_fail
if gamma_min > 1
    fprintf('equalization is unfeasible\n')
    return;
end 

% assign users to servers
tot = randi(ns,1,sum(n_dumb));
for j = 1:ns
    s_dumb(j) = sum(tot==j);
end

tot = randi(ns,1,sum(n_smart));
for j = 1:ns
    s_smart(j) = sum(tot==j);
end

fprintf('gamma = %g\n',gamma)
k = 0; 
arr_u = sum(mu.*np) * rho_active / nu;
pinned = zeros(1,numel(d)); 
x0 = [s_smart s_dumb];
optimize_patience();

%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%

pfail = zeros(1,ns);

if ~atconvergence
    sequence = zeros(nsteps,3*ns);
end
sequence(1,:) = [zeros(1,numel(s_dumb)) s_dumb s_smart];

load_intervals_index = 1; 

if atconvergence
    convergence_flag = 0;
    while convergence_flag == 0
        nsteps = nsteps + 1;
        for j = 1:numel(d)
            pfail(1,j) =  prf(to, d(j), (s_dumb(j)+s_smart(j))*arr_u, mu(j), b(j));
        end
        s_dumb = max(s_dumb + D * (s_dumb .* pfail) * M_dumb',0);
        s_smart = max(s_smart + D * (s_smart .* pfail) * M_smart',0);
        
        sequence(nsteps,:) = [pfail s_dumb s_smart];
        
        if numel(rho)>1 
            if D*(nsteps-1) >= load_intervals(load_intervals_index)
                load_intervals_index = min(load_intervals_index+1, numel(rho));
                rho_active = rho(load_intervals_index);
                arr_u = sum(mu.*np) * rho_active / nu;
            end
            if D*(nsteps-1) >= load_intervals(end)
                if sqrt(sum((sequence(nsteps,:)./sequence(nsteps-1,:)-1).^2)) < 1.0e-9
                    convergence_flag = 1;
                end
            end    
        else
            if sqrt(sum((sequence(nsteps,:)./sequence(nsteps-1,:)-1).^2)) < 1.0e-9
                convergence_flag = 1;
            end
        end
        
    end
else
    for k = 2:size(sequence,1)
        for j = 1:numel(d)
            pfail(1,j) =  prf(to, d(j), (s_dumb(j)+s_smart(j))*arr_u, mu(j), b(j));
        end
        s_dumb = max(s_dumb + D * (s_dumb .* pfail) * M_dumb',0);
        s_smart = max(s_smart + D * (s_smart .* pfail) * M_smart',0);
        sequence(k,:) = [pfail s_dumb s_smart];
        
        if numel(rho)>1 && D*k >= load_intervals(load_intervals_index)
            load_intervals_index = min(load_intervals_index+1, numel(rho));
            rho_active = rho(load_intervals_index);
            arr_u = sum(mu.*np) * rho_active / nu;
            x0 = s_dumb+s_smart;
            optimize_patience();
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
basename = sprintf('%s-Tdumb',basename);
for j = 1:ns
    basename = sprintf('%s_%g',basename,T_dumb(j));
end
basename = sprintf('%s-gamma_%g',basename,gamma);



save(sprintf('./ode_results%s.mat',basename))

fprintf('rho = %g, steps = %g, dumb population = [ ', rho(1), nsteps);
for j = 1:ns
    fprintf('%d ',s_dumb(j));
end
fprintf('], smart population = [ ')
for j = 1:ns
    fprintf('%d ',s_smart(j));
end
fprintf('], pfail = [ ')
for j = 1:ns
    fprintf('%d ',pfail(j));
end
fprintf(']\n')
if ns == 2
    fprintf('rho = %g, population = [%g %g], pfail = [%g %g], pfail_avg = %g \n', rho(1), s, pfail, pfail*(s_smart+s_dumb)'/nu)
end






if print_figures

    decimation = 50; 
    figure('Position',[10 10 900 600])
    hold on
    trange = D*[0:size(sequence,1)-1];
    for j = 1:ns
        plot(trange(1:decimation:end), sequence(1:decimation:end,j), 'Linewidth',3, 'DisplayName', sprintf('Server %d',j))
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
        plot(trange(1:decimation:end), sequence(1:decimation:end,j), 'Linewidth',3, 'DisplayName', sprintf('Server %d',j-ns))
    end
    %plot(trange(1:decimation:end), sum(sequence(ns+1,2*ns),2), ':k','Linewidth',3, 'DisplayName', 'total')
    legend('boxoff')
    legend('location','best')
    set(gca,'fontsize',24)
    ylim([0 nu])
    xlabel('time')
    ylabel('dumb population')


    figure('Position',[10 10 900 600])
    hold on
    trange = D*[0:size(sequence,1)-1];
    for j = 2*ns+1 : 3*ns
        plot(trange(1:decimation:end), sequence(1:decimation:end,j), 'Linewidth',3, 'DisplayName', sprintf('Server %d',j-2*ns))
    end
    %plot(trange, sum(sequence(2*ns+1,3*ns),2), ':k','Linewidth',3, 'DisplayName', 'total')
    legend('boxoff')
    legend('location','best')
    set(gca,'fontsize',24)
    ylim([0 nu])
    xlabel('time')
    ylabel('smart population')


    figure('Position',[10 10 900 600])
    hold on
    trange = D*[0:size(sequence,1)-1];
    for j = ns+1 : 2*ns
        plot(trange(1:decimation:end), sequence(1:decimation:end,j)+sequence(1:decimation:end,j+ns), 'Linewidth',3, 'DisplayName', sprintf('Server %d',j-ns))
    end
    legend('boxoff')
    legend('location','best')
    set(gca,'fontsize',24)
    ylim([0 nu])
    xlabel('time')
    ylabel('total population')

    % figure('Position',[10 10 900 600])
    % hold on
    % trange = D*[0:size(sequence,1)-1];
    % for j = 1:ns
    %     plot(trange, sequence(:,j) .* sequence(:,j+ns), 'Linewidth',3, 'DisplayName', sprintf('Server %d',j))
    % end
    % legend('boxoff')
    % legend('location','best')
    % set(gca,'fontsize',24)
    % xlabel('time')
    % ylabel('population-failure product')

    drawnow
end



