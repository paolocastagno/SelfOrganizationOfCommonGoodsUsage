function res = queue_pop(server)
global queues clock
res = 1; 
if queues(server).n == 0 
    res = 0; 
else
    queues(server).served = queues(server).served + 1; 
    queues(server).served_window = queues(server).served_window + 1; 
    n = queues(server).n - 1 ; 
    queues(server).n = n;
    np = queues(server).np; 
    if n >= np %start a new service
        ts = clock + exprnd(1/queues(server).mu); 
        event.time = ts;
        event.packet = queues(server).list(1);
        event.type = 3; %service complete
        calendar_push(event);
        clear ts event
        %queues(server).list(1:n-np) = queues(server).list(2:n-np+1);
        queues(server).list(1) = [];
        %queues(server).list(n-np+1) = [];
    end
end
end
