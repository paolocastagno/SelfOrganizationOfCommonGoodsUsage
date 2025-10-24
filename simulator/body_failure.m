%failure - check if it is time to switch

failures_user(u) = failures_user(u)+1;
failures_user_strategy(u) = failures_user_strategy(u)+1;
failures_user_window(u) = failures_user_window(u) + 1;
failures_server(event.packet.server) = failures_server(event.packet.server) + 1;
failures_server_window(event.packet.server) = failures_server_window(event.packet.server) + 1;

if failures_user_strategy(u) >= T(u,s(u))

    strategy_rate = successes_user_strategy(u)/failures_user_strategy(u); % + 1;
 
    if adaptive_flag == 1
        %Vincenzo's proposal
        if strategy_rate >= strategy_rate_avg(u, s(u))
            T(u,s(u)) = T(u,s(u)) + 1;
        else
            T(u,s(u)) = T(u,s(u)) - 1;
            T(u,s(u)) = max(T(u,s(u)), 1);
        end
        %update
        strategy_rate_avg(u,s(u)) = (1-alpha_adapt) * strategy_rate_avg(u,s(u)) + alpha_adapt * strategy_rate;
    elseif adaptive_flag == 2
        %Marco's proposal
        if strategy_rate >= strategy_rate_all(u)
            if adaptive_T_delta
                T_delta(u,s(u)) = 2 * T_delta(u,s(u));
                T(u,s(u)) = min(T(u,s(u)) + T_delta(u,s(u)), Tlimits(2,u,s(u)));
            else
                T(u,s(u)) = min(T(u,s(u)) + 1, Tlimits(2,u,s(u)));
            end
        else
            if adaptive_T_delta
                T_delta(u,s(u)) = 0.5;
                T(u,s(u)) = max(0.5 * T(u,s(u)), Tlimits(1,u,s(u)));
            else
                T(u,s(u)) = max(T(u,s(u)) - 1, Tlimits(1,u,s(u)));
            end
        end
        %update
        strategy_rate_avg(u,s(u)) = (1-alpha_adapt) * strategy_rate_avg(u,s(u)) + alpha_adapt * strategy_rate;
    elseif adaptive_flag == 3
        %Diogo's original proposal modified to adapt the total patience
        %update first
        strategy_rate_avg(u,s(u)) = (1-alpha_adapt) * strategy_rate_avg(u,s(u)) + alpha_adapt * strategy_rate;
        [Tmax_local(1)  Tmax_local(2)] = max(strategy_rate_avg(u, :));
        if strategy_rate_avg(u, s(u)) < strategy_rate_avg(u, Tmax_local(2))
            if T(u,s(u)) > Tlimits(1,u,s(u))
                if adaptive_T_delta
                    T_delta(u,s(u)) = min(0.5 * T(u,s(u)), T(u,s(u)) - Tlimits(1,u,s(u)));
                    T(u,s(u)) = T(u,s(u)) - T_delta(u,s(u));
                    sum_T_local = 0;
                    for j = 1:numel(d)
                        if j ~= s(u)
                            sum_T_local = sum_T_local + T(u,j); 
                        end
                    end
                    for j = 1:numel(d)
                        if j ~= s(u)
                           T(u,j) = T(u,j) * (1 + T_delta(u,s(u))/sum_T_local); 
                        end
                    end
                else
                    T(u,s(u)) = T(u,s(u)) - 1;
                    T(u, Tmax_local(2)) = T(u, Tmax_local(2)) + 1;
                end
            end
        else %the current server is the best
            %if the trend is negative, decrease the patience anyway
            %without redistributing
            if strategy_rate < strategy_rate_avg(u,s(u))
                if T(u,s(u)) > Tlimits(1,u,s(u))
                    if adaptive_T_delta
                        T(u,s(u)) = T(u,s(u)) - min(0.9 * T(u,s(u)), T(u,s(u)) - Tlimits(1,u,s(u)));;
                    else
                        T(u,s(u)) = T(u,s(u)) - 1;
                    end
                end
            end
        end
    elseif adaptive_flag == 4
        %Diogo's original proposal
        %update first
        strategy_rate_avg(u,s(u)) = (1-alpha_adapt) * strategy_rate_avg(u,s(u)) + alpha_adapt * strategy_rate;
        [Tmax_local(1)  Tmax_local(2)] = max(strategy_rate_avg(u, :));
        if strategy_rate_avg(u, s(u)) < strategy_rate_avg(u, Tmax_local(2))
            if T(u,s(u)) > Tlimits(1,u,s(u))
                if adaptive_T_delta
                    T_delta(u,s(u)) = min(0.5 * T(u,s(u)), T(u,s(u)) - Tlimits(1,u,s(u)));
                    T(u,s(u)) = T(u,s(u)) - T_delta(u,s(u));
                    sum_T_local = 0;
                    for j = 1:numel(d)
                        if j ~= s(u)
                            sum_T_local = sum_T_local + T(u,j); 
                        end
                    end
                    for j = 1:numel(d)
                        if j ~= s(u)
                           T(u,j) = T(u,j) * (1 + T_delta(u,s(u))/sum_T_local); 
                        end
                    end
                else
                    T(u,s(u)) = T(u,s(u)) - 1;
                    T(u, Tmax_local(2)) = T(u, Tmax_local(2)) + 1;
                end
            end
        else %remove the else if you want to preserve the sum of T values
            if T(u,s(u)) < Tlimits(2,u,s(u))
                if adaptive_T_delta
                    T_delta(u,s(u)) = ceil(min(0.1 * T(u,s(u)), - T(u,s(u)) + Tlimits(2,u,s(u))));
                    T(u,s(u)) = T(u,s(u)) + T_delta(u,s(u));
                else
                    T(u,s(u)) = T(u,s(u)) + 1;
                end
            end
        end
    end

    %update
    strategy_rate_all(u) = (1-alpha_adapt) * strategy_rate_all(u) + alpha_adapt * strategy_rate;
    strategy_rate_cnt(u,s(u)) = strategy_rate_cnt(u,s(u)) + 1;
   

    %switch server
    s_old = s(u);
    if switch_mode == 0
        while s(u) == s_old
            s(u) = randi(ns);
        end
    elseif switch_mode == 1
        pr = cumsum([T(u,1:end ~= s(u))]);
        pr = pr / pr(end);
        r = rand();
        k = 1;
        while pr(k) < r
            k = k+1;
        end
        if k >= s(u)
            k = k+1;
        end
        s(u) = k;
        clear k r pr
    end

    population(end+1,:) = population(end,:);
    population(end,1) = clock;
    population(end,1+s_old) = population(end-1,1+s_old) - 1;
    population(end,1+s(u)) = population(end-1,1+s(u)) + 1;

    perf{u}(end+1,:) = [clock s_old s(u) successes_user_strategy(u) failures_user_strategy(u) strategy_rate strategy_rate_avg(s_old)];
    failures_user_strategy(u) = 0;
    successes_user_strategy(u) = 0;

    clear strategy_rate
end

