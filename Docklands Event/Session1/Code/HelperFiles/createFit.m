function [pd1,pd2] = createFit(y)
    %CREATEFIT    Create plot of datasets and fits
    %   [PD1,PD2] = CREATEFIT(Y)
    %   Creates a plot, similar to the plot in the main distribution fitting
    %   window, using the data that you provide as input.  You can
    %   apply this function to the same data you used with dfittool
    %   or with different data.  You may want to edit the function to
    %   customize the code and this help message.
    %
    %   Number of datasets:  1
    %   Number of fits:  2
    %
    %   See also FITDIST.
    
    % This function was automatically generated on 25-Feb-2012 16:57:48
    
    % Output fitted probablility distributions: PD1,PD2
    
    % Data from dataset "y data":
    %    Y = y
    
    % Force all inputs to be column vectors
    y = y(:);
    
    % Prepare figure
    clf;
    hold on;
    LegHandles = []; LegText = {};
    
    
    % --- Plot data originally in dataset "y data"
    [CdfF,CdfX] = ecdf(y,'Function','cdf');  % compute empirical cdf
    BinInfo.rule = 1;
    [~,BinEdge] = internal.stats.histbins(y,[],[],BinInfo,CdfF,CdfX);
    [BinHeight,BinCenter] = ecdfhist(CdfF,CdfX,'edges',BinEdge);
    hLine = bar(BinCenter,BinHeight,'hist');
    set(hLine,'FaceColor','none','EdgeColor',[0.333333 0 0.666667],...
        'LineStyle','-', 'LineWidth',1);
    xlabel('Data');
    ylabel('Density')
    LegHandles(end+1) = hLine;
    LegText{end+1} = 'y data';
    
    % Create grid where function will be computed
    XLim = get(gca,'XLim');
    XLim = XLim + [-1 1] * 0.01 * diff(XLim);
    XGrid = linspace(XLim(1),XLim(2),100);
    
    
    % --- Create fit "NormalFit"
    
    % Fit this distribution to get parameter values
    % To use parameter estimates from the original fit:
    %     pd1 = ProbDistUnivParam('normal',[ 0.0002915312542661, 0.009481616083821])
    pd1 = fitdist(y, 'normal');
    YPlot = pdf(pd1,XGrid);
    hLine = plot(XGrid,YPlot,'Color',[1 0 0],...
        'LineStyle','-', 'LineWidth',2,...
        'Marker','none', 'MarkerSize',6);
    LegHandles(end+1) = hLine;
    LegText{end+1} = 'NormalFit';
    
    % --- Create fit "TLocationScaleFit"
    
    % Fit this distribution to get parameter values
    % To use parameter estimates from the original fit:
    %     pd2 = ProbDistUnivParam('tlocationscale',[ 0.0006009561679579, 0.006346374800247, 3.391598137629])
    pd2 = fitdist(y, 'tlocationscale');
    YPlot = pdf(pd2,XGrid);
    hLine = plot(XGrid,YPlot,'Color',[0 0 1],...
        'LineStyle','-', 'LineWidth',2,...
        'Marker','none', 'MarkerSize',6);
    LegHandles(end+1) = hLine;
    LegText{end+1} = 'TLocationScaleFit';
    
    % Adjust figure
    box on;
    hold off;
    
    % Create legend from accumulated handles and labels
    hLegend = legend(LegHandles,LegText,'Orientation', 'vertical', 'Location', 'NorthEast');
    set(hLegend,'Interpreter','none');
