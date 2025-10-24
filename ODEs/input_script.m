% Dumb users with heterogeneous patience
% 
% 

sim_duration = 50000;
switch_mode = 0;
adaptive_flag = 4;
Tgroups = [450 550];
Tvalues = [3 5 7; 3 5 7]; 
Tlimits(1:2,1:450,1) = 3;
Tlimits(1:2,1:450,2) = 5;
Tlimits(1:2,1:450,3) = 7;
Tlimits(1,451:1000,1:3) = 1;
Tlimits(2,451:1000,1:3) = 13;
gaming_var


sim_duration = 50000;
switch_mode = 0;
adaptive_flag = 2;
Tgroups = [450 550];
Tvalues = [3 5 7; 3 5 7]; 
Tlimits(1:2,1:450,1) = 3;
Tlimits(1:2,1:450,2) = 5;
Tlimits(1:2,1:450,3) = 7;
Tlimits(1,451:1000,1:3) = 1;
Tlimits(2,451:1000,1:3) = 100;
gaming_var


sim_duration = 50000;
switch_mode = 0;
adaptive_flag = 0;
Tgroups = [450 550];
Tvalues = [3 5 7; 1 9 26]; 
Tlimits(1:2,1:450,1) = 3;
Tlimits(1:2,1:450,2) = 5;
Tlimits(1:2,1:450,3) = 7;
Tlimits(1:2,451:1000,1) = 1;
Tlimits(1:2,451:1000,2) = 9;
Tlimits(1:2,451:1000,3) = 26;
gaming_var



sim_duration = 50000;
switch_mode = 0;
adaptive_flag = 2;
Tgroups = [300 700];
Tvalues = [5 5 5; 5 5 5]; 
Tlimits(1:2,1:450,1:3) = 5;
Tlimits(1,301:1000,1:3) = 1;
Tlimits(2,301:1000,1:3) = 100;
gaming_var



%%%%

sim_duration = 50000;
switch_mode = 0;
adaptive_T_delta = 1;
adaptive_flag = 4;
Tgroups = [300 700];
Tvalues = [5 5 5; 34 34 34]; 
Tlimits(1:2,1:450,1:3) = 5;
Tlimits(1,301:1000,1:3) = 1;
Tlimits(2,301:1000,1:3) = 100;
gaming_var


sim_duration = 50000;
switch_mode = 0;
adaptive_T_delta = 1;
adaptive_flag = 2;
Tgroups = [300 700];
Tvalues = [5 5 5; 34 34 34]; 
Tlimits(1:2,1:300,1:3) = 5;
Tlimits(1,301:1000,1:3) = 1;
Tlimits(2,301:1000,1:3) = 1000;
gaming_var


%%%%%%
%variable load
%%%%%%

sim_duration = 50000;
switch_mode = 0;
adaptive_T_delta = 1;
adaptive_flag = 2;
Tgroups = [300 700];
Tvalues = [5 5 5; 1 1 1]; 
Tlimits(1:2,1:300,1:3) = 5;
Tlimits(1,301:1000,1:3) = 1;
Tlimits(2,301:1000,1:3) = 1000;
rho = [0.75 0.95 0.75 0.5 0.75];
load_intervals = [1:5] * 10000; 
gaming_var


sim_duration = 50000;
switch_mode = 0;
adaptive_T_delta = 1;
adaptive_flag = 4;
Tgroups = [300 700];
Tvalues = [5 5 5; 1 1 1]; 
Tlimits(1:2,1:300,1:3) = 5;
Tlimits(1,301:1000,1:3) = 1;
Tlimits(2,301:1000,1:3) = 50;
rho = [0.75 0.95 0.75 0.5 0.75];
load_intervals = [1:5] * 10000; 
gaming_var


******


%%%%%%
%variable load v2
%%%%%%

sim_duration = 50000;
switch_mode = 0;
adaptive_T_delta = 1;
adaptive_flag = 2;
Tgroups = [249 751];
Tvalues = [5 5 5; 1 1 1]; 
Tlimits(1:2,1:300,1:3) = 5;
Tlimits(1,301:1000,1:3) = 1;
Tlimits(2,301:1000,1:3) = 1000;
rho = [0.75 0.95 0.75 0.5 0.75];
load_intervals = [1:5] * 10000; 
gaming_var


sim_duration = 50000;
switch_mode = 0;
adaptive_T_delta = 1;
adaptive_flag = 4;
Tgroups = [300 700];
Tvalues = [5 5 5; 1 1 1]; 
Tlimits(1:2,1:300,1:3) = 5;
Tlimits(1,301:1000,1:3) = 1;
Tlimits(2,301:1000,1:3) = 50;
rho = [0.75 0.95 0.75 0.5 0.75];
load_intervals = [1:5] * 10000; 
gaming_var


******************



delay_uncertainty = 0.1;
sim_duration = 50000;
switch_mode = 0;
adaptive_T_delta = 1;
adaptive_flag = 4;
Tgroups = [300 700];
Tvalues = [5 5 5; 1 1 1]; 
Tlimits(1:2,1:300,1:3) = 5;
Tlimits(1,301:1000,1:3) = 1;
Tlimits(2,301:1000,1:3) = 50;
rho = [0.75 0.95 0.75 0.5 0.75];
load_intervals = [1:5] * 10000; 
gaming_var

delay_uncertainty = 0.2;
sim_duration = 50000;
switch_mode = 0;
adaptive_T_delta = 1;
adaptive_flag = 4;
Tgroups = [300 700];
Tvalues = [5 5 5; 1 1 1]; 
Tlimits(1:2,1:300,1:3) = 5;
Tlimits(1,301:1000,1:3) = 1;
Tlimits(2,301:1000,1:3) = 50;
rho = [0.75 0.95 0.75 0.5 0.75];
load_intervals = [1:5] * 10000; 
gaming_var

delay_uncertainty = 0.1;
sim_duration = 50000;
switch_mode = 0;
adaptive_T_delta = 1;
adaptive_flag = 2;
Tgroups = [300 700];
Tvalues = [5 5 5; 1 1 1]; 
Tlimits(1:2,1:300,1:3) = 5;
Tlimits(1,301:1000,1:3) = 1;
Tlimits(2,301:1000,1:3) = 50;
rho = [0.75 0.95 0.75 0.5 0.75];
load_intervals = [1:5] * 10000; 
gaming_var

delay_uncertainty = 0.2;
sim_duration = 50000;
switch_mode = 0;
adaptive_T_delta = 1;
adaptive_flag = 2;
Tgroups = [300 700];
Tvalues = [5 5 5; 1 1 1]; 
Tlimits(1:2,1:300,1:3) = 5;
Tlimits(1,301:1000,1:3) = 1;
Tlimits(2,301:1000,1:3) = 50;
rho = [0.75 0.95 0.75 0.5 0.75];
load_intervals = [1:5] * 10000; 
gaming_var




