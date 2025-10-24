%packet generation 

ts = clock + d(s(u)) * (1+delay_uncertainty*(-1+2*rand()));
pkt.user = u;
pkt.server = s(u);
pkt.gen_time = event.packet.gen_time;
event_queue.time = ts;
event_queue.packet = pkt;
event_queue.type = 2; %queueing
calendar_push(event_queue);

ts = clock + exprnd(m(u));
pkt.gen_time = ts;
event_next.time = ts;
event_next.packet = pkt;
event_next.type = 1; %generation
calendar_push(event_next);

clear ts pkt event_queue event_next
