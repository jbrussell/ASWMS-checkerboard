This is a set of codes for performing a checkerboard test using the ASWMS framework. The test dataset was made using the NoMelt station geometry and 100 real earthquakes that occurred during the deployment.
jbrussell 2021/06

%%%%%% Required files%%%%%%

stations.txt: Text file containing the station coordinates
[Station name] [latitude] [longitude] [elevation]

events.txt: Text file containing the event coordinates
[Event id] [latitude] [longitude] [depth]


%%%%%% Part A: Making the checkerboard and tracing rays %%%%%%
a1_make_checkerboard: Make the synthetic phase velocity map with options for checker style (box vs. sinusoid), size, amplitude, etc.
a2_trace_tt: Traces rays through the checkerboard assuming great-circle propagation and save in the "CSmeasure" data structures. These will be fed into the ASWMS inversion.


%%%%%% Part B: Two-step eikonal inversion %%%%%%
b1_eikonal_eq: The original eikonal inversion for phase velocity slowness and propagation azimuth. One eikonal phase velocity map is estimated for each event in the catalogue.
b2_stack_phv: Stacks all eikonal maps produced in b1.


%%%%%% Part C: All-in-one eikonal inversion %%%%%%
c1_eikonal_eq_2DanisoRT: This version inverts for a single phase velocity map (and 2D anisotropy) at each frequency using all events at once. Some preliminary testing indicates that this inversion requires less smoothing to achieve the same model roughness as b1+b2. There are some extra QC parameters at the beginning of this script which can be useful with real data but probably not for these synethic tests. Must be patient... this one can take a while to run.



% Note: There is no inherent difference between different frequencies in the inversion. All assume perfect rays. Smoothing is not wavelength dependent unless you force it to be by choosing larger smoothing for longer periods (which is done by default). One option to make it more realistic is to remove measurements for interstation pairs with differential epicentral distance < some fraction of a wavelength. This can be achieved in c1 by adjusting min_stadist_wavelength. For example, min_stadist_wavelength = 1 would remove any measurements where the station separation is less than one wavelength.
