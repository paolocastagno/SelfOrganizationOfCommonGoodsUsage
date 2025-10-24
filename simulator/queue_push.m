function res = queue_push(packet)
global queues clock
server = packet.server; 
n = queues(server).n; 
np = queues(server).np; 
queues(server).arrivals = queues(server).arrivals+1;
queues(server).arrivals_window = queues(server).arrivals_window + 1;
res = 1; 
if n < np %start service
    queues(server).n = n+1;
    ts = clock + exprnd(1/queues(server).mu); 
    event.time = ts;
    event.packet = packet;
    event.type = 3; %service complete
    calendar_push(event);
    clear ts event
elseif n < queues(server).max %enqueue
    queues(server).n = queues(server).n+1;
    queues(server).list(n+1-np).gen_time = packet.gen_time; 
    queues(server).list(n+1-np).user = packet.user; 
    queues(server).list(n+1-np).server = packet.server; 
else
    res = 0; %drop
    queues(server).drops = queues(server).drops+1;
    queues(server).drops_window = queues(server).drops_window + 1; 
end
end
