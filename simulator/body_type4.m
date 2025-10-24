%ack delivered

if clock - event.packet.gen_time > timeout(u)
    body_failure()
    timeout_user(u) = timeout_user(u) + 1;
    timeout_user_window(u) = timeout_user_window(u) + 1;
    timeout_server(event.packet.server) = timeout_server(event.packet.server) + 1;
    timeout_server_window(event.packet.server) = timeout_server_window(event.packet.server) + 1;
else
    successes_user(u) = successes_user(u)+1;
    successes_user_strategy(u) = successes_user_strategy(u)+1;
    successes_user_window(u) = successes_user_window(u) + 1;
    successes_server(event.packet.server) = successes_server(event.packet.server) + 1;
    successes_server_window(event.packet.server) = successes_server_window(event.packet.server) + 1;
end
