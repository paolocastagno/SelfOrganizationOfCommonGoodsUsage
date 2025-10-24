%basename setup


basename = sprintf('-ns_%d-np',ns);
for j = 1:ns
    basename = sprintf('%s_%d',basename, np(j));
end
basename = sprintf('%s-mu',basename);
for j = 1:ns
    basename = sprintf('%s_%d',basename, mu(j));
end
basename = sprintf('%s-b',basename);
for j = 1:ns
    basename = sprintf('%s_%d',basename, b(j));
end
basename = sprintf('%s-d',basename);
for j = 1:ns
    basename = sprintf('%s_%g',basename, d(j));
end
basename = sprintf('%s-T',basename);

if adaptive_flag
    for j = 1:ng
        basename = sprintf('%s-gr%d_n%d_v',basename,j,Tgroups(j));
        for k = 1:ns
            basename = sprintf('%s_%d',basename, Tvalues(j,k));
        end
    end
    clear j
else
    basename = sprintf('%s-avg',basename);
    for j = 1:ns
        basename = sprintf('%s_%d',basename, mean(T(:,j)));
    end
    basename = sprintf('%s-min',basename);
    for j = 1:ns
        basename = sprintf('%s_%d',basename, min(T(:,j)));
    end
    basename = sprintf('%s-max',basename);
    for j = 1:ns
        basename = sprintf('%s_%d',basename, max(T(:,j)));
    end
end
fprintf("%s\n",basename)
basename = sprintf('%s-nu_%d-rho_%g',basename, nu, rho(1));
basename = sprintf('%s-to_%g',basename, to);
basename = sprintf('%s-dur_%g',basename, sim_duration);
if adaptive_flag == 1
    basename = sprintf('%s-adaptive_V',basename);
elseif adaptive_flag == 2
    basename = sprintf('%s-adaptive_M',basename);
elseif adaptive_flag == 3
    basename = sprintf('%s-adaptive_D',basename);
elseif adaptive_flag == 4
    basename = sprintf('%s-adaptive_D0',basename);
end
if switch_mode ==1
    basename = sprintf('%s-Tprop',basename);
end
if adaptive_flag > 0 && adaptive_T_delta == 1
    basename = sprintf('%s-Tdelta_adapt',basename);
end
if delay_uncertainty > 0 
    basename = sprintf('%s-rnd_del_%g',basename, delay_uncertainty);
end


fprintf("%s\n",basename)

