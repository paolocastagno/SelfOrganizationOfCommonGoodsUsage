%UPDATE OF STATISTICS 

stats_queue_arrival(end+1,1) = clock;
stats_queue_arrival_filtered(end+1,1) = clock;
stats_queue_drop(end+1,1) = clock;
stats_queue_drop_filtered(end+1,1) = clock;
stats_queue_served(end+1,1) = clock;
stats_queue_served_filtered(end+1,1) = clock;
stats_queue_block(end+1,1) = clock;
stats_queue_block_filtered(end+1,1) = clock;

stats_server_drop(end+1,1) = clock;
stats_server_drop_filtered(end+1,1) = clock;
stats_server_timeout(end+1,1) = clock;
stats_server_timeout_filtered(end+1,1) = clock;
stats_server_fail(end+1,1) = clock;
stats_server_fail_filtered(end+1,1) = clock;
stats_server_success(end+1,1) = clock;
stats_server_success_filtered(end+1,1) = clock;

stats_user_drop(end+1,1) = clock;
stats_user_drop_filtered(end+1,1) = clock;
stats_user_timeout(end+1,1) = clock;
stats_user_timeout_filtered(end+1,1) = clock;
stats_user_fail(end+1,1) = clock;
stats_user_fail_filtered(end+1,1) = clock;
stats_user_success(end+1,1) = clock;
stats_user_success_filtered(end+1,1) = clock;

samples_strategy_rate(end+1,:) = [clock mean(strategy_rate_avg)];
samples_strategy_time(end+1,:) = [clock mean(T)];


for k = 1:ns
    arr = queues(k).arrivals_window;
    queues(k).arrivals_window = 0;
    drop = queues(k).drops_window;
    queues(k).drops_window = 0;
    served = queues(k).served_window;
    queues(k).served_window = 0;

    stats_queue_block(end,k+1) = drop/arr;
    stats_queue_drop(end,k+1) = drop/stat_step;
    stats_queue_arrival(end,k+1) = arr/stat_step;
    stats_queue_served(end,k+1) = served/stat_step;
    if arr
        stats_queue_arrival_filtered(end,k+1) = arr/stat_step * alpha_stats + (1-alpha_stats) * stats_queue_arrival_filtered(end-1,k+1);
        stats_queue_drop_filtered(end,k+1) = drop/stat_step * alpha_stats + (1-alpha_stats) * stats_queue_drop_filtered(end-1,k+1);
        stats_queue_served_filtered(end,k+1) = served/stat_step * alpha_stats + (1-alpha_stats) * stats_queue_served_filtered(end-1,k+1);
        stats_queue_block_filtered(end,k+1) = drop/arr * alpha_stats + (1-alpha_stats) * stats_queue_drop_filtered(end-1,k+1);
    else
        stats_queue_drop_filtered(end,k+1) = stats_queue_drop_filtered(end-1,k+1);
        stats_queue_block_filtered(end,k+1) = stats_queue_block_filtered(end-1,k+1);
        stats_queue_arrival_filtered(end,k+1) = stats_queue_arrival_filtered(end-1,k+1);
        stats_queue_served_filtered(end,k+1) = stats_queue_served_filtered(end-1,k+1);
    end

    drop = drop_server_window(k);
    drop_server_window(k) = 0;
    tout = timeout_server_window(k);
    timeout_server_window(k) = 0;
    fail= failures_server_window(k);
    failures_server_window(k) = 0;
    succ = successes_server_window(k);
    successes_server_window(k) = 0;

    stats_server_drop(end,k+1) = drop/(fail+succ);
    stats_server_timeout(end,k+1) = tout/(fail+succ);
    stats_server_fail(end,k+1) = fail/(fail+succ);
    stats_server_success(end,k+1) = succ/(fail+succ);
    if fail+succ
        stats_server_drop_filtered(end,k+1) = drop/(fail+succ) * alpha_stats + (1-alpha_stats) * stats_server_drop_filtered(end-1,k+1);
        stats_server_timeout_filtered(end,k+1) = fail/(fail+succ) * alpha_stats + (1-alpha_stats) * stats_server_timeout_filtered(end-1,k+1);
        stats_server_fail_filtered(end,k+1) = fail/(fail+succ) * alpha_stats + (1-alpha_stats) * stats_server_fail_filtered(end-1,k+1);
        stats_server_success_filtered(end,k+1) = fail/(fail+succ) * alpha_stats + (1-alpha_stats) * stats_server_success_filtered(end-1,k+1);
    else
        stats_server_drop_filtered(end,k+1) = stats_server_drop_filtered(end-1,k+1);
        stats_server_timeout_filtered(end,k+1) = stats_server_timeout_filtered(end-1,k+1);
        stats_server_fail_filtered(end,k+1) = stats_server_fail_filtered(end-1,k+1);
        stats_server_success_filtered(end,k+1) = stats_server_success_filtered(end-1,k+1);
    end

end
clear succ arr drop fail tout block

for k = 1:nu
    drop = drop_user_window(k);
    drop_user_window(k) = 0;
    tout = timeout_user_window(k);
    timeout_user_window(k) = 0;
    fail = failures_user_window(k);
    failures_user_window(k) = 0;
    succ = successes_user_window(k);
    successes_user_window(k) = 0;

    stats_user_drop(end,k+1) = drop/(succ+fail);
    stats_user_timeout(end,k+1) = tout/(succ+fail);
    stats_user_fail(end,k+1) = fail/(succ+fail);
    stats_user_success(end,k+1) = succ/(succ+fail);
    if succ+fail
        stats_user_drop_filtered(end,k+1) = drop/(succ+fail) * alpha_stats + (1-alpha_stats) * stats_user_drop_filtered(end-1,k+1);
        stats_user_timeout_filtered(end,k+1) = tout/(succ+fail) * alpha_stats + (1-alpha_stats) * stats_user_timeout_filtered(end-1,k+1);
        stats_user_fail_filtered(end,k+1) = fail/(succ+fail) * alpha_stats + (1-alpha_stats) * stats_user_fail_filtered(end-1,k+1);
        stats_user_success_filtered(end,k+1) = succ/(succ+fail) * alpha_stats + (1-alpha_stats) * stats_user_success_filtered(end-1,k+1);
    else
        stats_user_drop_filtered(end,k+1) = stats_user_drop_filtered(end-1,k+1);
        stats_user_timeout_filtered(end,k+1) = stats_user_timeout_filtered(end-1,k+1);
        stats_user_fail_filtered(end,k+1) = stats_user_fail_filtered(end-1,k+1);
        stats_user_success_filtered(end,k+1) = stats_user_success_filtered(end-1,k+1);
    end

end
clear succ drop fail tout

if mod(size(stats_server_drop,1),5) == 1
    fprintf('time=%g ',clock)
    fprintf('--- drop rate: ')
    fprintf('%g ',stats_server_drop_filtered(end,2:end))
    fprintf('--- Patience: ');
    fprintf('%g ',samples_strategy_time(end,2:end))
    fprintf('--- Utility:')
    fprintf('%g ',samples_strategy_rate(end,2:end))
    fprintf('\n')
end
event.time = event.time + stat_step;
calendar_push(event);
