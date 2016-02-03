function plotCPExposure(dates, cpExposure, idx)

scale = 1000;

clf

h = plot(dates, cpExposure/scale, 'Color', [.8 .8 .8]);
h = h(1); set(h(1),'DisplayName','Exposures');
[EEcp, PEcp, MPEcp, EffEEcp] = computeExposureProfiles(cpExposure);

h(2) = line(dates, EEcp/scale, 'LineWidth', 2, 'Color', 'b', 'DisplayName', 'EE');
h(3) = line(dates, EffEEcp/scale, 'Color', 'b', 'DisplayName', 'Eff EE');
h(4) = line(dates, PEcp/scale, 'LineWidth', 2, 'Color', 'r', 'DisplayName', 'PFE');
h(5) = line(dates([1 end]), MPEcp/scale*[1 1], 'Color', 'r', 'LineStyle', ':', 'DisplayName', 'Max PFE');

xlabel('Simulation Date');
ylabel('Swap Exposure (x1000$)');
%dynamicDateTicks
datetick('x','keeplimits');

legend(h,'location','best');

titleStr = 'Exposure profiles for counterparty';
if nargin > 2
    titleStr = [titleStr ' ' int2str(idx)];
end
title(titleStr);