% Make checkerboard phase velocity map
%

clear;

setup_parameters;
periods = parameters.periods;

%%%%%% Checkerboard properties %%%%%%
checksize_deg = 2 * ones(size(periods)); % size of checker in degrees
dv_check_frac = 0.05 * ones(size(periods)); % fraction of phase velocity perturbation (%/100)
is_box_checks = 0; % is_box_checks = 1: boxwave function (sharp edges), is_box_checks = 0: sine wave (smooth edges)
phv_ref = 4*ones(size(periods)); % Average phase velocity of checkerboard map
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

workingdir = parameters.workingdir;
lalim=parameters.lalim;
lolim=parameters.lolim;
% gridsize=parameters.gridsize;
gridsize = 0.01; % [deg] value should be much smaller than inversion grid size (more accurate travel time tracing)

% setup useful variables
xnode=lalim(1):gridsize:lalim(2);
ynode=lolim(1):gridsize:lolim(2);
Nx=length(xnode);
Ny=length(ynode);
[xi yi]=ndgrid(xnode,ynode);


%% Build checkerboard
checker = [];
for ip = 1:length(periods)
    deg_check = checksize_deg(ip);
    amp_check = dv_check_frac(ip);
    
    if is_box_checks
        check_mat = amp_check * square(pi/deg_check*xi).*square(pi/deg_check*yi);
    else
        check_mat = amp_check * sin(pi/deg_check*xi).*sin(pi/deg_check*yi);
    end
    % Calculate phase velocity map
    phv = (1+check_mat) .* phv_ref(ip);
    
    checker(ip).amp_check = amp_check;
    checker(ip).deg_check = deg_check;
    checker(ip).is_box_checks = is_box_checks;
    checker(ip).xi = xi;
    checker(ip).yi = yi;
    checker(ip).check_mat = check_mat;
    checker(ip).phv_ref = phv_ref(ip);
    checker(ip).phv = phv;
    checker(ip).period = periods(ip);
end
save([workingdir,'/checker.mat'],'checker');

%% Plot checkerboards
figure(2); set(gcf,'position',[104         118        1077         876]);
load seiscmap
cmap = seiscmap
nrow=3; ncol=3;
for ip = 1:length(periods)
    phv = checker(ip).phv;
    xi = checker(ip).xi;
    yi = checker(ip).yi;
    
    subplot(nrow,ncol,ip);
    ax2 = worldmap(lalim+[-0.001 +0.001], lolim+[-0.001 +0.001]);
    setm(gca,'MapProjection','mercator','FLineWidth',1.5,'FontSize',13)
    tightmap
    set(ax2, 'Visible', 'on')
    set(gcf,'color','w')
    setm(gca,'FFaceColor',[0.9 0.9 0.9])
    surfacem(xi,yi,phv);
    caxis([min(phv(:)) max(phv(:))])
    cb = colorbar;
    ylabel(cb,'Phase Velocity','fontsize',15);
    colormap(cmap);  
    set(cb,'linewidth',1.5,'fontsize',15);
    set(gca,'fontsize',15);
    hold on;
    plotm(stlat,stlon,'ok','markerfacecolor',[0 0 0],'MarkerEdgeColor',[1 1 1]);
    title([num2str(periods(ip)),' s']);
end