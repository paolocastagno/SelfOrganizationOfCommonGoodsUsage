
%setup the parameters forloowing parameters before calling 
%this sctips or the script will use default values

%continue_flag: 0 for new simulaiton, 1 to continue another one

%sim_duration: simulated seconds

%Tgroups: define as many "tolerance" groups as you want, specify their size. E.g. Tgroups = [300 400 300] for 3 groups of 300, 400 and 300 users

%Tvalues: define the initial patience parameter for each server. One row
%   for each group. E.g., Tvalues = [2 5 10; 5 10 20] for two groups and three
%   servers

%print_figures: set it to 0 if you do not want figures

%save_figures: set it to 0 if you do not want to save figures (in eps
%   format --- you can easily change the output format in the code, if you prefer)

%visibility_flag: in case you wnat figures, set this to 'off' in order not
%   to show them (still, you;ll be able to save figures without seeing
%   them)

%save_results: set it to 0 if you do not want to save numerical results in
%   a mat file

%adaptive_flag: set it to 0 if you do not want that patience parameters
%   adapt during the simulation

%switch_mode: set it to 0 for uniform reselection of server after the tolerance limit has benn hit,
%   otherwiset use 1 to select another server proportionally to current
%   tolerance values

%rho: use an array of positive values that will be used to compute the
%   offered load. Use as many values as the intervals in which you want to
%   test differnt load levels and specify interval durations (see below)

%to: timeout for response time from the server, in seconds

%Tlimits: set min and max patience for a user on a given server;
%   for instance 
%   Tlimits(1,1:nu,1:ns) = 5;
%   Tlimits(2,1:nu,1:ns) = 10;
%   forces patience values to stay in between 5 and 10 for all users and all servers
%   note that the following relations must hold: 
%   nu = sum(Tgroups) for the number of gouros
%   ns = numel(Tvalues(1,:)) for the number of servers

%T_delta: set the step for the adaptation of patience values, for each user
%   and each server, for in stance T_delta(1:nu,1:ns) = 0.5 will cause
%   patience adjustments by 0.5 if not further modified during the simulation 

%adaptive_T_delta: set it is 0 if you do not want to adapt T_delta during
%   simulation
    
%delay_uncertainty: define the amplitide of uniform noise to be added to
%   the user-to-server latency. The noise is proportional to the distance
%   between user and server.
%   E.g.,  delay_uncertainty = 0 will add no noise.
%   E.g.,  delay_uncertainty = 0.5 will a uniform noise in the +/- 50% range.

%partial_report_time: time (in seconds) at which partial results will be
%   saved. This value is then incremented by "partial_report_step" each
%   time the simulation reaches "partial_report_time". 

%partial_report_step: time (in seconds) that indicates intervals between
%partial data dumping to mat file

%load_intervals: number of seconds during which the load reamins constant
%   E.g., load_intervals = [sim_duration] implies that the load will not
%   change

%load_intervals_index: index of the current load, indicated in array "rho"

%if you are running a simulaiton from scratch, you also need to define
%network and server parameters: 

%np: array with the number of processors per each server, for instance, 
%   np = [1 2 1] defines 3 servers, the first and the last with one processor 
%   and the second one with two processors 
% 
%mu: the numebr of services per processor and per second that can be completed, on average
%   E.g., mu = [100 200 400] means that there are 3 servers, 
%   each with processors that can serve 100, 200 and 300 requests per second 

%b: length of each server's queue. E.g., b = [10 10 10] means that of
%   three available servers can have 10 requests waiting for a processor to
%   become free

%d: latency between user and servers, in seconds. 
%   E.g., d= [0.010 0.020 0.030] means that the user is at 10ms from server 1, 
%   20ms from server 2 and 30 ms from server 3. 





if ~exist('continue_flag')
    continue_flag = 0;
end

if ~exist('sim_duration')
    sim_duration = 30;
end

if ~exist('Tgroups')
    Tgroups = [1000]; %define as many groups as you want, specify their size. E.g. Tgroups = [300 400 300] for 3 groups of 300, 400 and 300 users
end

if ~exist('Tvalues')
    Tvalues = [1 1 1]; %define the initial patience parameter for each server. One row for each group. 
end

if ~exist('print_figures')
    print_figures = 1;
end

if ~exist('visibility_flag')
    visibility_flag = 'on';
end

if ~exist('save_results')
    save_results = 1;
end

if ~exist('save_figures')
    save_figures = 0;
end

if ~exist('adaptive_flag')
    adaptive_flag = 0;
end

if ~exist('switch_mode')
    switch_mode = 1; %0 for uniform, 1 for proportional to T
end

if ~exist('rho')
    rho = 0.75; 
end



 
if ~exist('partial_report_time')
    partial_report_time = 5000; 
end

if ~exist('partial_report_step')
    partial_report_step = 5000; 
end

if ~exist('load_intervals')
    load_intervals = [2*sim_duration];
end

if ~exist('load_intervals_index')
    load_intervals_index = 1;
end
 

if ~exist('to','var')
    to = 0.100;
end

if ~exist('Tlimits')
    nu = sum(Tgroups);
    ns = numel(Tvalues(1,:));
    Tlimits(1,1:nu,1:ns) = 1;
    Tlimits(2,1:nu,1:ns) = Inf;
end

if ~exist('T_delta')
    nu = sum(Tgroups);
    ns = numel(Tvalues(1,:));
    T_delta(1:nu,1:ns) = 0.5; 
end

if ~exist('adaptive_T_delta')
    adaptive_T_delta = 0; 
end


if ~exist('delay_uncertainty')
    delay_uncertainty = 0; 
end

if ~continue_flag
    clearvars -except delay_uncertainty T_delta adaptive_T_delta to Tlimits sim_duration continue_flag Tgroups Tvalues print_figures visibility_flag save_results save_figures adaptive_flag switch_mode Tmax partial_report_step partial_report_time rho load_intervals load_intervals_index

    global clock calendar queues
    clock = 0;
    calendar.n = 0;
    calendar.event = [];

    %%%%%%%%%%%%%%%%%%%%%
    %network parameters (the length of arrays must be the same, as it
    %implicitly defines the number of servers inthe system)
    np = [1 1 1]; %processors at servers
    mu = [100 200 400] ; %services/s per processor
    b = [10 10 10]; % buffer space at servers
    d = [0.010 0.020 0.030]; %distance between users and servers
    %%%%%%%%%%%%%%%%%%%%%



    rho_active = rho(load_intervals_index);
    nu = sum(Tgroups);
    ng = numel(Tgroups);
    Tmax = sum(mean(Tvalues,1)); 

    ns = numel(mu);
    arr = sum(mu.*np) * rho_active / nu; %arrivals/s per user

     
    alpha_stats = 0.1;
    alpha_adapt = 0.1;
    stat_step = 1;

    timeout = to * ones(1,nu);
    m = ones(1,nu)./arr;
    for j = 1:nu
        s(j) = 1 + mod(j+1,ns);
    end
    %clear adv

    for j = 1:ng
        if j == 1
            range = [1:Tgroups(1)];
        else
            range = [range(end)+1:range(end)+Tgroups(j)];
        end
        T(range, 1:ns) = repmat(Tvalues(j,:),numel(range),1);
    end

    for j = 1:ns
        queues(j).n = 0; %elements in the queue or in service
        queues(j).max = b(j);
        queues(j).mu = mu(j);
        queues(j).np = np(j);
        queues(j).arrivals = 0;
        queues(j).arrivals_window = 0;
        queues(j).drops = 0;
        queues(j).drops_window = 0;
        queues(j).served = 0;
        queues(j).served_window = 0;
        queues(j).list = [];
    end

    body_basename()

    strategy_rate_avg = zeros(nu,ns);
    strategy_rate_cnt = zeros(nu,ns);
    strategy_rate_all = zeros(nu,1);

    successes_user = zeros(1, nu);
    successes_user_strategy = zeros(1, nu);
    successes_user_window = zeros(1, nu);
    successes_server = zeros(1, nu);
    successes_server_window = zeros(1, nu);
    failures_user = zeros(1, nu);
    failures_user_strategy = zeros(1, nu);
    failures_user_window = zeros(1, nu);
    failures_server = zeros(1, nu);
    failures_server_window = zeros(1, nu);
    timeout_user = zeros(1, nu);
    timeout_user_window = zeros(1, nu);
    timeout_server = zeros(1, ns);
    timeout_server_window = zeros(1, ns);
    drop_user = zeros(1, nu);
    drop_user_window = zeros(1, nu);
    drop_server = zeros(1, ns);
    drop_server_window = zeros(1, ns);

    stats_queue_arrival(1,:) = zeros(1,1+ns);
    stats_queue_arrival_filtered(1,:) = zeros(1,1+ns);
    stats_queue_drop(1,:) = zeros(1,1+ns);
    stats_queue_drop_filtered(1,:) = zeros(1,1+ns);
    stats_queue_served(1,:) = zeros(1,1+ns);
    stats_queue_served_filtered(1,:) = zeros(1,1+ns);
    stats_queue_block(1,:) = zeros(1,1+ns);
    stats_queue_block_filtered(1,:) = zeros(1,1+ns);

    stats_server_drop(1,:) = zeros(1,1+ns);
    stats_server_drop_filtered(1,:) = zeros(1,1+ns);
    stats_server_timeout(1,:) = zeros(1,1+ns);
    stats_server_timeout_filtered(1,:) = zeros(1,1+ns);
    stats_server_fail(1,:) = zeros(1,1+ns);
    stats_server_fail_filtered(1,:) = zeros(1,1+ns);
    stats_server_success(1,:) = zeros(1,1+ns);
    stats_server_success_filtered(1,:) = zeros(1,1+ns);

    stats_user_drop(1,:) = zeros(1,1+nu);
    stats_user_drop_filtered(1,:) = zeros(1,1+nu);
    stats_user_timeout(1,:) = zeros(1,1+nu);
    stats_user_timeout_filtered(1,:) = zeros(1,1+nu);
    stats_user_fail(1,:) = zeros(1,1+nu);
    stats_user_fail_filtered(1,:) = zeros(1,1+nu);
    stats_user_success(1,:) = zeros(1,1+nu);
    stats_user_success_filtered(1,:) = zeros(1,1+nu);

    samples_strategy_rate(1,:) = zeros(1,1+ns);
    samples_strategy_time(1,:) = zeros(1,1+ns);


    %place the first stats update event 
    ts = stat_step;
    pkt.user = 0;
    pkt.server = 0;
    pkt.gen_time = 0;
    event.time = ts;
    event.packet = pkt;
    event.type = 11; %update stats
    calendar_push(event);
    clear ts pkt event

    %place the first packet generation for each user
    for j = 1:nu
        ts = exprnd(m(j));
        pkt.user = j;
        pkt.server = s(j);
        pkt.gen_time = ts;
        event.time = ts;
        event.packet = pkt;
        event.type = 1; %generation
        calendar_push(event);
        perf{j}(1,:) = [clock 0 s(j) 0 0 0 0];
    end
    clear ts pkt event

    population(1,1:2) = [clock sum(s==1)];
    for k = 2:ns
        population(1,k+1) = sum(s==k);
    end
    
    for j = 1:calendar.n
        fprintf('%d: src=%d, gen_time=%g, server=%d, time=%g, type=%d\n', j, calendar.event(j).packet.user, calendar.event(j).packet.gen_time, calendar.event(j).packet.server, calendar.event(j).time, calendar.event(j).type )
    end
    fprintf('\n\n')
    event_cnt = 0;

else
    %update the basename
    body_basename()
end

%now start reading from the calendar and execute events

while clock < sim_duration && calendar.n > 0
    event_cnt= event_cnt+1;
    event = calendar_pop();
    clock = event.time;
    u = event.packet.user;
    type = event.type;

    if clock > load_intervals(load_intervals_index);
        load_intervals_index = min(load_intervals_index+1, numel(rho));
        rho_active = rho(load_intervals_index);
        arr = sum(mu.*np) * rho_active / nu;
        m = ones(1,nu)./arr;
    end
    if mod(event_cnt,1000)==0
        fprintf('%d: src=%d, gen_time=%g, server=%d, time=%g, type=%d', event_cnt, event.packet.user, event.packet.gen_time, event.packet.server, event.time, event.type)
        fprintf(' population: [ ');
        fprintf('%d ',population(end,2:end))
        fprintf(']\n')
    end

    if type == 1 %generation
        body_type1()

    elseif type == 2 %queueing
        body_type2()

    elseif type == 3 %service complete
        body_type3()

    elseif type == 4 %ack delivered
        body_type4()

    elseif type == 5 %timeout because of a packet drop
        body_type5()

    elseif type == 11 %update stats
        body_type11()

    end
    clear event u type
    if save_results && clock > partial_report_time
        save(sprintf('res/res%s-partial%g.mat',basename, partial_report_time))
        if partial_report_time > partial_report_step
            system(sprintf('rm res/res%s-partial%g.mat',basename, partial_report_time - partial_report_step));
        end
        partial_report_time = partial_report_time + partial_report_step;
    end
end

%save results and matlab status
if save_results
    save(sprintf('res%s.mat',basename))
end

%print some figures and save them in eps format
if print_figures
    figure('Position',[0 0 900 450], 'visible', visibility_flag)
    hold on
    for j = 1:ns
        plot(population(:,1),population(:,j+1),'Linewidth',3,'DisplayName',sprintf('server %d',j))
    end
    xlabel('time (s)')
    ylabel('population')
    set(gca,'fontsize',24)
    legend('boxoff')
    legend('location','best')

    if save_figures
        saveas(gca, sprintf('figures/fig%s-population.eps',basename),'epsc')
    end


    figure('Position',[25 0 900 450],'visible',visibility_flag)
    hold on
    for j = 1:ns
        plot(stats_server_drop_filtered(:,1),stats_server_drop_filtered(:,j+1),'Linewidth',3,'DisplayName',sprintf('server %d',j))
    end
    xlabel('time (s)')
    ylabel('drop rate')
    set(gca,'fontsize',24)
    legend('boxoff')
    legend('location','best')

    if save_figures
        saveas(gca, sprintf('figures/fig%s-drop.eps',basename),'epsc')
    end

    figure('Position',[50 0 900 450],'visible',visibility_flag)
    hold on
    for j = 1:ns
        plot(stats_server_fail_filtered(:,1),stats_server_fail_filtered(:,j+1),'Linewidth',3,'DisplayName',sprintf('server %d',j))
    end
    xlabel('time (s)')
    ylabel('fail rate')
    set(gca,'fontsize',24)
    set(gca,'yscale','log')
    legend('boxoff')
    legend('location','best')

    if save_figures
        saveas(gca, sprintf('figures/fig%s-fail_server.eps',basename),'epsc')
    end


    figure('Position',[75 0 900 450],'visible',visibility_flag)
    hold on
    for j = 1:min(10,nu)
        plot(stats_user_fail_filtered(:,1),stats_user_fail_filtered(:,j+1),'Linewidth',3,'DisplayName',sprintf('user %d',j))
    end
    xlabel('time (s)')
    ylabel('user fail rate')
    set(gca,'fontsize',24)
    legend('boxoff')
    legend('location','best')

    if save_figures
        saveas(gca, sprintf('figures/fig%s-fail_user.eps',basename),'epsc')
    end

    clear population_sum
    cnt = zeros(1+ceil(population(end,1)/stat_step),1);
    population_sum = zeros(1+ceil(population(end,1)/stat_step),ns);
    cnt(1,1) = 1;
    population_sum(1,:) = 0;
    for j = 1:size(population,1)
        index = 1+ceil(population(j,1)/stat_step);
        population_sum(index,:) = population_sum(index,:) +  population(j,2:end);
        cnt(index,1) = cnt(index,1)+1;
    end
    size_diff = size(stats_server_fail_filtered) -size(population_sum,1); 
    if size_diff
        pad = population_sum(end,:); 
        for j = 1:size_diff
            population_sum(end+1,:) = pad;
            cnt(end+1,1) = 0;
        end
    end

    figure('Position',[100 0 900 450], 'visible',visibility_flag)
    hold on
    for j = 1:ns
        plot(stats_server_fail_filtered(:,1),(population_sum(:,j)./cnt).* stats_server_fail_filtered(:,j+1),'Linewidth',3,'DisplayName',sprintf('server %d',j))
    end
    xlabel('time (s)')
    ylabel('Population-failure product')
    set(gca,'fontsize',24)
    legend('boxoff')
    legend('location','best')

    if save_figures
        saveas(gca, sprintf('figures/fig%s-population_fail_product.eps',basename),'epsc')
    end

    arr_u = sum(mu.*np) * rho_active / nu;
    figure('Position',[125 0 900 450],'visible',visibility_flag)
    hold on
    for j = 1:ns
        plot(stats_server_fail_filtered(:,1),(population_sum(:,j)./cnt*arr_u).* stats_server_fail_filtered(:,j+1),'Linewidth',3,'DisplayName',sprintf('server %d',j))
    end
    xlabel('time (s)')
    ylabel('arrival-failure product (failure mass)')
    set(gca,'fontsize',24)
    legend('boxoff')
    legend('location','best')

    if save_figures
        saveas(gca, sprintf('figures/fig%s-failure_mass.eps',basename),'epsc')
    end


    figure('Position',[150 0 900 450],'visible',visibility_flag)
    hold on
    for j = 1:ns
        plot(samples_strategy_time(:,1),samples_strategy_time(:,1+j),'Linewidth',3,'DisplayName',sprintf('server %d',j))
    end
    xlabel('time (s)')
    ylabel('Average patience')
    set(gca,'fontsize',24)
    legend('boxoff')
    legend('location','best')

    if save_figures
        saveas(gca, sprintf('figures/fig%s-patience.eps',basename),'epsc')
    end


end









