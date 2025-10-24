%timeout because of a packet drop

body_failure()
drop_user(u) = drop_user(u) + 1;
drop_user_window(u) = drop_user_window(u) + 1;
drop_server(event.packet.server) = drop_server(event.packet.server) + 1;
drop_server_window(event.packet.server) = drop_server_window(event.packet.server) + 1;
