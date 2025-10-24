%service complete

res = queue_pop(event.packet.server);
if res > 0
    event_ack.time = clock + d(event.packet.server) * (1+delay_uncertainty*(-1+2*rand()));
    event_ack.packet = event.packet;
    event_ack.type = 4; %ack delivered
    calendar_push(event_ack);
    clear event_ack;
else
    %this should not happen
end

clear res
