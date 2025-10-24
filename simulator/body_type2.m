%queueing

res = queue_push(event.packet);
if res == 0 %drop
    event_fail.time = event.packet.gen_time + timeout(u);
    event_fail.packet = event.packet;
    event_fail.type = 5; %failure due to overflow
    calendar_push(event_fail);
    clear event_fail;
else %ok
    %stats?
end

clear res
