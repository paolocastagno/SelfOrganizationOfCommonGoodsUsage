function event = calendar_pop()
global calendar 

if calendar.n > 0
    event = calendar.event(1); 
    %calendar.event(1:calendar.n-1) = calendar.event(2:calendar.n); 
    %calendar.event(calendar.n)=[];
    calendar.event(1)=[];
    calendar.n = calendar.n - 1;
else
    event.time = 0;
    event.type = 0;
    event.packet = []; 
end

end