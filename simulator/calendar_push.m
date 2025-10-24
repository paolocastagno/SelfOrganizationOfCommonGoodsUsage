function calendar_push(event)
global calendar 
%queue serving serving_limit buffer_limit d failures attempts 


n = calendar.n; 
j = 1;
time = event.time;

if n > 0
    range = [1 n];
    centre = ceil(mean(range));
    centre_old = 0;
    while (centre_old - centre) ~= 0 && diff(range)>0
        if calendar.event(centre).time < time
            range(1) = centre;
        else
            range(2) = centre;
        end
        centre_old = centre; 
        centre = ceil(mean(range));
    end
    centre = range(1);
    if calendar.event(centre).time > time        
        calendar.event(centre+1:n+1) =  calendar.event(centre:n);
    else
        centre = centre + 1; 
        if centre <= n 
            calendar.event(centre+1:n+1) =  calendar.event(centre:n);
        end
    end
else
    centre = 1;
end

calendar.event(centre).packet =  event.packet;
calendar.event(centre).time =  event.time;
calendar.event(centre).type =  event.type;
calendar.n = calendar.n+1;

end