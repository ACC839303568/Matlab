% Demonstrates evaluating plot type names in order to
% use the plot functions and put the names in titles

year = 2013:2017;
pop = [0.9  1.4  1.7  1.3  1.8];
titles = {'plot', 'bar', 'area', 'stem'};
for i = 1:4
    subplot(2,2,i)
    eval([titles{i} '(year,pop)'])
    title(titles{i})
    xlabel('Year')
    ylabel('Population (mil)')
end
