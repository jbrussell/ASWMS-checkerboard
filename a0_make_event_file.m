% Make file containing list of earthquakes
%
% evid lat lon depth
%

% Path to idagrn CMT files
path2cmt = '~/BROWN/RESEARCH/PROJ_NoMelt/DATA/EVENTS/fetch_EVENTS/IRIS_ZA_5.5_Zcorr/CMT2idagrn/';
% Path to output event file
outfile = './events.txt';

max_depth = 50; % km

cmtfiles = dir([path2cmt,'/evt*']);
% Loop over CMT files
evid={}; lat=[]; lon=[]; detph_km=[];
for ie=1:length(cmtfiles)
    
    % Load values from CMT idagrn file
    fname = [path2cmt,'/',cmtfiles(ie).name];
    
    fid = fopen(fname,'r');
    evid{ie} = sscanf(fgetl(fid),'%s');
    temp = sscanf(fgetl(fid),'%f %f %f');
    lat(ie) = temp(1);
    lon(ie) = temp(2);
    depth_km(ie) = temp(3);
    mult_fac = sscanf(fgetl(fid),'%f');
    m_rr = sscanf(fgetl(fid),'%f');
    m_tt = sscanf(fgetl(fid),'%f');
    m_pp = sscanf(fgetl(fid),'%f');
    m_rt = sscanf(fgetl(fid),'%f');
    m_rp = sscanf(fgetl(fid),'%f');
    m_tp = sscanf(fgetl(fid),'%f');    
    fclose(fid);
    
%     disp(['Working on ' evid])

end

% Write event file
fid = fopen(outfile,'w');
for ie = 1:length(evid)
    if depth_km(ie) > max_depth
        continue
    end
    fprintf(fid,'%s %8.2f %8.2f %8.2f\n',evid{ie},lat(ie),lon(ie),depth_km(ie));
end
fclose(fid); 